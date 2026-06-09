# Opportunity Intelligence Pipeline Run — 2026-06-09

## Summary

4-agent pipeline completed. 12 new opportunities inserted into Supabase table `opportunities` (project `dshrbbnjahjcwxzvzygh`). Total records: **3,846** (was 3,834).

## Pipeline Results

| Stage | Count |
|---|---|
| Agent 1 candidates proposed | 20 |
| Agent 2 failed (dead URL) | 1 (ID 19 – ECONNREFUSED) |
| Agent 3 failed (invalid/duplicate opportunity) | 8 (IDs 4, 9, 14, 15, 16, 17, 18, 19) |
| Agent 4 corrections applied | 2 (IDs 12, 13 – deadline_date fixed to `open`) |
| **Successfully inserted** | **12** |
| Skipped (already in DB) | 0 |

## Inserted Opportunities

| # | Title | Sector | Type | Status | Region |
|---|---|---|---|---|---|
| 1 | Aramco Community Sponsorship Grant Program | Humanitarian | Grant | recurring | Saudi Arabia |
| 2 | Aramco Global Sponsorship Hub | Private Sector | Sponsorship | recurring | Global |
| 3 | Falling Walls Lab 2026 – Global Science Competition | Innovation & Entrepreneurship | Competition | open | Global |
| 4 | Miller Center GSBI Accelerator 2026 | Innovation & Entrepreneurship | Accelerator | open | Global |
| 5 | ASTF Abdul Latif Jameel Research Grant Programme | Innovation & Entrepreneurship | Grant | recurring | Arab States |
| 6 | UNIDO Global Entrepreneurs Alliance (GEA) | Innovation & Entrepreneurship | Program | recurring | Middle East |
| 7 | World Entrepreneurs Investment Forum (WEIF) | Innovation & Entrepreneurship | Forum | recurring | Middle East |
| 8 | AICEI – Arab Enterprise Creation and Growth Programs | Innovation & Entrepreneurship | Training | recurring | Arab States |
| 9 | UNESCWA Abdul Latif Jameel Grant for Arab Research | Education | Grant | recurring | Arab States |
| 10 | Saudi Environment Fund – Green Factory Initiative | Environment Services | Grant | open | Saudi Arabia |
| 11 | Saudi Environment Fund – NPO Environment Action Grant | Environment Services | Grant | open | Saudi Arabia |
| 12 | Aramco Sponsorship Request – Corporate and Community Grants | Private Sector | Sponsorship | recurring | Global |

## Failed Candidates (not inserted)

| ID | URL | Reason |
|---|---|---|
| 4 | safcsp.org.sa/en/ | Agent 3: organizational homepage, no specific program |
| 9 | idwsc.com/attend/whats-on-idws | Agent 3: conference attendance only, not a funding opportunity |
| 14 | my.gov.sa/en/content/Investment-incentives | Agent 3: informational government page, not actionable |
| 15 | saudiyouth.org/ | Agent 3: organizational homepage |
| 16 | itpo-manama.unido.org/ | Agent 3: organizational homepage, superseded by IDs 6 & 7 |
| 17 | astf.net/new/ | Agent 3: generic, superseded by more specific ID 5 |
| 18 | aicei.online/about-us/who-we-are | Agent 3: About page, duplicate of ID 8 |
| 19 | smeportal.unescwa.org/UN-for-SMEs/aicei | Agent 2: ECONNREFUSED; Agent 3: duplicate of ID 8 |

## Rules Compliance

- EXCLUSION: investsaudi.sa domain — never used ✓
- Sectors: all from the 17 allowed values ✓
- deadline_date: all valid (`open`, `recurring`, or ISO date) ✓
- status: all valid (`open` or `recurring`) ✓
- id: generated with `gen_random_uuid()::text` ✓
- sectors: stored as `text[]` single-element arrays ✓
- last_verified: `2026-05-17` ✓
- Deduplication: WHERE NOT EXISTS guard applied to all 12 inserts ✓
