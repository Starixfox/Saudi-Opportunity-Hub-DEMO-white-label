# Opportunity Intelligence Pipeline Run — 2026-06-10

**Date:** 2026-06-10  
**Branch:** `claude/ecstatic-sagan-yv2vy6`  
**Database:** Supabase `dshrbbnjahjcwxzvzygh`  
**Pipeline:** 4-agent opportunity discovery and insertion

---

## Summary

| Stage | Count |
|---|---:|
| Candidates researched | ~40 |
| Failed dedup (already in DB) | ~20 |
| Passed all agents | 20 |
| Inserted | 20 |
| Skipped (dedup guard fired) | 0 |

All 20 entries inserted with `WHERE NOT EXISTS` dedup guard. `last_verified = 2026-05-17` on all rows.

---

## Inserted Opportunities

| # | Title | Sector | URL |
|---|---|---|---|
| 1 | Motamim Industrial Licensing Program | Industrial & Manufacturing | https://modon.gov.sa/en/Programs/Pages/Motamim.aspx |
| 2 | Tali Ventures Corporate Venture Capital | ICT | https://tali.vc/ |
| 3 | Arab Fund for Economic and Social Development – Grant Programs | Private Sector | https://www.arabfund.org/en/grant-programs |
| 4 | Riyadh Valley Company Investment Portfolio | Innovation & Entrepreneurship | https://rvc.com.sa/en/investments/ |
| 5 | Saudi Ministry of Transport – Logistics Sectors Investment | Transport & Logistics | https://mot.gov.sa/en/logistics-sectors |
| 6 | MoH × BioLabs Saudi Biotech Accelerator | Pharma & Biotech | https://www.saudi-biotech.com/ |
| 7 | Saudi Fund for Development | Humanitarian | https://www.sfd.gov.sa/en/ |
| 8 | The Arab Energy Fund (TAEF) – Energy Transition Investment | Energy | https://taef.com/ |
| 9 | NIDLP Daleel – Basic Chemicals Investment Guide | Chemicals | https://daleel.gov.sa/segment/basic-chemicals/ |
| 10 | NIDLP Daleel – Intermediate Chemicals Investment Guide | Chemicals | https://daleel.gov.sa/segment/intermediate-chemicals/ |
| 11 | NIDLP Daleel – Mining Upstream Investment Guide | Mining & Metals | https://daleel.gov.sa/segment/mining-upstream-mines/ |
| 12 | Daleel Investment Platform – Saudi Arabia Industry and Logistics | Industrial & Manufacturing | https://daleel.gov.sa/en |
| 13 | Dammam Valley – Innovation Hub Investment | Innovation & Entrepreneurship | https://dammamvalley.sa/en/industries/innovation |
| 14 | PIF Real Estate Program | Real Estate | https://www.pif.gov.sa/en/strategy-and-impact/the-program/real-estate/ |
| 15 | NIDLP Daleel – Medical Devices & Supplies Investment Guide | Healthcare & Life Sciences | https://daleel.gov.sa/segment/medical-devices-supplies/ |
| 16 | Saudi Ministry of Education – Private Sector Investment in Education | Education | https://moe.gov.sa/en/investment/Pages/default.aspx |
| 17 | NIDLP Daleel – Food & Beverage Processing Investment Guide | Agriculture & Food Processing | https://daleel.gov.sa/FoodBeverages |
| 18 | PIF Capital Markets Program | Financial Services | https://www.pif.gov.sa/en/investors/capital-markets-program/ |
| 19 | Saudi Vision 2030 – Quality of Life Program | Tourism & Quality of Life | https://www.vision2030.gov.sa/en/explore/programs/quality-of-life-program |
| 20 | Middle East Green Initiative (MGI) | Environment Services | https://www.sgi.gov.sa/about-mgi/ |

---

## Sector Coverage

16 of 17 allowed sectors covered. Missing sector: none (Pharma & Biotech covered by #6).

| Sector | Count |
|---|---:|
| Industrial & Manufacturing | 2 |
| ICT | 1 |
| Private Sector | 1 |
| Innovation & Entrepreneurship | 2 |
| Transport & Logistics | 1 |
| Pharma & Biotech | 1 |
| Humanitarian | 1 |
| Energy | 1 |
| Chemicals | 2 |
| Mining & Metals | 1 |
| Real Estate | 1 |
| Healthcare & Life Sciences | 1 |
| Education | 1 |
| Agriculture & Food Processing | 1 |
| Financial Services | 1 |
| Tourism & Quality of Life | 1 |
| Environment Services | 1 |

---

## Exclusions Applied

- `investsaudi.sa` domain excluded per standing rule
- `saudigreeninitiative.org` excluded (not official primary source; official site is `sgi.gov.sa`)
- `sparklabssaudi.com` excluded (already in DB)
- `aramcoventures.com` excluded (already in DB)
- All TDF program sub-pages except final candidate — already in DB
- All ic.gov.sa cluster pages — already in DB
- All roshn.sa sub-pages — already in DB
- All ncp.gov.sa URLs — already in DB
