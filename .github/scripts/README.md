# Weekly opportunity-digest automation

A scheduled GitHub Action that researches new funding opportunities for the
Saudi Opportunity Hub and opens a draft PR with a digest every Monday.

## Architecture

```
        Monday 08:00 UTC                Bright Data SERP (optional)
              │                                  │
              ▼                                  ▼
   GitHub Actions runner ───────► research_opportunities.py
              │                                  │
              │           1. Pull existing titles from Supabase
              │           2. (optional) Bright Data SERP across known sources
              │           3. Claude (web_search + 3-layer verification)
              │           4. Write digests/YYYY-MM-DD.md
              ▼
       Open draft PR
```

## Required secrets

Set these in **Repo → Settings → Secrets and variables → Actions → New repository secret**:

| Secret                       | Required | What it does |
|------------------------------|----------|---------------|
| `ANTHROPIC_API_KEY`          | **Yes**  | Authenticates the Claude API call. Get one at <https://console.anthropic.com>. |
| `BRIGHTDATA_API_TOKEN`       | No       | Enables Bright Data SERP + Web Unlocker for higher-quality source crawling. Without it the script falls back to Claude's native `web_search` tool. |
| `BRIGHTDATA_SERP_ZONE`       | No       | Zone name configured in your Bright Data dashboard for SERP queries. |
| `BRIGHTDATA_UNLOCKER_ZONE`   | No       | Zone name for fetching full page content via Web Unlocker. |

You can also override the model the script uses by setting `CLAUDE_MODEL` as a
plain repo variable (not a secret); default is `claude-sonnet-4-6`.

## Triggering

- **Automatic**: every Monday at 08:00 UTC (≈09:00 Europe/Amsterdam winter,
  10:00 summer). Adjust the cron line in
  [`.github/workflows/weekly-opportunity-digest.yml`](../workflows/weekly-opportunity-digest.yml).
- **Manual**: GitHub → Actions tab → "Weekly opportunity digest" → "Run workflow".
  Optional inputs let you change the min/max candidate count for that run.

## Output

Each run produces:

- `digests/YYYY-MM-DD.md` — Markdown digest with a candidates table, full
  per-candidate detail, rejection notes, summary stats, and a raw JSON block
  suitable for pasting into a Supabase `INSERT`.
- A **draft pull request** on a branch named `digest/YYYY-MM-DD`. The PR is
  draft on purpose — nothing lands without your review. Close it without
  merging once you've copied the rows you want into Supabase.

## Cost estimate

Per run, with Claude Sonnet 4.6 and ~600 existing titles in context:

| Item | Tokens (approx) | Sonnet cost |
|------|-----------------|-------------|
| System prompt | ~1,500 | — |
| Dedup baseline + search hits | ~30,000 | — |
| Output (digest + JSON) | ~5,000 | — |
| **Total per run** | ~36,500 | ≈ **$0.20** |

Weekly ≈ **$0.80 / month** plus your Bright Data zone usage if enabled.

## Local dry-run

```bash
cd .github/scripts
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt

export ANTHROPIC_API_KEY=sk-ant-...
# optional:
export BRIGHTDATA_API_TOKEN=...
export BRIGHTDATA_SERP_ZONE=...
export BRIGHTDATA_UNLOCKER_ZONE=...

python research_opportunities.py
# → writes ../../digests/<today>.md
```

## Tuning the source list

Edit `SOURCES` in [`research_opportunities.py`](./research_opportunities.py).
Each entry is `(label, search query)`. Add sources, remove dead ones, or
narrow the query phrasing — the script picks them up on the next run.

## Disabling temporarily

Either:

- Comment out the `schedule:` block in the workflow file (manual `Run workflow`
  still works), or
- Disable the workflow from the Actions tab → ⋯ → "Disable workflow".
