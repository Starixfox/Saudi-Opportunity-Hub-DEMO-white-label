# Opportunity Intelligence Pipeline Run — 2026-05-28

**Project:** Saudi Opportunity Hub (Supabase: `dshrbbnjahjcwxzvzygh`)  
**Table:** `opportunities`  
**Run date:** 2026-05-28  
**Pre-run count:** 1,575  
**Post-run count:** 1,589  
**Net new:** +14

---

## Pipeline Summary

| Stage | Agent | Result |
|-------|-------|--------|
| Discovery | Agent 1 | 20 candidates proposed |
| URL Liveness | Agent 2 | 17 LIVE / 3 DEAD |
| Validity Check | Agent 3 | 14 VALID / 3 REJECTED |
| Data Accuracy | Agent 4 | 14 ACCURATE (2 corrected in-flight) |
| Insertion | Main Agent | 14 inserted / 0 skipped |

---

## Agent 2 — URL Liveness Rejections (3)

| URL | Reason |
|-----|--------|
| `https://saudispace.gov.sa/en/landing-page/` | ECONNREFUSED — server unreachable |
| `https://www.mcit.gov.sa/en/media-center/initiatives/tech-champions` | Superseded by 5th edition; 4th edition link broken |
| `https://doh.gov.ae/en/programs/...` | Deadline passed Feb 28 2026 |

## Agent 3 — Validity Rejections (3)

| Opportunity | Reason |
|-------------|--------|
| NEOM Oxagon Startup Program Cohort 1 | Past cohort — no open application |
| MCIT Tech Champions 4th Edition | 5th edition already launched; 4th closed |
| Abu Dhabi DOH Community Health Initiative | Deadline passed |

---

## 14 Verified Opportunities Inserted

| # | Title | Sector | Country |
|---|-------|--------|---------|
| 1 | KAUST Research Funding Service — External Sponsor Opportunities | Innovation & Entrepreneurship | Saudi Arabia |
| 2 | Tamkeen Bahrain Enterprise Support Programs 2026 | Private Sector | Bahrain |
| 3 | Riyadah National Entrepreneurship Training Program | Innovation & Entrepreneurship | Saudi Arabia |
| 4 | LEAP 2026 Startup & Scaleup Program — Rocket Fuel Pitch Competition | ICT | Saudi Arabia |
| 5 | MIT Enterprise Forum Saudi Arabia Startup Competition | Innovation & Entrepreneurship | Saudi Arabia |
| 6 | Saudi Tourism Authority Accelerator Program | Tourism & Quality of Life | Saudi Arabia |
| 7 | MCIT Tech Founders Program — Saudi Digital Startup Builder | ICT | Saudi Arabia |
| 8 | Tamweel SME Digital Financing Platform | Financial Services | Saudi Arabia |
| 9 | Bahrain EDB Startup Fast-Track and Investment Support | Private Sector | Bahrain |
| 10 | Founder Institute MENA Pre-Seed Accelerator 2026 | Innovation & Entrepreneurship | MENA |
| 11 | Future Fund Oman — Investment Application Process | Private Sector | Oman |
| 12 | Misk Hub Programs — Saudi Youth Leadership and Entrepreneurship | Education | Saudi Arabia |
| 13 | Takamol Ventures — Corporate VC for Saudi Tech Startups | ICT | Saudi Arabia |
| 14 | Taqatech Energy Sector Accelerator — Steps & Services | Energy | Saudi Arabia |

---

## Rules Applied

- `investsaudi.sa` exclusion rule: enforced (0 proposals from that domain)
- Sector values: all 14 use approved values from the 17-sector list
- Deduplication: all 14 URLs confirmed absent before insertion
- `isNew`: set to `true` on all 14 rows
