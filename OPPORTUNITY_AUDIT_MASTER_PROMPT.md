# Opportunity Audit — Master Prompt

A reusable, parameterised prompt for validating **every** opportunity in the
Saudi Opportunity Hub against its real source page, using cheap (Haiku)
subagents that actually visit each site. Drives: deadline accuracy,
description accuracy, correct country, dead/404 link detection, and
duplicate detection — with safe, audited writes.

**Two ways to run**
1. Paste the **PROMPT** section below into a Claude Code session (Opus/Sonnet
   as orchestrator). It will fan out cheap subagents and apply the policy.
2. Run the companion workflow `scripts/opportunity-audit.workflow.js` via the
   `Workflow` tool (same logic, deterministic fan-out). It implements this
   prompt step-for-step.

> **Link-checking dependency.** Accurate 404 detection on Saudi/GCC government
> and global grant portals needs a real browser/scraper — many block plain
> bots. Preferred: **Bright Data MCP** (`scrape`/`search`) for liveness + HTTP
> status, **WebFetch** as fallback. If Bright Data is **not connected**, the run
> falls back to WebFetch only; in that mode a failed load is *ambiguous*
> (real 404 vs bot-block), so **dead-link findings must be QUEUED, never
> auto-applied** (see Apply Policy).

---

## CONFIG (edit before running)

```
PROJECT_ID        = dshrbbnjahjcwxzvzygh        # Supabase project
TABLE             = public.opportunities         # source of truth (rows)
QUEUE_TABLE       = public.opportunities_review   # proposals land here (admin panel reads it)
ARCHIVE_TABLE     = public.opportunities_archive   # duplicates go here (never DELETE)
SCOPE             = status <> 'archived'          # which rows to audit
CHECKER_MODEL     = haiku                          # "cheap subagents" for per-row web checks
VERIFIER_MODEL    = haiku                          # adversarial re-check of flagged rows
REASONER_MODEL    = sonnet                          # dedup clustering + synthesis
BATCH_SIZE        = 20                              # rows per checker subagent (keeps agent count < 1000)
CONCURRENCY       = 12                              # parallel subagents
LINK_TOOL         = bright_data -> webfetch         # primary -> fallback
APPLY_MODE        = auto_high_confidence_else_queue  # see Apply Policy
RECHECK_WINDOW_D  = 14                              # skip rows whose last_verified is within N days (idempotent re-runs)
SAMPLE_LIMIT      = none                            # set to e.g. 25 for a pilot
```

---

## HARD RULES (non-negotiable — these protect the live data)

1. **No fabrication.** Only write a value you can quote from the source page.
   If a field can't be confirmed, use an honest fallback (`Rolling`, `TBC`,
   `Closed`) or leave it and QUEUE — never guess, never invent a deadline/URL.
2. **Never hard-delete.** Duplicates are *archived* into `ARCHIVE_TABLE` with a
   `reason` and the `kept_id` of the canonical row. Archiving is reversible.
3. **Duplicate definition is strict.** Same title alone is **not** a duplicate.
   Sharing a sponsor portal/domain is **not** a duplicate. A duplicate is the
   *same program/intake* — corroborated by ≥2 of: normalised title match,
   same sponsor, same application URL (or same canonical program page),
   overlapping deadline. When two rows are a true dup, the **structured id**
   (`SA-…`, `GCC-…`, `GL-…`) is canonical over a bare UUID; otherwise keep the
   one with the richer/verified record and archive the other.
4. **Country vs eligibility are different.** `country` = where the
   sponsor/program is based; `eligibility_region` = who can apply. The id
   prefix is a strong signal (`SA-`→Saudi, `GCC-`→GCC, `GL-`→Global). Don't
   "correct" a global program to Saudi just because it's KSA-eligible.
5. **Every change carries evidence.** A finding is only valid with a quoted
   snippet from the page **and** the source URL it came from.
6. **Confidence gate + adversarial check.** No auto-apply without (a) high
   confidence and (b) a second independent subagent that *tried to refute the
   change* and failed.
7. **Idempotent.** Skip rows whose `last_verified` is within `RECHECK_WINDOW_D`.
   Re-running must not create duplicate queue rows (upsert on id+reason).
8. **Never silently drop work.** A row whose page wouldn't load after retries
   is reported as `unchecked`, not treated as dead and not silently skipped.
9. **Content fields are queued, not auto-written.** `description_short`,
   `country`, `deadline_date`, `funding_amount`, `title` are only changed via
   the review queue (a human approves), regardless of confidence.

---

## THE FIVE CHECKS (per opportunity)

For each row, visit `application_link` (via `LINK_TOOL`) and assess:

**1 — Link liveness / 404.** Classify as `live` | `dead` (404/410/NXDOMAIN/parked)
| `redirected_generic` (lands on a homepage/search, program gone) |
`blocked_or_unknown` (bot-wall, timeout — only when the tool can't confirm).
Require **two independent fetch attempts** before `dead`. With WebFetch-only,
`dead` is downgraded to `blocked_or_unknown` unless the response is an
unambiguous 404 body.

**2 — Deadline.** Find the program's stated deadline on the page. If it differs
from `deadline_date` → propose the page value. If the page shows the deadline
has passed / intake closed → propose `status` change (e.g. `closed`,
`closed_but_recurring`) rather than inventing a new date. If the program is
genuinely always-open and the row has a bogus date → propose `Rolling`. No
date on the page and none defensible → `TBC` (queue).

**3 — Description.** Does `description_short` accurately describe the program on
the page? Flag if wrong program, materially outdated, or empty. Suggested
rewrite must be ≤300 chars, factual, drawn from the page — **queued**.

**4 — Country.** Determine the sponsor/program home country from the page.
Compare to `country` (+ sanity-check `eligibility_region` and the id prefix).
Flag genuine mismatches (e.g. country says "UAE" but it's a Saudi PIF program).
Respect rule #4 — don't conflate eligibility with location.

**5 — Duplicates.** Emit a normalised dedup key for the row
(`lower(trim(title))` minus punctuation/years + sponsor + registrable domain of
`application_link`). After all rows are keyed, cluster collisions and apply
rule #3 to decide canonical vs archive.

Each per-row result is structured:
```json
{ "id": "...", "checks": {
    "link":   {"verdict":"live|dead|redirected_generic|blocked_or_unknown","evidence":"...","source_url":"...","confidence":0.0},
    "deadline":{"ok":true,"current":"...","suggested":null,"evidence":"...","confidence":0.0},
    "description":{"ok":true,"suggested":null,"evidence":"...","confidence":0.0},
    "country": {"ok":true,"current":"...","suggested":null,"evidence":"...","confidence":0.0}
  },
  "dedup_key":"...", "domain":"...", "sponsor":"...",
  "unchecked": false
}
```

---

## ORCHESTRATION (cheap subagents, batched)

1. **Discover** — count rows in scope (`SELECT count(*) … WHERE SCOPE`). Compute
   `N = ceil(count / BATCH_SIZE)` batches.
2. **Verify (pipeline, CHECKER_MODEL)** — one subagent per batch. The agent
   reads its slice with `execute_sql … ORDER BY id LIMIT BATCH_SIZE OFFSET
   batch*BATCH_SIZE`, runs the five checks (web visits via LINK_TOOL), returns
   the structured results. Batched so total agents stay well under the 1000 cap;
   concurrency-capped so we don't hammer sites.
3. **Cross-check (VERIFIER_MODEL)** — for every row with a "needs change"
   finding, a second subagent independently re-verifies, prompted to **refute**
   the change. Survives only if it can't.
4. **Dedup (REASONER_MODEL)** — aggregate all `dedup_key`s, cluster collisions,
   apply rule #3, output {canonical_id, archive_ids[], reason} per cluster.
5. **Apply / Queue** — per Apply Policy below.
6. **Synthesize** — write CSV audit files + a markdown summary; report counts
   (changed / queued / archived / dead / unchecked) with sample evidence.

---

## APPLY POLICY (`APPLY_MODE = auto_high_confidence_else_queue`)

**Auto-apply (high-confidence, reversible, audited) — ONLY these:**
- **Exact duplicates** → insert loser into `ARCHIVE_TABLE` (with `reason`,
  `kept_id`), set its `status='archived'`. Does not need the web; safest write.
- **Confirmed-dead link** → only when `LINK_TOOL` can return a real HTTP status
  (i.e. Bright Data connected) AND two attempts agree AND the verifier concurs:
  set `review_status`/note + `last_verified=today`. (Does **not** delete the
  link or the row.) Under WebFetch-only this is **queued**, not applied.
- **Stamp** `last_verified=today` on rows that passed all checks clean.

**Queue to `QUEUE_TABLE` (human approves in the admin panel) — everything else:**
- Any `description`, `country`, `deadline_date`, `funding` correction.
- `status` changes from a "deadline passed/closed" reading.
- Anything below high confidence, or where the page was `blocked_or_unknown`.
- Write with `review_reason` (which check + why), `review_confidence`,
  `source_url`, `candidate_origin='audit'`. Upsert so re-runs don't duplicate.

**Never:** hard-delete; overwrite a non-empty content field automatically;
change `title`; act on a page that failed to load; write a value you can't
quote.

---

## OUTPUTS

- `QUEUE_TABLE` rows for every proposed content/status fix (admin-reviewable).
- `ARCHIVE_TABLE` rows for de-duplicated opportunities (reason + kept_id).
- CSV audits at repo root (mirrors existing convention, e.g.
  `audit_links_dead_<date>.csv`, `audit_dedup_<date>.csv`,
  `audit_country_mismatch_<date>.csv`, `audit_deadline_<date>.csv`,
  `audit_unchecked_<date>.csv`).
- A markdown summary: totals per category, % auto-applied vs queued, the
  `unchecked` count (and why), and 5–10 worked examples with evidence.
```
```
