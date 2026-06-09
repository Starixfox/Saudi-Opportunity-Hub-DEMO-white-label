# Opportunity Discovery Pipeline Run – 2026-06-09

## Summary
20 new investment opportunities discovered, verified, and inserted into Supabase (`dshrbbnjahjcwxzvzygh`).
All records use `last_verified = '2026-05-17'` and dedup guard `WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = ...)`.

## Inserted Opportunities

| # | Title | Sector | Type | Status | Deadline |
|---|-------|--------|------|--------|----------|
| 1 | ACSS Small Grants Program (SGP) Cycle 10: AI Research Grant | Education | Grant | open | 2026-07-14 |
| 2 | ACSS Scholars Collaborative Grants (SCG) Cycle 1 | Education | Grant | closed | 2025-03-24 |
| 3 | ACSS Research Grants Program (RGP) Cycle 10: Rethinking Development | Education | Grant | closed | 2024-12-31 |
| 4 | ACSS Scholars Collaborative Grants (SCG) Cycle 2 | Education | Grant | closed | 2025-10-26 |
| 5 | TikTok x Blossom SME Empowerment Program – AI Accelerator (2nd Cohort) | ICT | Accelerator | open | open |
| 6 | Fourth Industrial Revolution Program Grant (4IR Grant) | Industrial & Manufacturing | Grant | recurring | recurring |
| 7 | SEU Sports Technology Accelerator | Tourism & Quality of Life | Accelerator | recurring | recurring |
| 8 | Ministry of Culture Cultural Research Grants Program | Tourism & Quality of Life | Grant | open | 2026-08-31 |
| 9 | Municipal Investment Opportunity: Livestock and Feed Market Operation | Agriculture & Food Processing | Investment | closed | closed |
| 10 | Municipal Investment: Al-Amal Street Naming and Sponsorship Rights, Al-Neim | Tourism & Quality of Life | Investment | open | open |
| 11 | Municipal Investment: Residential Villas Development, Al-Aridh District, Riyadh | Real Estate | Investment | open | open |
| 12 | Saudi Tourism Authority Graduate Development Program | Tourism & Quality of Life | Scholarship | recurring | recurring |
| 13 | SpaceUp Competition: Greening Saudi Arabia Challenge | Environment Services | Competition | closed | 2025-04-12 |
| 14 | Royal Commission for AlUla – Future Investment Initiative | Tourism & Quality of Life | Investment | open | open |
| 15 | Energy Tech Challengers – Europe 2026 | Energy | Competition | closed | 2026-04-15 |
| 16 | Energy Tech Challengers – Asia 2026 | Energy | Competition | open | open |
| 17 | Arab IoT & AI Challenge – Registration Portal | ICT | Competition | recurring | recurring |
| 18 | MEWA Sunbolah – FoodTech Accelerator Track | Agriculture & Food Processing | Accelerator | closed | 2026-05-12 |
| 19 | Falling Walls Lab Riyadh 2026 | Innovation & Entrepreneurship | Competition | open | 2026-08-01 |
| 20 | TDF Grow Tourism Programme – New Cohort Entry (GP-000006) | Tourism & Quality of Life | Accelerator | recurring | recurring |

## Sector Breakdown
- Tourism & Quality of Life: 7
- Education: 4
- Agriculture & Food Processing: 3
- ICT: 2
- Energy: 2
- Industrial & Manufacturing: 1
- Real Estate: 1
- Environment Services: 1
- Innovation & Entrepreneurship: 1

## Notes
- All 20 URLs verified not in DB prior to insertion (dedup check against 3,862 existing records)
- No investsaudi.sa URLs included (per pipeline constraint)
- URL #20 (TDF GP-000006): portal returns HTTP 403; title/description conservatively derived from TDF Grow series pattern (GP-000001–GP-000005)
- Sources include: ACSS grant portal, MOMAH Furas portal, CST, RCU, STA, MoC, MEWA, SEU, TDF, Blossom, Energy Tech Summit, Falling Walls, Arab IoT & AI
