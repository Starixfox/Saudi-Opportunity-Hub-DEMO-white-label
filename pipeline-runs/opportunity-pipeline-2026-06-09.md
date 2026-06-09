# Opportunity Intelligence Pipeline Run — 2026-06-09

## Summary
Autonomous 4-agent pipeline successfully found and inserted **20 new verified opportunities** into the Supabase `opportunities` table.

- Database before: 3,741 rows
- Database after: 3,761 rows
- New entries: 20

## Inserted Opportunities

| # | Title | URL | Sector | Status |
|---|-------|-----|--------|--------|
| 1 | Founder Institute MENA Startup Accelerator | https://fi.co/mena | Innovation & Entrepreneurship | recurring |
| 2 | WAM Saudi 2026 Startup Exhibit | https://event.wamsaudi.com/2026-Startup | Industrial & Manufacturing | closed |
| 3 | The Garage Plus Accelerator | https://thegarage.sa/garage-plus | ICT | recurring |
| 4 | ACCESS Disability Technologies Accelerator | https://thegarage.sa/access | Healthcare & Life Sciences | open |
| 5 | Techstars Founder Catalyst Jeddah | https://www.techstars.com/accelerators/jeddah | ICT | recurring |
| 6 | Techstars Founder Catalyst Al-Ahsa | https://www.techstars.com/accelerators/al-ahsa | ICT | recurring |
| 7 | DGA Innovation Hackathon 2025 | https://dga.gov.sa/en/Events/Innovation-Hackathon | ICT | closed |
| 8 | Saudi 4IR Hackathon #8 | https://saudi4ir.mcit.gov.sa/en/hackathon/8 | Industrial & Manufacturing | closed |
| 9 | Taqatech Energy Technology Accelerator | https://thegarage.sa/taqatech | Energy | recurring |
| 10 | The Garage Deep-Tech Incubator | https://thegarage.sa/garage-incubator | ICT | open |
| 11 | Meta Llama Design Drive KSA | https://llamadesigndrive.com/ksa.html | ICT | recurring |
| 12 | GAME BY CODE Gaming Incubator | https://code.mcit.gov.sa/en/incubator/game-by-code | ICT | recurring |
| 13 | The Multiverse Program by CODE MCIT | https://code.mcit.gov.sa/en/multiverse | ICT | recurring |
| 14 | GameFounders KSA 2 Gaming Accelerator | https://code.mcit.gov.sa/en/accelerator-incubator/gamefounders-ksa-2 | ICT | closed |
| 15 | SWIC Water Technology Incubator | https://swic.sa/water-technology-incubator | Environment Services | open |
| 16 | Badir Inventors Service Office | https://www.badir.com.sa/en/programs/inventors-office | Innovation & Entrepreneurship | open |
| 17 | CODE University Incubators Program | https://code.mcit.gov.sa/en/university-incubators | ICT | recurring |
| 18 | Tech Pioneers Program by CODE MCIT | https://code.mcit.gov.sa/en/tech-pioneers | ICT | recurring |
| 19 | Developers Zone II Competition | https://code.mcit.gov.sa/en/competition/developers-zone-ii | ICT | closed |
| 20 | HUB71 Innovation Lab at CODE MCIT | https://code.mcit.gov.sa/en/Innovation-Lab/hub71 | ICT | open |

## Pipeline Steps Completed

- **Agent 1 (Discovery)**: Searched for new opportunities not in the 3,741-entry database using Google site: searches and domain deduplication against `/tmp/existing_links.txt`
- **Agent 2 (URL Verification)**: Confirmed all 20 URLs are indexed and real via WebSearch (WebFetch returned 403 for most Saudi government and commercial sites)
- **Agent 3 (Validity Check)**: Confirmed each is a primary-source, real Saudi opportunity
- **Agent 4 (Data Accuracy)**: Verified title, institution, sector, funding, and status for each
- **Main Agent**: Cross-referenced all verdicts, corrected URL for The Multiverse (using `/en/multiverse` not `/en/multiverse-program`), and executed 20 deduplication-safe INSERT statements

## Deduplication Method
Each INSERT used `WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = $url)` to prevent duplicates.

## Notes
- `investsaudi.sa` excluded per pipeline rules
- `last_verified` set to `2026-05-17` per specification
- `isNew` set to `true` for all entries
- Sectors use exact allowed values from the 17-sector taxonomy
