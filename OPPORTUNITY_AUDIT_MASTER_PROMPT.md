# Opportunity Audit — Autonomous Master Prompt

Paste this into Claude Code in your terminal. It runs **fully autonomously** —
the lead agent fans out **cheap (Haiku) subagents** that visit each
opportunity's real source page, then **fixes problems directly in the database**
with no check-ins. It validates deadlines, descriptions, country, dead/404
links, and duplicates; updates outdated descriptions; and removes opportunities
that are genuinely gone.

---

## Run it in your terminal

Prerequisites (already configured for this project): the **Supabase MCP** and
the **WebFetch/WebSearch** tools. Optional but recommended: **Bright Data MCP**
for reliable HTTP status on bot-blocked government portals.

```bash
# Fully hands-off (no permission prompts). Run from the repo root.
claude --permission-mode bypassPermissions -p "Execute the audit defined in ./OPPORTUNITY_AUDIT_MASTER_PROMPT.md autonomously. Do not ask me anything; fix everything you can, archive what is genuinely dead or duplicated, update outdated descriptions, then print a final summary."
```

Interactive alternative:
```bash
claude --permission-mode bypassPermissions
# then paste:  Execute ./OPPORTUNITY_AUDIT_MASTER_PROMPT.md autonomously and report only at the end.
```

Deterministic engine (same logic, recommended for the full 5k):
```bash
claude --permission-mode bypassPermissions -p "Run the workflow at scripts/opportunity-audit.workflow.js"
# pilot first:  ...args { sampleLimit: 25 }
```

> The lead agent must **never stop to ask the user**. Make every decision with
> the rules below, act, and report once at the end.

---

## CONFIG

```
PROJECT_ID        = dshrbbnjahjcwxzvzygh
TABLE             = public.opportunities          # live rows (source of truth)
ARCHIVE_TABLE     = public.opportunities_archive   # "deleted" rows land here (reversible)
SCOPE             = status <> 'archived'
CHECKER_MODEL     = haiku        # cheap subagents do the per-row web checks
VERIFIER_MODEL    = haiku        # adversarial re-check before any destructive/content change
REASONER_MODEL    = sonnet       # dedup clustering + final synthesis
BATCH_SIZE        = 20           # rows per subagent
CONCURRENCY       = 12
LINK_TOOL         = bright_data -> webfetch (+ websearch to corroborate)
APPLY_MODE        = autonomous   # fix + delete directly, NO human queue, NO check-ins
DELETE_MODE       = archive      # "delete" = archive (reversible). Set HARD_DELETE=true for real DELETE.
HARD_DELETE       = false
RECHECK_WINDOW_D  = 14           # skip rows verified within N days (idempotent re-runs)
SAMPLE_LIMIT      = none         # set to e.g. 25 for a pilot
```

---

## HARD RULES (these keep autonomous changes safe)

1. **Act, don't ask.** Never return to the user mid-run. Resolve every case with
   these rules and proceed. Report once, at the end.
2. **No fabrication.** Only write a value you can quote from the source page (or
   a corroborating authoritative page found via WebSearch). If a field can't be
   confirmed, use an honest fallback (`Rolling`, `TBC`, `Closed`) — never invent
   a date, URL, or fact. Updating a stale description to the page's *current*
   wording is required and is NOT fabrication; inventing one is.
3. **"Delete" = archive (reversible).** A removed row is INSERTed into
   `ARCHIVE_TABLE` (with `review_reason` + `kept_id` when it's a duplicate) and
   its `status` set to `'archived'`, so it disappears from the live site
   everywhere. Only if `HARD_DELETE=true` do you `DELETE FROM`. Never lose data
   on a guess.
4. **Deletion needs strong corroboration — never delete on ambiguity.** Remove an
   opportunity ONLY when it is genuinely gone, proven by BOTH: (a) the link is
   truly dead (404/410/NXDOMAIN/parked) on **two independent fetches**, AND
   (b) a **WebSearch** for the program+sponsor finds no live equivalent (if it
   finds the program at a new URL, that's a LINK FIX, not a delete) OR an
   authoritative source states it's discontinued. A bot-block / timeout /
   "blocked_or_unknown" is **never** grounds to delete — fix nothing, flag it,
   move on. Never delete an `unchecked` row.
5. **Prefer fixing over deleting.** Dead URL but program still exists → update
   the URL. Wrong deadline → update it (or set status closed/Rolling). Outdated
   description → rewrite from the page (≤300 chars, factual). Wrong country →
   correct it. Delete only when the opportunity itself no longer exists.
6. **Duplicate definition is strict.** Same title alone is not a duplicate;
   shared portal domain is not a duplicate. Require ≥2 of: normalised-title
   match, same sponsor, same application URL/canonical program page, overlapping
   deadline. Keep the canonical row (structured id `SA-/GCC-/GL-` beats a bare
   UUID; else the richer/verified record), archive the rest with `kept_id`.
7. **Country ≠ eligibility.** `country` = sponsor/program home; the id prefix is
   a strong signal. Don't relocate a global program to Saudi just because it's
   KSA-eligible.
8. **Evidence + adversarial gate.** Every content change or deletion needs a
   quoted snippet + source URL, AND a second subagent that tried to **refute**
   the change and failed. No solo destructive actions.
9. **Idempotent + audited.** Skip rows `last_verified` within `RECHECK_WINDOW_D`.
   Stamp `last_verified=today` on every row you touch or clear. Append every
   change/deletion to a CSV audit log (see Outputs) so the run is fully traceable
   even though there's no human queue.

---

## THE FIVE CHECKS (per opportunity)

Visit `application_link` via `LINK_TOOL` (Bright Data if available, else WebFetch;
use WebSearch to corroborate/relocate). For each row assess:

1. **Link** — `live | dead | redirected_generic | blocked_or_unknown`. Two
   independent attempts before `dead`. WebFetch-only + won't load → `blocked_or_unknown`.
2. **Deadline** — page's stated deadline vs `deadline_date`. Passed/closed →
   status change, not an invented date. Always-open → `Rolling`. None → `TBC`.
3. **Description** — does `description_short` match the program on the page?
   If wrong/outdated → rewrite from the page (factual, ≤300 chars).
4. **Country** — sponsor/program home country from the page vs `country`
   (sanity-check `eligibility_region` + id prefix). Fix genuine mismatches.
5. **Duplicates** — emit a normalised dedup key (`lower(trim(title))` minus
   punctuation/years + sponsor + registrable domain). Cluster after the sweep.

---

## AUTONOMOUS APPLY POLICY (`APPLY_MODE = autonomous`)

After the adversarial verifier confirms a finding, **apply it directly** to
`TABLE` — no queue, no approval:

- **Fix** `deadline_date`, `status`, `description_short`, `country`,
  `application_link`, `funding_*` when confidently sourced (rule #2, #5, #8).
- **Archive duplicates** (losers) with `kept_id` + reason; keep canonical.
- **Delete (=archive)** opportunities that are genuinely gone per rule #4.
- **Stamp** `last_verified=today` on every row you fix or clear.
- **Skip** ambiguous/blocked rows — log them as `unchecked`, change nothing.

Write changes in batches via the Supabase MCP `execute_sql`. Keep destructive
ops reversible (archive) unless `HARD_DELETE=true`.

---

## ORCHESTRATION (cheap subagents, autonomous)

1. **Discover** — `SELECT count(*) … WHERE SCOPE`; compute `N = ceil(count/BATCH_SIZE)`.
2. **Verify** — fan out `CHECKER_MODEL` subagents (concurrency `CONCURRENCY`),
   one per batch. Each reads its slice (`execute_sql … ORDER BY id LIMIT
   BATCH_SIZE OFFSET batch*BATCH_SIZE`), runs the five checks via the web, and
   returns structured findings + a dedup key per row.
3. **Cross-check** — `VERIFIER_MODEL` subagent re-verifies every proposed
   change/deletion, prompted to refute it. Survives only if irrefutable.
4. **Dedup** — `REASONER_MODEL` clusters key-collisions, picks canonical.
5. **Apply** — execute fixes + archives directly (Apply Policy). Reversible.
6. **Report** — write the audit CSVs + markdown summary; print final counts.

Run total agents under the 1000 cap (batching keeps it ~260 + verifiers). The
committed workflow `scripts/opportunity-audit.workflow.js` implements all of
this deterministically — prefer it for the full run.

---

## OUTPUTS (audit trail, written automatically — not a human queue)

- Direct edits/archives applied to `TABLE` / `ARCHIVE_TABLE`.
- CSV logs at repo root: `audit_fixed_<date>.csv` (every field change: id, field,
  old, new, evidence, source_url), `audit_deleted_<date>.csv` (id, reason,
  evidence, source_url), `audit_dedup_<date>.csv` (kept_id, archived_ids,
  reason), `audit_unchecked_<date>.csv` (id, why).
- `audit_opportunity_run.md`: totals (fixed / archived / deleted / unchecked),
  the unchecked count and why, and 5–10 worked examples with evidence.
- A final printed summary. No questions, no queue — just the report.
```
```
