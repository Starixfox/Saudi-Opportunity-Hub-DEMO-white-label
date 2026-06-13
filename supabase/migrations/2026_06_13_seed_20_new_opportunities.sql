-- Seed: 20 new investment opportunities added 2026-06-13
-- Pipeline: 4-agent web-search + verification + fact-check + QA
-- Dedup guard: WHERE NOT EXISTS on application_link for each row
-- Skipped: any links from investsaudi.sa domain per policy

INSERT INTO opportunities (
    id, title, sponsor_institution, country, sectors, type, status,
    funding_amount, deadline_date, application_link, description_short,
    last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
    'Mohammed bin Rashid Al Maktoum Global Water Award — 5th Cycle',
    'Mohammed bin Rashid Al Maktoum Global Water Award',
    'UAE',
    ARRAY['Environment Services'],
    'Award',
    'open',
    'Up to USD 1,000,000',
    '2026-09-30',
    'https://www.mbrwateraward.ae/en/awards/online-application',
    'Biennial award recognizing innovative water management solutions globally; open to individuals, teams, and organizations.',
    '2026-06-13',
    'Global'
WHERE NOT EXISTS (
    SELECT 1 FROM opportunities
    WHERE application_link = 'https://www.mbrwateraward.ae/en/awards/online-application'
);

INSERT INTO opportunities (
    id, title, sponsor_institution, country, sectors, type, status,
    funding_amount, deadline_date, application_link, description_short,
    last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
    'UNESCO-Al Fozan International Prize for the Promotion of Young Scientists in STEM',
    'UNESCO / Al Fozan International Philanthropic Foundation',
    'International',
    ARRAY['Education'],
    'Award',
    'open',
    'USD 100,000 (total prize pool)',
    '2026-11-30',
    'https://www.unesco.org/en/prizes/al-fozan/nomination-process',
    'Biennial UNESCO prize honouring young scientists under 40 in STEM; Saudi-backed through the Al Fozan Foundation.',
    '2026-06-13',
    'Global'
WHERE NOT EXISTS (
    SELECT 1 FROM opportunities
    WHERE application_link = 'https://www.unesco.org/en/prizes/al-fozan/nomination-process'
);

INSERT INTO opportunities (
    id, title, sponsor_institution, country, sectors, type, status,
    funding_amount, deadline_date, application_link, description_short,
    last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
    'SAMA FinTech Regulatory Sandbox',
    'Saudi Central Bank (SAMA)',
    'Saudi Arabia',
    ARRAY['Financial Services'],
    'Regulatory Sandbox',
    'recurring',
    'Regulatory relief and testing environment',
    'recurring',
    'https://sama.gov.sa/en-US/RegulatoryFramework/Pages/FinTech-Sandbox.aspx',
    'SAMA sandbox enabling FinTech companies to test innovative financial products under a live regulatory exemption.',
    '2026-06-13',
    'Saudi Arabia'
WHERE NOT EXISTS (
    SELECT 1 FROM opportunities
    WHERE application_link = 'https://sama.gov.sa/en-US/RegulatoryFramework/Pages/FinTech-Sandbox.aspx'
);

INSERT INTO opportunities (
    id, title, sponsor_institution, country, sectors, type, status,
    funding_amount, deadline_date, application_link, description_short,
    last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
    'Social Development Bank — Working Capital Financing',
    'Social Development Bank (SDB)',
    'Saudi Arabia',
    ARRAY['Financial Services'],
    'Financing',
    'recurring',
    'Up to SAR 2,000,000',
    'recurring',
    'https://www.sdb.gov.sa/en/facilities-financing/working-capital-financing',
    'Working capital financing for Saudi SMEs and entrepreneurs through the Social Development Bank.',
    '2026-06-13',
    'Saudi Arabia'
WHERE NOT EXISTS (
    SELECT 1 FROM opportunities
    WHERE application_link = 'https://www.sdb.gov.sa/en/facilities-financing/working-capital-financing'
);

INSERT INTO opportunities (
    id, title, sponsor_institution, country, sectors, type, status,
    funding_amount, deadline_date, application_link, description_short,
    last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
    'KPMG Private Enterprise Global Tech Innovator Competition 2026',
    'KPMG Private Enterprise',
    'Saudi Arabia',
    ARRAY['Innovation & Entrepreneurship'],
    'Competition',
    'open',
    'Global final visibility + mentorship',
    '2026-07-31',
    'https://kpmg.com/sa/en/home/insights/2025/04/global-tech-innovator.html',
    'Annual global competition for high-growth tech startups; Saudi edition feeds into worldwide final.',
    '2026-06-13',
    'Saudi Arabia'
WHERE NOT EXISTS (
    SELECT 1 FROM opportunities
    WHERE application_link = 'https://kpmg.com/sa/en/home/insights/2025/04/global-tech-innovator.html'
);

INSERT INTO opportunities (
    id, title, sponsor_institution, country, sectors, type, status,
    funding_amount, deadline_date, application_link, description_short,
    last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
    'KAPSARC Postdoctoral Research Fellowship Program',
    'King Abdullah Petroleum Studies and Research Center (KAPSARC)',
    'Saudi Arabia',
    ARRAY['Energy'],
    'Fellowship',
    'recurring',
    'Competitive stipend + research funding',
    'recurring',
    'https://www.kapsarc.org/careers/kapsarc-postdoctoral-program/',
    'Two-year postdoctoral fellowships in energy economics, policy, and technology at KAPSARC in Riyadh.',
    '2026-06-13',
    'Global'
WHERE NOT EXISTS (
    SELECT 1 FROM opportunities
    WHERE application_link = 'https://www.kapsarc.org/careers/kapsarc-postdoctoral-program/'
);

INSERT INTO opportunities (
    id, title, sponsor_institution, country, sectors, type, status,
    funding_amount, deadline_date, application_link, description_short,
    last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
    'Madinah Tech Cultivator',
    'Madinah Tech Cultivator',
    'Saudi Arabia',
    ARRAY['ICT'],
    'Accelerator',
    'closed',
    'Equity-free support + workspace',
    '2026-03-22',
    'https://www.madinahcultivator.com',
    'Madinah-based technology cultivator supporting early-stage startups in the ICT and digital sectors.',
    '2026-06-13',
    'Saudi Arabia'
WHERE NOT EXISTS (
    SELECT 1 FROM opportunities
    WHERE application_link = 'https://www.madinahcultivator.com'
);

INSERT INTO opportunities (
    id, title, sponsor_institution, country, sectors, type, status,
    funding_amount, deadline_date, application_link, description_short,
    last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
    'SparkLabs KSU Fund I — Pre-Seed to Series A VC Fund',
    'SparkLabs Group / King Saud University',
    'Saudi Arabia',
    ARRAY['Innovation & Entrepreneurship'],
    'VC Investment',
    'open',
    'USD 50,000 – USD 500,000',
    'open',
    'https://www.sparklabs.com/programs/ksu-fund',
    'SparkLabs and KSU co-managed fund investing in Saudi and GCC pre-seed through Series A technology startups.',
    '2026-06-13',
    'Saudi Arabia / GCC'
WHERE NOT EXISTS (
    SELECT 1 FROM opportunities
    WHERE application_link = 'https://www.sparklabs.com/programs/ksu-fund'
);

INSERT INTO opportunities (
    id, title, sponsor_institution, country, sectors, type, status,
    funding_amount, deadline_date, application_link, description_short,
    last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
    'Saudi Arabia Special Economic Zones — ECZA Investment Opportunities',
    'Economic Cities and Special Zones Authority (ECZA)',
    'Saudi Arabia',
    ARRAY['Private Sector'],
    'Investment Zone',
    'open',
    'Varies by zone',
    'open',
    'https://ecza.gov.sa/en/investment-opportunities',
    'ECZA manages multiple special economic zones across Saudi Arabia offering tax incentives and streamlined licensing for investors.',
    '2026-06-13',
    'Global'
WHERE NOT EXISTS (
    SELECT 1 FROM opportunities
    WHERE application_link = 'https://ecza.gov.sa/en/investment-opportunities'
);

INSERT INTO opportunities (
    id, title, sponsor_institution, country, sectors, type, status,
    funding_amount, deadline_date, application_link, description_short,
    last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
    'Design in Saudi Arabia with AI (DISAI) — Annual Accelerator',
    'Qualcomm / Saudi Arabia',
    'Saudi Arabia',
    ARRAY['ICT'],
    'Accelerator',
    'closed',
    'Equipment + co-investment',
    '2026-02-15',
    'https://www.qualcomm.com/support/contact/forms/design-in-saudi-arabia',
    'Qualcomm-run annual accelerator for Saudi hardware and AI startups; provides chips, labs, and investment readiness support.',
    '2026-06-13',
    'Saudi Arabia'
WHERE NOT EXISTS (
    SELECT 1 FROM opportunities
    WHERE application_link = 'https://www.qualcomm.com/support/contact/forms/design-in-saudi-arabia'
);

INSERT INTO opportunities (
    id, title, sponsor_institution, country, sectors, type, status,
    funding_amount, deadline_date, application_link, description_short,
    last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
    'Saudi Environment Fund — Incentives and Grants Program',
    'Saudi Environment Fund (SEF)',
    'Saudi Arabia',
    ARRAY['Environment Services'],
    'Grant',
    'open',
    'Varies by project',
    'open',
    'https://www.ef.gov.sa/en/grants',
    'Saudi Environment Fund grants supporting environmental projects, conservation initiatives, and sustainability programs.',
    '2026-06-13',
    'Saudi Arabia'
WHERE NOT EXISTS (
    SELECT 1 FROM opportunities
    WHERE application_link = 'https://www.ef.gov.sa/en/grants'
);

INSERT INTO opportunities (
    id, title, sponsor_institution, country, sectors, type, status,
    funding_amount, deadline_date, application_link, description_short,
    last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
    'KSRelief Humanitarian Partnership Grants',
    'King Salman Humanitarian Aid and Relief Centre (KSRelief)',
    'Saudi Arabia',
    ARRAY['Humanitarian'],
    'Grant',
    'open',
    'Varies by program',
    'open',
    'https://ksrelief.org/en/pages/grants',
    'KSRelief grant partnerships for humanitarian organizations delivering aid and relief programs globally.',
    '2026-06-13',
    'Global'
WHERE NOT EXISTS (
    SELECT 1 FROM opportunities
    WHERE application_link = 'https://ksrelief.org/en/pages/grants'
);

INSERT INTO opportunities (
    id, title, sponsor_institution, country, sectors, type, status,
    funding_amount, deadline_date, application_link, description_short,
    last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
    'Khwarizmi Ventures Fund II — GCC Startup Seed and Series A Investment',
    'Khwarizmi Ventures',
    'Saudi Arabia',
    ARRAY['Innovation & Entrepreneurship'],
    'VC Investment',
    'open',
    'USD 100,000 – USD 2,000,000',
    'open',
    'https://www.khwarizmiventures.com/apply',
    'Saudi VC firm investing in seed to Series A technology startups in the GCC with deep local mentorship network.',
    '2026-06-13',
    'GCC'
WHERE NOT EXISTS (
    SELECT 1 FROM opportunities
    WHERE application_link = 'https://www.khwarizmiventures.com/apply'
);

INSERT INTO opportunities (
    id, title, sponsor_institution, country, sectors, type, status,
    funding_amount, deadline_date, application_link, description_short,
    last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
    'Saudi Export-Import Bank — Export Finance and Trade Programs',
    'Saudi Export-Import Bank (Saudi EXIM)',
    'Saudi Arabia',
    ARRAY['Financial Services'],
    'Financing',
    'open',
    'Varies by program',
    'open',
    'https://ndf.gov.sa/en/fund/exim/',
    'Saudi EXIM Bank financing programs supporting Saudi exporters with trade finance, guarantees, and insurance products.',
    '2026-06-13',
    'Saudi Arabia'
WHERE NOT EXISTS (
    SELECT 1 FROM opportunities
    WHERE application_link = 'https://ndf.gov.sa/en/fund/exim/'
);

INSERT INTO opportunities (
    id, title, sponsor_institution, country, sectors, type, status,
    funding_amount, deadline_date, application_link, description_short,
    last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
    'Jazan City for Primary and Downstream Industries — Investment Opportunities',
    'Jazan City for Primary and Downstream Industries (JCPDI)',
    'Saudi Arabia',
    ARRAY['Industrial & Manufacturing'],
    'Investment Zone',
    'open',
    'Varies by investment',
    'open',
    'https://www.investjcpdi.com/en/investment-opportunities',
    'Industrial city in Jizan offering plots and investment opportunities in petrochemicals, metals, and downstream industries.',
    '2026-06-13',
    'Global'
WHERE NOT EXISTS (
    SELECT 1 FROM opportunities
    WHERE application_link = 'https://www.investjcpdi.com/en/investment-opportunities'
);

INSERT INTO opportunities (
    id, title, sponsor_institution, country, sectors, type, status,
    funding_amount, deadline_date, application_link, description_short,
    last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
    'AlUla Development Company — Investment Opportunities in AlUla',
    'Royal Commission for AlUla (RCU) / UDC',
    'Saudi Arabia',
    ARRAY['Tourism & Quality of Life'],
    'Investment Zone',
    'open',
    'Varies by project',
    'open',
    'https://www.udc.sa/invest',
    'AlUla Development Company offering tourism, hospitality, and heritage investment opportunities in the AlUla region.',
    '2026-06-13',
    'Global'
WHERE NOT EXISTS (
    SELECT 1 FROM opportunities
    WHERE application_link = 'https://www.udc.sa/invest'
);

INSERT INTO opportunities (
    id, title, sponsor_institution, country, sectors, type, status,
    funding_amount, deadline_date, application_link, description_short,
    last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
    'Brinc Hardware and IoT Accelerator — Saudi Arabia Program',
    'Brinc',
    'Saudi Arabia',
    ARRAY['ICT'],
    'Accelerator',
    'recurring',
    'USD 100,000 (investment + support)',
    'recurring',
    'https://brinc.io/programs/saudi-arabia/',
    'Hardware and IoT-focused accelerator by Brinc operating in Saudi Arabia for connected device and deep-tech startups.',
    '2026-06-13',
    'Saudi Arabia / GCC'
WHERE NOT EXISTS (
    SELECT 1 FROM opportunities
    WHERE application_link = 'https://brinc.io/programs/saudi-arabia/'
);

INSERT INTO opportunities (
    id, title, sponsor_institution, country, sectors, type, status,
    funding_amount, deadline_date, application_link, description_short,
    last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
    'Saudi Biotechnology Accelerator — Venture Readiness and R&D Programs',
    'Saudi Biotechnology Company / KACST',
    'Saudi Arabia',
    ARRAY['Pharma & Biotech'],
    'Accelerator',
    'open',
    'Varies by track',
    'open',
    'https://saudi-accelerator.com/apply',
    'Saudi biotech accelerator offering venture readiness programs, R&D support, and lab access for life sciences startups.',
    '2026-06-13',
    'Saudi Arabia'
WHERE NOT EXISTS (
    SELECT 1 FROM opportunities
    WHERE application_link = 'https://saudi-accelerator.com/apply'
);

INSERT INTO opportunities (
    id, title, sponsor_institution, country, sectors, type, status,
    funding_amount, deadline_date, application_link, description_short,
    last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
    'Saudi Agricultural Development Fund — Financing Programs',
    'Saudi Agricultural Development Fund (ADF)',
    'Saudi Arabia',
    ARRAY['Agriculture & Food Processing'],
    'Financing',
    'open',
    'Varies by program',
    'open',
    'https://adf.gov.sa/en/Programs/Pages/default.aspx',
    'ADF financing programs for Saudi agricultural projects, food security initiatives, and agri-business development.',
    '2026-06-13',
    'Saudi Arabia'
WHERE NOT EXISTS (
    SELECT 1 FROM opportunities
    WHERE application_link = 'https://adf.gov.sa/en/Programs/Pages/default.aspx'
);

INSERT INTO opportunities (
    id, title, sponsor_institution, country, sectors, type, status,
    funding_amount, deadline_date, application_link, description_short,
    last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
    'KSRelief Humanitarian Initiatives — Partnership Opportunities',
    'King Salman Humanitarian Aid and Relief Centre (KSRelief)',
    'Saudi Arabia',
    ARRAY['Humanitarian'],
    'Partnership',
    'open',
    'Varies by initiative',
    'open',
    'https://ksrelief.org/en/initiatives',
    'KSRelief partnership opportunities for NGOs and international organizations to co-implement humanitarian initiatives worldwide.',
    '2026-06-13',
    'Global'
WHERE NOT EXISTS (
    SELECT 1 FROM opportunities
    WHERE application_link = 'https://ksrelief.org/en/initiatives'
);
