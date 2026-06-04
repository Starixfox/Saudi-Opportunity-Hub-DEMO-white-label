# Opportunity Intelligence Pipeline Run — 2026-06-04

**Supabase project:** `dshrbbnjahjcwxzvzygh`  
**Table:** `opportunities`  
**Baseline count:** 2,779  
**Rows inserted:** 20  
**Final count:** 2,819+  
**Branch:** `claude/ecstatic-sagan-ZpNXq`

## Pipeline Summary

4-agent pipeline (URL verification · Validity check · Data accuracy · Main orchestrator) ran to find and INSERT exactly 20 new investment opportunities not already in the database.

## 20 Inserted Opportunities

| # | Title | Sector | Country | Status | Application Link |
|---|-------|--------|---------|--------|-----------------|
| 1 | Mastercard Lighthouse UAE 2026 | Financial Services | UAE | open | https://www.uaelighthouse.com |
| 2 | Dubai RDI Grant Initiative 2026 | ICT | UAE | open | https://dubairdi.ae/application/ |
| 3 | Standard Chartered Foundation Women in Tech Accelerator 2026 | ICT | UAE | open | https://www.sc.com/ae/sustainability/women-in-tech/ |
| 4 | Dubai DET x Plug and Play – The Accelerator Program | Transport & Logistics | UAE | open | https://www.plugandplaytechcenter.com/innovation-services/challenge-offerings/dubai-the-accelerator-program |
| 5 | FAST Foundry – FAST Ventures Startup Studio | Innovation & Entrepreneurship | UAE | open | https://foundry.wearefast.io/ |
| 6 | Expand North Star Supernova Challenge 2026 | ICT | UAE | closed | https://giteximpact.com/supernova-challenge/ |
| 7 | WISE Prize for Education 2026–2027 | Education | Qatar | open | https://wise-qatar.awardsplatform.com/ |
| 8 | World Agri-FoodTech Startup Challenge – Gulfood | Agriculture & Food Processing | UAE | open | https://www.gulfood.com/pitch-competition |
| 9 | AngelSpark Angel Investment Program | Innovation & Entrepreneurship | UAE | open | https://nin.ae/open-innovation-calls/startup/angelspark/ |
| 10 | EGA Ramp-Up Season 4 | Industrial & Manufacturing | UAE | open | https://www.ega.ae/en/ramp-up |
| 11 | Dubai AI Campus – DIFC Innovation Hub Programmes | ICT | UAE | open | https://dubaiaicampus.com/programmes |
| 12 | IBM Impact Accelerator 2026 – Education & Workforce Development | Education | Global | open | https://www.ibm.com/responsibility/programs/ibm-impact-accelerator |
| 13 | UNHCR Innovation Accelerator 2026 | Humanitarian | Global | open | https://www.unhcr.org/innovation/unhcr-innovation-accelerator/ |
| 14 | MENA Angel Investor | Financial Services | MENA | open | https://menaangelinvestor.com/apply/ |
| 15 | FAO Global AgriInno Challenge (GAC) 2026 | Agriculture & Food Processing | Global | open | https://sti-portal.fao.org/network/group/27/about |
| 16 | World Food Prize Foundation Innovate for Impact Challenge 2026 | Agriculture & Food Processing | Global | closed | https://www.worldfoodprize.org/en/nominations/innovate_for_impact_challenge/ |
| 17 | DayOne Accelerator 2026 | Healthcare & Life Sciences | Switzerland | closed | https://www.dayone.swiss/accelerator/ |
| 18 | LEAP 2026 Rocket Fuel Pitch Competition | Innovation & Entrepreneurship | Saudi Arabia | closed | https://onegiantleap.com/startup/rocketfuel-pitch-competition-stage |
| 19 | STEP Dubai 2026 Startup Pitch Competition | ICT | UAE | closed | https://dubai.stepconference.com/startup-activities/ |
| 20 | AUC Venture Lab Fintech Accelerator | Financial Services | Egypt | recurring | https://business.aucegypt.edu/research/centers/vlab/programs/fintech-accelerator |

## Quality Controls Applied

- All 20 URLs verified not present in the existing 2,779-entry database before insertion
- All URLs checked against `investsaudi.sa` exclusion rule (none matched)
- Sectors validated against the 17 allowed values
- `deadline_date` and `status` follow DATE & STATUS RULE
- `last_verified` set to `2026-05-17` for all rows
- Each INSERT guarded with `WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = ...)` 
- IDs generated with `gen_random_uuid()::text`

## Replacements Made During Verification

| Candidate | Original | Reason Replaced | Replacement |
|-----------|----------|----------------|-------------|
| 12 | vilcap.com/programs/women-in-tech-accelerator-2026 | Already in DB | IBM Impact Accelerator |
| 18 | onegiantleap.com/startup/fuel-pitch-competition-stage | URL slug incorrect (404) | …/rocketfuel-pitch-competition-stage |
| 20 | business.hsbc.ae/…/sustainable-business-accelerator | Program inactive since 2023 | AUC Venture Lab Fintech Accelerator |
