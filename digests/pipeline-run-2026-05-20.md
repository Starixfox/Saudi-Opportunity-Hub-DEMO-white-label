# Opportunity Intelligence Pipeline Run — 2026-05-20

## Summary

| Metric | Count |
|---|---|
| Candidates discovered (Agent 1) | 20 |
| Passed URL liveness check (Agent 2) | 16 |
| Passed validity check (Agent 3) | 18 |
| Passed data accuracy check (Agent 4) | 12 |
| **Passed all 3 verification agents** | **9** |
| Inserted into Supabase | **9** |
| Skipped (failed ≥1 agent) | 11 |

## Inserted Records

| ID | Title | Sector | Type | Link |
|---|---|---|---|---|
| SA-N318 | Artificial Intelligence Innovation Challenge — CODE MCIT | ict | Competition | https://code.mcit.gov.sa/en/challenges/ai |
| SA-N319 | HRDF Professional Experience Program for Saudi Students | education | Training Program | https://www.hrdf.org.sa/en/products-and-services/programs/individuals/training/professional-experience/ |
| SA-N320 | Monshaat Innovation Center — Open Access for Entrepreneurs | innovation | Incubator | https://innovationcenter.monshaat.gov.sa/en |
| SA-N321 | SDAIA Academy AI and Data Bootcamps — Saudi Professionals | ict | Training Program | https://sdaia.gov.sa/en/Sectors/academy/bootcamps/Pages/default.aspx |
| SA-N322 | Monshaat Business Incubator and Accelerator Licensing Program | innovation | Licensing Program | https://www.monshaat.gov.sa/en/ep |
| SA-N323 | RDIA Saudi Emerging Investigator Research Grant Program | innovation | Grant | https://saudiminds.rdia.gov.sa/account/grants-info/2 |
| SA-N324 | HRDF Professional Experience Program for Establishments | education | Training Program | https://www.hrdf.org.sa/en/products-and-services/programs/establishments/training/professional-experience/ |
| SA-N325 | SDAIA Academy for Data & AI — National Capacity Building | ict | Training Program | https://sdaia.gov.sa/en/Sectors/academy/Pages/default.aspx |
| SA-N326 | Monshaat SME Support Centers — National Advisory Network | innovation | Support Program | https://www.monshaat.gov.sa/en/ssc |

## Discarded Candidates

| # | Title | Failed Agent(s) | Reason |
|---|---|---|---|
| 1 | Sahabah Water Sector Accelerator (MEWA) | Agent 2 | ECONNREFUSED — entrepreneurship.mewa.gov.sa unreachable from scraper |
| 2 | Sunbolah Agriculture Accelerator (MEWA) | Agent 2 | ECONNREFUSED — entrepreneurship.mewa.gov.sa unreachable from scraper |
| 3 | Sedrah Environment Accelerator (MEWA) | Agent 2 | ECONNREFUSED — entrepreneurship.mewa.gov.sa unreachable from scraper |
| 4 | CODE AI Incubator — MCIT | Agent 4 | Funding claim "NTDP financial support provided" unverified |
| 7 | KACST Venture Program (KVP) | Agent 3, 4 | `/internal/` path suggests intranet page; edition number and SAR 6.9M funding figure unverified |
| 10 | Monshaat Fikra Commercial Innovation Portal | Agent 4 | Title unverifiable from generic node ID URL `/node/12827` |
| 11 | Propeller Kernel Camp | Agent 4 | 403 blocked; institution type, funding specifics, and geographic scope unverified |
| 13 | Monshaat E-Commerce Support (SMEs) | Agent 4 | Sector mismatch — ICT incorrect; should be innovation for SME e-commerce support |
| 14 | TDF Grow Tourism Accelerator — Second Cohort | Agent 4 | "Second Cohort" claim conflicts with GP-000001 identifier |
| 16 | SIAN — Saudi Incubators and Accelerators Network | Agents 2, 3, 4 | ECONNREFUSED (non-gov.sa domain); institution attribution inaccurate |
| 17 | TDF Tourism Hackathons 2026 — 8 Saudi Cities | Agent 4 | Specific title claims unverifiable for general listing page URL |

## Pipeline Configuration

- Supabase project: `dshrbbnjahjcwxzvzygh`
- Target table: `opportunities`
- Exclusion rule: No `investsaudi.sa` links
- Dedup: checked against existing 1,001+ records via `/tmp/existing_links.txt`
- Branch: `claude/modest-hopper-zrWmO`
