# Opportunity Intelligence Pipeline Run – 2026-06-15

**Branch:** `claude/ecstatic-sagan-cd223p`  
**DB Project:** `dshrbbnjahjcwxzvzygh` (table: `opportunities`)  
**Pre-run count:** 5,047  
**Post-run count:** 5,065  
**Net new:** 18 opportunities inserted

---

## Pipeline Summary

| Phase | Result |
|-------|--------|
| Agent 1 – DB survey + web search | 20 candidates proposed |
| Agent 2 – URL liveness check | 18 PASS (2 excluded: alfozanaward.org past competitions appear closed) |
| Agent 3 – Validity check (real, not expired, primary source) | 18 PASS |
| Agent 4 – Data accuracy check | 18 PASS |
| Main Agent – Cross-reference + INSERT | **18 inserted** |

**Exclusion enforced:** No opportunities from `investsaudi.sa` domain.

---

## Inserted Opportunities

| # | Title | URL | Sector | Status | Deadline |
|---|-------|-----|--------|--------|----------|
| 1 | Abdullatif Al Fozan Award for Mosque Architecture – 6th Cycle (2026–2029) | alfozanaward.org/actual-cycle/ | Real Estate | open | open |
| 2 | Abdullatif Al Fozan Award – International Student Mosque Architecture Competition | alfozanaward.org/competitions/student-competition/ | Education | open | open |
| 3 | Great Arab Minds Award | greatarabminds.ae/apply/ | Innovation & Entrepreneurship | recurring | recurring |
| 4 | Global Teacher Prize | globalteacherprize.org | Education | recurring | recurring |
| 5 | Global Student Prize | varkeyfoundation.org/global-student-prize | Education | recurring | recurring |
| 6 | Global Schools Prize | varkeyfoundation.org/global-schools-prize | Education | recurring | recurring |
| 7 | Zayed Award for Human Fraternity | zayedaward.org | Humanitarian | recurring | recurring |
| 8 | Arab Water Council Non-Conventional Water Resources Award | ncwr.arabwatercouncil.org/award/ | Environment Services | recurring | recurring |
| 9 | MATE ROV Competition – Saudi Arabia Red Sea Regional | materovcompetition.org/register-regionals/saudiarabia-regional | Education | recurring | recurring |
| 10 | Aga Khan Award for Architecture | the.akdn/en/.../aga-khan-award-for-architecture | Real Estate | open | 2026-09-15 |
| 11 | World Summit Awards (WSA) | wsa-global.org | ICT | recurring | recurring |
| 12 | Mada Innovation Award 2026 | award.mada.org.qa/submission/ | ICT | open | 2026-06-20 |
| 13 | Sheikh Zayed Book Award – 21st Edition (2026) | zayedaward.ae | Tourism & Quality of Life | open | 2026-09-01 |
| 14 | Sharjah International Book Fair (SIBF) Translation Grant | sibf.com | Tourism & Quality of Life | recurring | recurring |
| 15 | International Prize for Arabic Fiction (IPAF) | en.arabicfiction.org | Tourism & Quality of Life | recurring | recurring |
| 16 | Rolex Awards for Enterprise | rolex.org/rolex-awards | Innovation & Entrepreneurship | recurring | recurring |
| 17 | National Geographic Society Explorer Grants Program | nationalgeographic.org/funding-opportunities/grants/ | Environment Services | open | open |
| 18 | Arab Reading Challenge | arabreadingchallenge.com/en | Education | recurring | recurring |

---

## Dedup Guard Used

All inserts used `WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = $url)` — no `ON CONFLICT` clause, per spec. IDs generated with `gen_random_uuid()::text`.

## Domains Confirmed NOT Previously in DB

Each domain verified via targeted `SELECT application_link FROM opportunities WHERE application_link LIKE '%domain%' LIMIT 20` queries before proposing. All 18 domains returned 0 matches prior to insertion.
