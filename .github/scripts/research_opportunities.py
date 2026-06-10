#!/usr/bin/env python3
"""
Weekly opportunity research for the Saudi Opportunity Hub.

Pipeline:
  1. Pull existing opportunity titles + sponsors from Supabase (dedup baseline)
  2. Run Bright Data SERP queries across known funding sources, OR fall back to
     Claude's native web_search tool when BRIGHTDATA_API_TOKEN isn't set
  3. Feed search hits + dedup context into Claude with the 3-layer verification
     prompt; Claude returns JSON candidates + REJECTED notes
  4. Write a Markdown digest at digests/YYYY-MM-DD.md

The workflow YAML opens a draft PR with that file.

Required env vars:
  ANTHROPIC_API_KEY               (required)
  BRIGHTDATA_API_TOKEN            (optional — enables Bright Data SERP/unlocker)
  BRIGHTDATA_SERP_ZONE            (optional — Bright Data zone for SERP)
  BRIGHTDATA_UNLOCKER_ZONE        (optional — Bright Data zone for fetching)
  MIN_CANDIDATES                  (default 10)
  MAX_CANDIDATES                  (default 20)
"""

from __future__ import annotations

import datetime as _dt
import json
import os
import re
import sys
import time
import urllib.parse
import urllib.request
from pathlib import Path
from typing import Any

import requests
from anthropic import Anthropic

# ─── Config ───────────────────────────────────────────────────────────────
SUPABASE_URL = "https://dshrbbnjahjcwxzvzygh.supabase.co"
# Anon key is intentionally public — same key the static frontend uses
SUPABASE_ANON_KEY = (
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9."
    "eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRzaHJiYm5qYWhqY3d4enZ6eWdoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg0ODE3OTgsImV4cCI6MjA5NDA1Nzc5OH0."
    "OpUGgfL91m7STsZpE6fnX281KN_Ge8oytR-2lM-3qTo"
)

MIN_CANDIDATES = int(os.environ.get("MIN_CANDIDATES", "10"))
MAX_CANDIDATES = int(os.environ.get("MAX_CANDIDATES", "20"))

BRIGHTDATA_TOKEN = os.environ.get("BRIGHTDATA_API_TOKEN", "").strip()
BRIGHTDATA_SERP_ZONE = os.environ.get("BRIGHTDATA_SERP_ZONE", "").strip()
BRIGHTDATA_UNLOCKER_ZONE = os.environ.get("BRIGHTDATA_UNLOCKER_ZONE", "").strip()

USE_BRIGHTDATA = bool(BRIGHTDATA_TOKEN and BRIGHTDATA_SERP_ZONE)

ANTHROPIC_API_KEY = os.environ.get("ANTHROPIC_API_KEY", "").strip()
if not ANTHROPIC_API_KEY:
    print("::error::ANTHROPIC_API_KEY not set", file=sys.stderr)
    sys.exit(1)

CLAUDE_MODEL = os.environ.get("CLAUDE_MODEL", "claude-sonnet-4-6")

# Sources to crawl — order by signal strength
SOURCES: list[tuple[str, str]] = [
    # Saudi government
    ("MISA",       "site:misa.gov.sa OR \"Ministry of Investment Saudi Arabia\" new program 2025 2026"),
    ("Monsha'at",  "site:monshaat.gov.sa OR Monsha'at new SME programme launch 2025 2026"),
    ("RDIA",       "site:rdia.gov.sa OR \"Research Development and Innovation Authority\" new call 2025 2026"),
    ("KAUST",      "site:kaust.edu.sa OR \"KAUST Innovation\" new program 2025 2026"),
    ("KACST",      "site:kacst.edu.sa new programme 2025 2026"),
    ("PIF",        "site:pif.gov.sa OR \"Public Investment Fund\" new fund 2025 2026"),
    ("SVC",        "site:svc.com.sa OR \"Saudi Venture Capital\" new fund 2025 2026"),
    ("Misk",       "site:misk.org.sa OR \"Misk Foundation\" new programme 2025 2026"),
    ("CST",        "site:cst.gov.sa new programme 2025 2026"),
    ("SSA",        "site:ssa.gov.sa OR \"Saudi Space Agency\" new programme 2025 2026"),
    ("NEOM",       "site:neom.com OR NEOM new fund 2025 2026"),
    ("Wa'ed",      "\"Wa'ed Ventures\" OR \"Aramco Ventures\" new fund 2025 2026"),
    # GCC
    ("Hub71",      "site:hub71.com new cohort 2025 2026"),
    ("ADGM",       "site:adgm.com new programme 2025 2026"),
    ("QSTP",       "\"Qatar Science Technology Park\" new programme 2025 2026"),
    ("Tamkeen",    "\"Tamkeen Bahrain\" new programme 2025 2026"),
    # Global
    ("WorldBank",  "\"World Bank\" Saudi Arabia new programme 2025 2026"),
    ("EUHorizon",  "\"Horizon Europe\" Saudi Arabia OR GCC new call 2025 2026"),
    ("UNDP",       "UNDP Saudi Arabia OR GCC new programme 2025 2026"),
    # Press / aggregators
    ("Wamda",      "site:wamda.com Saudi new fund 2025 2026"),
    ("Magnitt",    "site:magnitt.com Saudi new fund 2025 2026"),
    ("Zawya",      "site:zawya.com Saudi new programme 2025 2026"),
]


# ─── Supabase: dedup baseline ─────────────────────────────────────────────
def fetch_existing_opportunities() -> list[dict[str, Any]]:
    """Pull (id, title, sponsor_institution) for every record in Supabase."""
    rows: list[dict[str, Any]] = []
    page_size = 1000
    offset = 0
    while True:
        url = (
            f"{SUPABASE_URL}/rest/v1/opportunities"
            f"?select=id,title,sponsor_institution&order=id.asc"
            f"&limit={page_size}&offset={offset}"
        )
        req = urllib.request.Request(
            url,
            headers={
                "apikey": SUPABASE_ANON_KEY,
                "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
            },
        )
        with urllib.request.urlopen(req, timeout=30) as resp:
            batch = json.loads(resp.read())
        rows.extend(batch)
        if len(batch) < page_size:
            break
        offset += page_size
        if offset > 50_000:
            break
    return rows


# ─── Bright Data SERP (optional) ──────────────────────────────────────────
def brightdata_serp(query: str, n: int = 10) -> list[dict[str, str]]:
    """
    Query Bright Data SERP API.

    Bright Data exposes search via their unified /request endpoint with
    a SERP zone configured for `search_engine=google` (or bing). The
    response includes the raw HTML; we extract organic result rows.

    If the call fails for any reason we return an empty list — the caller
    will fall back to Claude's native web_search tool.
    """
    if not USE_BRIGHTDATA:
        return []
    try:
        payload = {
            "zone": BRIGHTDATA_SERP_ZONE,
            "url": f"https://www.google.com/search?q={urllib.parse.quote_plus(query)}&hl=en&num={n}&brd_json=1",
            "format": "raw",
        }
        r = requests.post(
            "https://api.brightdata.com/request",
            headers={
                "Authorization": f"Bearer {BRIGHTDATA_TOKEN}",
                "Content-Type": "application/json",
            },
            data=json.dumps(payload),
            timeout=60,
        )
        if r.status_code != 200:
            print(f"[brightdata] SERP {r.status_code}: {r.text[:200]}", file=sys.stderr)
            return []
        # When brd_json=1 is requested, Bright Data returns JSON; otherwise HTML.
        try:
            data = r.json()
        except ValueError:
            return []
        organic = (data.get("organic") or data.get("results") or [])[:n]
        out: list[dict[str, str]] = []
        for item in organic:
            link = item.get("link") or item.get("url") or ""
            if not link:
                continue
            out.append({
                "title": (item.get("title") or "")[:240],
                "url": link,
                "snippet": (item.get("description") or item.get("snippet") or "")[:600],
            })
        return out
    except Exception as e:  # noqa: BLE001
        print(f"[brightdata] SERP exception: {e}", file=sys.stderr)
        return []


def brightdata_fetch(url: str) -> str:
    """
    Fetch a URL through Bright Data Web Unlocker. Returns plain text/HTML,
    or '' on failure. Caller should fall back to plain requests.get if empty.
    """
    if not USE_BRIGHTDATA or not BRIGHTDATA_UNLOCKER_ZONE:
        return ""
    try:
        payload = {
            "zone": BRIGHTDATA_UNLOCKER_ZONE,
            "url": url,
            "format": "raw",
        }
        r = requests.post(
            "https://api.brightdata.com/request",
            headers={
                "Authorization": f"Bearer {BRIGHTDATA_TOKEN}",
                "Content-Type": "application/json",
            },
            data=json.dumps(payload),
            timeout=60,
        )
        if r.status_code != 200:
            print(f"[brightdata] fetch {r.status_code}: {r.text[:160]}", file=sys.stderr)
            return ""
        return r.text[:60_000]
    except Exception as e:  # noqa: BLE001
        print(f"[brightdata] fetch exception: {e}", file=sys.stderr)
        return ""


# ─── Plain HTTP fetch (fallback) ──────────────────────────────────────────
def plain_fetch(url: str) -> str:
    try:
        r = requests.get(
            url,
            headers={"User-Agent": "Mozilla/5.0 (compatible; SaudiHubBot/1.0)"},
            timeout=20,
        )
        if r.status_code != 200:
            return ""
        return r.text[:60_000]
    except Exception as e:  # noqa: BLE001
        print(f"[plain_fetch] {url}: {e}", file=sys.stderr)
        return ""


# ─── 3-layer verification prompt ──────────────────────────────────────────
SYSTEM_PROMPT = """You are a research agent for the Saudi Opportunity Hub platform. Your job is to find NEW investment, funding, grant, accelerator, tender, and partnership opportunities relevant to Saudi Arabia, GCC countries, and global programs targeting the region.

You must run every candidate opportunity through 3 strict verification layers before it can be added.

---

## PLATFORM CONTEXT
- Existing database: 4,000+ opportunities already in Supabase (titles listed in the user message)
- Sectors covered: Innovation, ICT, Financial, Industrial, Healthcare, Environment, Energy, Real Estate, Education, Transport, Pharma, Chemicals, Agriculture, Tourism, Mining, Media
- Target audience: Startups, SMEs, investors, researchers, government entities in Saudi Arabia and GCC
- Types accepted: grants, tenders, accelerators, investment programs, fellowships, ecosystem initiatives

---

## LAYER 1 — EXISTENCE CHECK (No hallucinations)
For each candidate opportunity you find, you MUST:
1. Provide a real, working URL that links directly to the official program page
2. Confirm the sponsor/issuer is a real, verifiable organization (government body, fund, corporation, or institution)
3. Confirm the opportunity was announced or active within the last 24 months
4. If no working URL can be found → REJECT immediately, do not proceed to Layer 2

REJECT if: URL is dead, redirects to a homepage, or leads to a generic search result.

---

## LAYER 2 — DUPLICATE CHECK (No repeats)
Compare each candidate against the existing database titles provided in the user message. REJECT if:
- The title is the same or near-identical (even if slightly reworded)
- It is the same program from the same sponsor even with a different cohort year (unless it's a clearly new cycle with new terms/deadline)
- The URL domain and program name match any existing entry

Only pass candidates that are genuinely new and not already in the database.

---

## LAYER 3 — QUALITY & RELEVANCE CHECK (Right fit)
Each opportunity must pass ALL of the following:
1. GEOGRAPHY: Must be based in Saudi Arabia, GCC, MENA, or explicitly open to Saudi/GCC applicants
2. RELEVANCE: Must align with at least one of the 16 platform sectors
3. LEGITIMACY: Sponsor must be a recognized institution (no obscure blogs, no unverifiable sources)
4. ACTIONABILITY: Must have a clear way to apply, register, or engage (application link, contact, deadline, or rolling basis)
5. NOT EXPIRED: Deadline must be in the future OR it must be a rolling/recurring program

REJECT if any single criterion fails.

---

## OUTPUT FORMAT

Output ONE valid JSON document with exactly this structure:

```json
{
  "candidates": [
    {
      "title": "...",
      "sponsor": "...",
      "type": "grant | tender | accelerator | investment program | fellowship | other",
      "sector": ["..."],
      "country": "...",
      "region": "Saudi Arabia | GCC | MENA | Global",
      "status": "open | recurring | closed_but_recurring",
      "deadline": "YYYY-MM-DD or null",
      "funding_amount": "...",
      "description": "2–3 sentence summary",
      "url": "https://...",
      "verified_url": true,
      "passed_layer_1": true,
      "passed_layer_2": true,
      "passed_layer_3": true
    }
  ],
  "rejected": [
    { "title": "...", "layer": 1, "reason": "..." }
  ],
  "summary": {
    "candidates_found": 0,
    "rejected_l1": 0,
    "rejected_l2": 0,
    "rejected_l3": 0,
    "coverage_window": "Jan 2025 — present",
    "skipped_sources": [],
    "caveats": []
  }
}
```

Wrap the entire JSON in a single ```json fenced block. NO prose before or after. Aim for the minimum number of candidates listed in the user message; cap at the maximum."""


def build_user_message(
    existing: list[dict[str, Any]],
    search_hits: list[dict[str, Any]],
) -> str:
    """Compose the per-run user message with dedup context + search hits."""
    # Cap dedup context to keep token cost reasonable
    titles = [
        f"- {o.get('title','?')} — {o.get('sponsor_institution','?')}"
        for o in existing
        if o.get("title")
    ]
    # Sample uniformly if we exceed budget
    cap = 600
    if len(titles) > cap:
        step = len(titles) / cap
        titles = [titles[int(i * step)] for i in range(cap)]
    dedup = "\n".join(titles)

    hits_block = ""
    if search_hits:
        hits_block = (
            "\n\nSEARCH RESULTS (already retrieved for you — use these as your starting "
            "set, fetch each URL to verify and extract details before classifying):\n"
        )
        for h in search_hits[:80]:
            hits_block += f"- [{h.get('source','?')}] {h.get('title','')} → {h.get('url','')}\n   {h.get('snippet','')}\n"

    return f"""Find new funding/investment/grant/accelerator/tender/partnership opportunities for the Saudi Opportunity Hub.

Minimum target: {MIN_CANDIDATES} verified candidates.
Maximum: {MAX_CANDIDATES} (do not pad).

EXISTING DATABASE TITLES (for Layer 2 dedup; sample of {len(titles)}):
{dedup}
{hits_block}

Run each candidate through the 3-layer verification. Use the web_search and web_fetch tools to confirm URLs are live and grab program details. Output the single JSON document described in the system prompt — no prose around it."""


# ─── Run Claude with web tools ────────────────────────────────────────────
def run_claude(existing: list[dict[str, Any]], search_hits: list[dict[str, Any]]) -> str:
    client = Anthropic(api_key=ANTHROPIC_API_KEY)

    user_msg = build_user_message(existing, search_hits)

    # If we have no pre-loaded SERP hits, give Claude the web_search tool so
    # it can find candidates itself. With pre-loaded hits we can also enable
    # web_search to dig deeper — it's cheap.
    tools: list[dict[str, Any]] = [
        # Claude's native web search (works without Bright Data). See:
        # https://docs.anthropic.com/en/docs/build-with-claude/tool-use/web-search-tool
        {"type": "web_search_20250305", "name": "web_search"},
    ]

    print(f"[claude] model={CLAUDE_MODEL}, existing={len(existing)}, "
          f"preloaded_hits={len(search_hits)}, using_brightdata={USE_BRIGHTDATA}")

    response = client.messages.create(
        model=CLAUDE_MODEL,
        max_tokens=16_000,
        system=SYSTEM_PROMPT,
        tools=tools,
        messages=[{"role": "user", "content": user_msg}],
    )

    print(f"[claude] stop_reason={response.stop_reason}, "
          f"input_tokens={response.usage.input_tokens}, "
          f"output_tokens={response.usage.output_tokens}")

    # Concatenate text blocks
    parts: list[str] = []
    for block in response.content:
        if getattr(block, "type", None) == "text":
            parts.append(block.text)
    return "\n".join(parts).strip()


# ─── Markdown digest writer ───────────────────────────────────────────────
def parse_json_from_response(raw: str) -> dict[str, Any]:
    """Extract the JSON document Claude returned. Best-effort."""
    # Find a ```json fenced block first
    m = re.search(r"```json\s*(\{.*?\})\s*```", raw, re.DOTALL)
    if m:
        candidate = m.group(1)
    else:
        # Fallback: first top-level { ... } block
        start = raw.find("{")
        if start < 0:
            return {}
        depth = 0
        end = -1
        for i, ch in enumerate(raw[start:], start=start):
            if ch == "{":
                depth += 1
            elif ch == "}":
                depth -= 1
                if depth == 0:
                    end = i + 1
                    break
        if end < 0:
            return {}
        candidate = raw[start:end]
    try:
        return json.loads(candidate)
    except json.JSONDecodeError as e:
        print(f"[parse] JSON decode failed at pos {e.pos}: {e.msg}", file=sys.stderr)
        return {}


def write_digest(today: str, raw_response: str, parsed: dict[str, Any]) -> Path:
    Path("digests").mkdir(parents=True, exist_ok=True)
    out = Path(f"digests/{today}.md")

    candidates: list[dict[str, Any]] = parsed.get("candidates") or []
    rejected: list[dict[str, Any]] = parsed.get("rejected") or []
    summary: dict[str, Any] = parsed.get("summary") or {}

    lines: list[str] = []
    lines.append(f"# Weekly opportunity digest — {today}")
    lines.append("")
    lines.append(
        f"Automated research run. **{len(candidates)} candidate(s)** found, "
        f"**{len(rejected)} rejected**."
    )
    lines.append("")

    if summary:
        lines.append("## Summary")
        for k in (
            "candidates_found", "rejected_l1", "rejected_l2", "rejected_l3",
            "coverage_window",
        ):
            if k in summary:
                lines.append(f"- **{k.replace('_', ' ')}:** {summary[k]}")
        if summary.get("skipped_sources"):
            lines.append(f"- **skipped sources:** {', '.join(summary['skipped_sources'])}")
        if summary.get("caveats"):
            for c in summary["caveats"]:
                lines.append(f"- _Caveat:_ {c}")
        lines.append("")

    if candidates:
        lines.append("## Candidates (passed all 3 layers)")
        lines.append("")
        # Headline table
        lines.append("| # | Title | Sponsor | Type | Region | Deadline | Match link |")
        lines.append("|---|---|---|---|---|---|---|")
        for i, c in enumerate(candidates, 1):
            title = (c.get("title") or "").replace("|", "\\|")
            sponsor = (c.get("sponsor") or "").replace("|", "\\|")
            lines.append(
                f"| {i} | {title} | {sponsor} | {c.get('type','?')} | "
                f"{c.get('region','?')} | {c.get('deadline') or '—'} | "
                f"[link]({c.get('url','')}) |"
            )
        lines.append("")
        # Full per-candidate detail
        for i, c in enumerate(candidates, 1):
            lines.append(f"### {i}. {c.get('title','Untitled')}")
            lines.append("")
            lines.append(f"- **Sponsor:** {c.get('sponsor','?')}")
            lines.append(f"- **Type:** {c.get('type','?')}")
            lines.append(f"- **Sectors:** {', '.join(c.get('sector') or [])}")
            lines.append(f"- **Country / Region:** {c.get('country','?')} · {c.get('region','?')}")
            lines.append(f"- **Status:** {c.get('status','?')}")
            lines.append(f"- **Deadline:** {c.get('deadline') or '—'}")
            lines.append(f"- **Funding:** {c.get('funding_amount','?')}")
            lines.append(f"- **URL:** <{c.get('url','')}>")
            lines.append("")
            lines.append(f"{c.get('description','')}")
            lines.append("")
        lines.append("")
        # JSON for easy paste into Supabase ingestion
        lines.append("### Raw JSON (for ingestion)")
        lines.append("")
        lines.append("```json")
        lines.append(json.dumps(candidates, indent=2, ensure_ascii=False))
        lines.append("```")
        lines.append("")

    if rejected:
        lines.append("## Rejections")
        lines.append("")
        for r in rejected[:60]:
            lines.append(
                f"- **L{r.get('layer','?')}** — {r.get('title','?')}: {r.get('reason','')}"
            )
        lines.append("")

    # Always include the raw response as a folded debug section
    lines.append("<details><summary>Raw model response (debug)</summary>")
    lines.append("")
    lines.append("```")
    lines.append(raw_response[:30_000])
    lines.append("```")
    lines.append("")
    lines.append("</details>")
    lines.append("")

    out.write_text("\n".join(lines), encoding="utf-8")
    print(f"[digest] wrote {out} — {len(candidates)} candidates, {len(rejected)} rejections")
    return out


# ─── Entry point ──────────────────────────────────────────────────────────
def main() -> None:
    today = _dt.date.today().isoformat()
    print(f"[run] {today} — Bright Data: {'ON' if USE_BRIGHTDATA else 'off (using native web_search)'}")

    # Step 0: dedup baseline
    try:
        existing = fetch_existing_opportunities()
        print(f"[supabase] loaded {len(existing)} existing rows for dedup")
    except Exception as e:  # noqa: BLE001
        print(f"::warning::Supabase dedup fetch failed: {e}", file=sys.stderr)
        existing = []

    # Step 1: optional Bright Data SERP — gives Claude a strong starting set
    search_hits: list[dict[str, Any]] = []
    if USE_BRIGHTDATA:
        for source, query in SOURCES:
            results = brightdata_serp(query, n=8)
            for r in results:
                r["source"] = source
            search_hits.extend(results)
            time.sleep(0.5)
        print(f"[brightdata] collected {len(search_hits)} SERP hits across {len(SOURCES)} sources")

    # Step 2: send to Claude with 3-layer prompt
    try:
        raw = run_claude(existing, search_hits)
    except Exception as e:  # noqa: BLE001
        print(f"::error::Claude call failed: {e}", file=sys.stderr)
        sys.exit(2)

    parsed = parse_json_from_response(raw)

    # Step 3: write digest
    write_digest(today, raw, parsed)
    print("[run] done")


if __name__ == "__main__":
    main()
