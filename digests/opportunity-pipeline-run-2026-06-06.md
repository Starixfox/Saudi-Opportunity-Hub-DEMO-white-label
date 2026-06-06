# Opportunity Intelligence Pipeline Run — 2026-06-06

## Summary
- **Candidates proposed (Agent 1):** 20
- **Failed Agent 2 liveness:** 0 (all 20 returned HTTP 403 — live, scraper-blocking)
- **Failed Agent 3 validity:** 0
- **Failed Agent 4 accuracy:** 0
- **Total inserted:** 20
- **Skipped (WHERE NOT EXISTS):** 0
- **Database row count:** 3,122 (was 3,102)

## Inserted Opportunities

| # | Title | Sector | Status | Deadline | Country |
|---|-------|--------|--------|----------|---------|
| 1 | DominAite AI Scale Accelerator | ICT | closed | 2026-04-18 | Saudi Arabia |
| 2 | Tomoh Fast-Growing SME Scale-Up Program | Private Sector | open | open | Saudi Arabia |
| 3 | Sedrah Environment Sector Startup Accelerator – 2026 Registration | Environment Services | closed | 2026-05-12 | Saudi Arabia |
| 4 | Women Entrepreneurs Finance Initiative (We-Fi) | Financial Services | open | open | Global |
| 5 | OPEC Fund for International Development – Private Sector Financing | Humanitarian | open | open | Global |
| 6 | Senaei Industrial Incentives Platform | Industrial & Manufacturing | open | open | Saudi Arabia |
| 7 | Saudi Ministry of Commerce – Start Your Business Portal | Private Sector | open | open | Saudi Arabia |
| 8 | Sanabel Microfinance Network of Arab Countries – Membership Program | Financial Services | open | open | Arab Countries |
| 9 | Saudi Jordanian Investment Fund (SJIF) | Industrial & Manufacturing | open | open | Jordan |
| 10 | Abu Dhabi Department of Health Research and Innovation Grant | Healthcare & Life Sciences | recurring | recurring | UAE |
| 11 | KACST National R&D Grants Program | Innovation & Entrepreneurship | open | open | Saudi Arabia |
| 12 | Ma'aden Mining Investment and Partnership Opportunities | Mining & Metals | open | open | Saudi Arabia |
| 13 | SWCC Innovation Submission Platform | Environment Services | open | open | Saudi Arabia |
| 14 | Saudi Data and AI Authority (SDAIA) AI Innovation Programs | ICT | open | open | Saudi Arabia |
| 15 | Qatar Development Bank Green Financing Program | Energy | open | open | Qatar |
| 16 | KAPSARC Energy Research Fellowships and Grants | Energy | open | open | Saudi Arabia |
| 17 | Ejar Real Estate Rental Investment Platform | Real Estate | open | open | Saudi Arabia |
| 18 | Ithmar Capital Alternative Investment Management | Financial Services | open | open | UAE |
| 19 | Future Fund Oman Investment Program | Innovation & Entrepreneurship | open | open | Oman |
| 20 | Saudi Cultural Development Fund – Cultural Financing Program | Tourism & Quality of Life | open | open | Saudi Arabia |

## Notes
- All 20 URLs confirmed NOT in the existing 3,102-link database before insertion
- `WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = ...)` guard used on every INSERT
- No `ON CONFLICT` clause used (no unique constraint on `application_link`)
- All sector values drawn from the approved 17-value taxonomy
- `last_verified` set to `'2026-05-17'::date` for all rows
- `id` generated with `gen_random_uuid()::text` for all rows
- investsaudi.sa domain exclusion rule applied throughout Agent 1 discovery
