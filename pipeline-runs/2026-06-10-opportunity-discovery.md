# Opportunity Intelligence Pipeline Run – 2026-06-10

## Summary
- **Run date**: 2026-06-10
- **Agent**: 4-agent opportunity intelligence pipeline
- **Supabase project**: dshrbbnjahjcwxzvzygh
- **DB records before**: 4,097
- **DB records after**: 4,116 (+19 inserted)

## Pipeline Results
| Stage | Count |
|-------|-------|
| Agent 1 – Candidates proposed | 20 |
| Agent 2 – URL liveness FAIL (dead) | 1 (manara.om – ECONNREFUSED) |
| Agent 2 – URL liveness PASS | 19 |
| Agent 3 – Validity PASS | 19 |
| Agent 4 – Data accuracy PASS | 19 |
| **Final inserted** | **19** |

## Inserted Opportunities

| # | Title | Sector | Status | Funding | Deadline |
|---|-------|--------|--------|---------|----------|
| 1 | GAFSP 9th Call for Country-Led Agriculture Projects | Agriculture & Food Processing | open | $163,000,000 | 2026-09-15 |
| 2 | Fashion Trust Arabia – Debut Talent Grant | Tourism & Quality of Life | open | $50,000 | open |
| 3 | NTDP Connect Initiative – Tech SME PoC Funding | ICT | open | Up to $200,000 | open |
| 4 | Alfanar Venture Philanthropy – Arab Social Enterprise Investment | Humanitarian | recurring | Varies | recurring |
| 5 | Prince Sultan International Prize for Water (PSIPW) – 12th Edition | Environment Services | open | $130,000 | 2026-12-31 |
| 6 | Lenabtaker Entrepreneurship and Innovation Competition for Youth | Innovation & Entrepreneurship | recurring | Varies | recurring |
| 7 | Alwaleed Philanthropies Global Grant Programs | Humanitarian | recurring | Varies | recurring |
| 8 | Sanabil Investments – Venture and Growth Capital | Financial Services | open | Up to $20,000,000 | open |
| 9 | Jadwa Investment – GCC Private Credit Fund | Financial Services | open | $200,000,000 | open |
| 10 | Global Agriculture and Food Security Program (GAFSP) | Agriculture & Food Processing | open | Varies | open |
| 11 | Saudi Film Commission – Content and Production Incentives | Tourism & Quality of Life | open | Varies | open |
| 12 | Film Commission – Ministry of Culture Filmmaker Programs | Tourism & Quality of Life | open | Varies | open |
| 13 | Royal Commission for Jubail and Yanbu – Industrial Investment | Industrial & Manufacturing | open | Varies | open |
| 14 | Red Sea Global – Tourism Vendor and Investment Partnerships | Tourism & Quality of Life | open | Varies | open |
| 15 | AMAALA – Luxury Coastal Tourism Investment Opportunities | Tourism & Quality of Life | open | Varies | open |
| 16 | Saudi Ministry of Energy – Renewable Energy Investment Programs | Energy | open | Varies | open |
| 17 | Kafalah Program – SME Loan Guarantee Scheme | Financial Services | open | Up to SAR 30,000,000 | open |
| 18 | Saudi Investment Bank (SAIB) – SME and Corporate Financing | Financial Services | open | Varies | open |
| 19 | IsDB Agriculture Sector – Islamic Financing for Food Security | Agriculture & Food Processing | open | Varies | open |

## Excluded
- `https://manara.om/en/` – **Agent 2 FAIL**: ECONNREFUSED (server down)

## Notes
- Database already had 4,097 entries making new discovery challenging
- All URLs verified NEW via exact-match dedup against existing application_links
- Sectors validated against allowed list of 17
- deadline_date and status kept consistent per schema rules
- last_verified set to 2026-06-10
- No records from investsaudi.sa (exclusion rule respected)
