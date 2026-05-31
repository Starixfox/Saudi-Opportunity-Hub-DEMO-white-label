-- 20 new verified opportunities - Saudi Opportunity Hub - 2026-05-31

-- 1. Women's Health Accelerator Program
INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT
  gen_random_uuid()::text,
  'Women''s Health Accelerator Program',
  'Flat6Labs & Organon',
  'Regional (META)',
  ARRAY['Healthcare & Life Sciences'],
  'Accelerator',
  'recurring',
  NULL,
  'recurring',
  'https://flat6labs.com/program/womens-health-accelerator-program/',
  'Supports FemTech and women''s health startups across Middle East, Turkey & Africa (META) with mentorship, market-fit testing, and investor access; 3rd edition active in 2026.',
  '2026-05-31'::date,
  'META (Middle East, Turkey & Africa)'
WHERE NOT EXISTS (
  SELECT 1 FROM opportunities WHERE application_link = 'https://flat6labs.com/program/womens-health-accelerator-program/'
);

-- 2. Nawah Pre-Accelerator Program
INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT
  gen_random_uuid()::text,
  'Nawah Pre-Accelerator Program',
  'Flat6Labs & Google for Startups',
  'Palestine',
  ARRAY['Innovation & Entrepreneurship'],
  'Pre-Accelerator',
  'open',
  NULL,
  'open',
  'https://flat6labs.com/program/nawah-pre-accelerator-program/',
  'Google for Startups-backed pre-accelerator empowering Palestinian founders to build viable tech startups; 2026 cycle runs April–July 2026.',
  '2026-05-31'::date,
  'Palestine'
WHERE NOT EXISTS (
  SELECT 1 FROM opportunities WHERE application_link = 'https://flat6labs.com/program/nawah-pre-accelerator-program/'
);

-- 3. Misk Investment Manager Training Bootcamp
INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT
  gen_random_uuid()::text,
  'Investment Manager Training Bootcamp',
  'Misk Foundation',
  'Saudi Arabia',
  ARRAY['Innovation & Entrepreneurship'],
  'Training Program',
  'open',
  NULL,
  'open',
  'https://hub.misk.org.sa/programs/entrepreneurship/investment-manager-training-bootcamp/',
  'Misk Foundation''s structured bootcamp (August 2026–January 2027) developing aspiring Saudi investment managers through theory, practice, and expert mentorship.',
  '2026-05-31'::date,
  'Saudi Arabia'
WHERE NOT EXISTS (
  SELECT 1 FROM opportunities WHERE application_link = 'https://hub.misk.org.sa/programs/entrepreneurship/investment-manager-training-bootcamp/'
);

-- 4. SEEC Energy Efficiency Certification Training Programs
INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT
  gen_random_uuid()::text,
  'SEEC Energy Efficiency Certification Training Programs 2026',
  'Saudi Energy Efficiency Center (SEEC)',
  'Saudi Arabia',
  ARRAY['Energy'],
  'Training Program',
  'open',
  NULL,
  'open',
  'https://www.seec.gov.sa/en/online-services/training-programs',
  'Government-supported training for CEM, CEA, and CMVP energy certifications building Saudi expertise in energy management, aligned with Vision 2030 efficiency targets.',
  '2026-05-31'::date,
  'Saudi Arabia'
WHERE NOT EXISTS (
  SELECT 1 FROM opportunities WHERE application_link = 'https://www.seec.gov.sa/en/online-services/training-programs'
);

-- 5. IsDB-ITFC Scholarship in International Trade
INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT
  gen_random_uuid()::text,
  'IsDB-ITFC Scholarship Program in International Trade',
  'Islamic Development Bank (IsDB) & International Islamic Trade Finance Corporation (ITFC)',
  'Saudi Arabia',
  ARRAY['Education'],
  'Scholarship',
  'closed',
  NULL,
  '2026-01-31',
  'https://www.isdb.org/scholarships/isdb-itfc-scholarship-program-in-international-trade',
  'Joint scholarship for postgraduate students from IsDB member countries in international trade finance, strengthening regional trade expertise. Deadline: January 31, 2026.',
  '2026-05-31'::date,
  'IsDB Member Countries'
WHERE NOT EXISTS (
  SELECT 1 FROM opportunities WHERE application_link = 'https://www.isdb.org/scholarships/isdb-itfc-scholarship-program-in-international-trade'
);

-- 6. QRDI Small Business Innovation Grant Program Qatar
INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT
  gen_random_uuid()::text,
  'Small Business Innovation Grant Program (SBIG) – Qatar',
  'Qatar Research, Development and Innovation Council (QRDI)',
  'Qatar',
  ARRAY['Innovation & Entrepreneurship'],
  'Grant',
  'closed',
  'Up to QAR 3,000,000 per project (Phase I: QAR 800K + Phase II: QAR 2.2M)',
  '2025-08-04',
  'https://portal365.org/en/grants/SmallBusinessInnovationGrantProgramQatar',
  'QRDI''s non-dilutive phased competitive grant for Qatar-based SMEs commercializing novel technologies in healthcare, supply chain, and sustainable urban development.',
  '2026-05-31'::date,
  'Qatar'
WHERE NOT EXISTS (
  SELECT 1 FROM opportunities WHERE application_link = 'https://portal365.org/en/grants/SmallBusinessInnovationGrantProgramQatar'
);

-- 7. Oman Development Bank SME Finance
INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT
  gen_random_uuid()::text,
  'Oman Development Bank (ODB) SME Finance Program',
  'Oman Development Bank',
  'Oman',
  ARRAY['Financial Services'],
  'Financing',
  'open',
  'OMR 5,000 to OMR 1,000,000',
  'open',
  'https://odb.om/service/SME-Finance',
  'ODB''s concessional loan facility for Omani SMEs across priority sectors (agriculture, fisheries, manufacturing, tourism, healthcare) at 3% rate with online applications.',
  '2026-05-31'::date,
  'Oman'
WHERE NOT EXISTS (
  SELECT 1 FROM opportunities WHERE application_link = 'https://odb.om/service/SME-Finance'
);

-- 8. JEDCO Jordan Programs
INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT
  gen_random_uuid()::text,
  'JEDCO SME & Startup Support Programs',
  'Jordan Enterprise Development Corporation (JEDCO)',
  'Jordan',
  ARRAY['Private Sector'],
  'Grant & Technical Support',
  'open',
  'Up to JOD 100,000 per enterprise',
  'open',
  'https://jedco.gov.jo/EN/List/JEDCO_Programs',
  'JEDCO''s portfolio of programs providing financial and technical support to Jordanian SMEs and entrepreneurs across industrial, agricultural, tourism, and creative sectors.',
  '2026-05-31'::date,
  'Jordan'
WHERE NOT EXISTS (
  SELECT 1 FROM opportunities WHERE application_link = 'https://jedco.gov.jo/EN/List/JEDCO_Programs'
);

-- 9. KAUST Innovation Fund
INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT
  gen_random_uuid()::text,
  'KAUST Innovation Fund – Call for Applicants',
  'King Abdullah University of Science and Technology (KAUST)',
  'Saudi Arabia',
  ARRAY['Innovation & Entrepreneurship'],
  'Venture Capital',
  'open',
  'Seed up to USD 200,000; Early-stage up to USD 2,000,000',
  'open',
  'https://innovation.kaust.edu.sa/event/innovation-fund-call-for-applicants/',
  'KAUST Innovation Fund accepts rolling applications from deep-tech startups with breakthrough technologies, investing from seed (<$200K) to early-stage (up to $2M).',
  '2026-05-31'::date,
  'Saudi Arabia / International'
WHERE NOT EXISTS (
  SELECT 1 FROM opportunities WHERE application_link = 'https://innovation.kaust.edu.sa/event/innovation-fund-call-for-applicants/'
);

-- 10. WISE EdTech Accelerator
INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT
  gen_random_uuid()::text,
  'WISE EdTech Accelerator',
  'World Innovation Summit for Education (WISE) / Qatar Foundation',
  'Qatar',
  ARRAY['Education'],
  'Accelerator',
  'open',
  'USD 50,000 in-kind support per startup (International Track)',
  'open',
  'https://wise-qatar.org/wise-works/edtech-accelerator/',
  'Qatar Foundation''s annual dual-track EdTech accelerator (local Qatar and international) for pre-Series A startups, offering mentorship, coaching, and investor connectivity.',
  '2026-05-31'::date,
  'Global / Qatar'
WHERE NOT EXISTS (
  SELECT 1 FROM opportunities WHERE application_link = 'https://wise-qatar.org/wise-works/edtech-accelerator/'
);

-- 11. Climate Finance Accelerator Egypt
INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT
  gen_random_uuid()::text,
  'Climate Finance Accelerator (CFA) Egypt',
  'Flat6Labs & UK Government (DESNZ / ICF)',
  'Egypt',
  ARRAY['Environment Services'],
  'Accelerator',
  'recurring',
  NULL,
  'recurring',
  'https://flat6labs.com/program/climate-finance-accelerator-program/',
  'UK Government DESNZ-funded 16-week accelerator for Egyptian climate mitigation entrepreneurs with low-carbon solutions, targeting 8-12 startups per cohort with investor readiness support.',
  '2026-05-31'::date,
  'Egypt'
WHERE NOT EXISTS (
  SELECT 1 FROM opportunities WHERE application_link = 'https://flat6labs.com/program/climate-finance-accelerator-program/'
);

-- 12. Ebtekar Agri Digital Acceleration
INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT
  gen_random_uuid()::text,
  'Ebtekar Agri Digital Acceleration Program',
  'Flat6Labs & GIZ',
  'Egypt',
  ARRAY['Agriculture & Food Processing'],
  'Accelerator',
  'recurring',
  NULL,
  'recurring',
  'https://flat6labs.com/program/ebtekar/',
  'GIZ and Flat6Labs'' program accelerating Egyptian agri-digital and water conservation startups in IoT, smart farming, precision agriculture, AI, and agri-SaaS solutions.',
  '2026-05-31'::date,
  'Egypt'
WHERE NOT EXISTS (
  SELECT 1 FROM opportunities WHERE application_link = 'https://flat6labs.com/program/ebtekar/'
);

-- 13. UM6P Ventures Call for Startups
INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT
  gen_random_uuid()::text,
  'UM6P Ventures – Call for Startups',
  'University Mohammed VI Polytechnic (UM6P)',
  'Morocco',
  ARRAY['Innovation & Entrepreneurship'],
  'Venture Capital',
  'open',
  'USD 100,000 to USD 500,000',
  'open',
  'https://um6pventures.com/call-for-startups',
  'UM6P Ventures invests USD 100K–500K at pre-seed/seed in Moroccan AgriTech, GreenTech, and HealthTech startups, with UM6P lab access and expert network support.',
  '2026-05-31'::date,
  'Morocco / Moroccan Diaspora'
WHERE NOT EXISTS (
  SELECT 1 FROM opportunities WHERE application_link = 'https://um6pventures.com/call-for-startups'
);

-- 14. Ibtikar Fund
INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT
  gen_random_uuid()::text,
  'Ibtikar Fund – Palestinian Startup Investment',
  'Ibtikar Fund',
  'Palestine',
  ARRAY['Innovation & Entrepreneurship'],
  'Venture Capital',
  'open',
  'USD 500,000 per investment (seed / pre-Series A)',
  'open',
  'https://ibtikarfund.com/',
  'IFC- and EBRD-backed Palestinian VC fund (Fund II: $25M) investing in tech-enabled startups led by Palestinian founders in the West Bank, Gaza, and MENA region.',
  '2026-05-31'::date,
  'Palestine / MENA'
WHERE NOT EXISTS (
  SELECT 1 FROM opportunities WHERE application_link = 'https://ibtikarfund.com/'
);

-- 15. YTB-IsDB Joint Scholarship 2026
INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT
  gen_random_uuid()::text,
  'YTB–IsDB Joint Scholarship Program 2026',
  'Türkiye Scholarships (YTB) & Islamic Development Bank (IsDB)',
  'Turkey',
  ARRAY['Education'],
  'Scholarship',
  'closed',
  NULL,
  '2026-02-20',
  'https://www.turkiyeburslari.gov.tr/announcements/ytb-islamic-development-bank-isdb-joint-scholarship-program-2026-applicaiton-period-122',
  'Co-funded by YTB and IsDB, offering full scholarships (tuition, stipend, housing, airfare) to students from IsDB member countries studying at Turkish universities; 2026 cycle closed Feb 20.',
  '2026-05-31'::date,
  'IsDB Member Countries'
WHERE NOT EXISTS (
  SELECT 1 FROM opportunities WHERE application_link = 'https://www.turkiyeburslari.gov.tr/announcements/ytb-islamic-development-bank-isdb-joint-scholarship-program-2026-applicaiton-period-122'
);

-- 16. SMEF Inma Fund Oman
INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT
  gen_random_uuid()::text,
  'SMEF Inma Fund – SME Financing 2026',
  'SME Development Fund (Inma) / SMEF Oman',
  'Oman',
  ARRAY['Financial Services'],
  'Financing',
  'open',
  'OMR 33,000,000 total allocation for 2026',
  'open',
  'https://www.smefoman.com/',
  'Oman''s SMEF Inma Fund has allocated OMR 33M for 2026 SME financing across tourism, services, industry, and trade with flexible repayment terms up to 8 years.',
  '2026-05-31'::date,
  'Oman'
WHERE NOT EXISTS (
  SELECT 1 FROM opportunities WHERE application_link = 'https://www.smefoman.com/'
);

-- 17. GGJAP Green Growth and Jobs Accelerator
INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT
  gen_random_uuid()::text,
  'Green Growth and Jobs Accelerator Project (GGJAP)',
  'UNDP & Flat6Labs (Danish-Arab Partnership Program)',
  'Regional (MENA)',
  ARRAY['Environment Services'],
  'Accelerator',
  'closed',
  NULL,
  '2026-04-16',
  'https://flat6labs.com/program/ggjap/',
  'UNDP and Flat6Labs'' 2023–2027 MENA program supporting SMEs in Morocco, Tunisia, Egypt, Jordan, and Algeria to transition to greener operations and create sustainable green jobs.',
  '2026-05-31'::date,
  'MENA (Morocco, Tunisia, Egypt, Jordan, Algeria)'
WHERE NOT EXISTS (
  SELECT 1 FROM opportunities WHERE application_link = 'https://flat6labs.com/program/ggjap/'
);

-- 18. Bidaya Entrepreneurship Program Bahrain
INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT
  gen_random_uuid()::text,
  'Bidaya Entrepreneurship Training Program',
  'Hope Ventures Bahrain',
  'Bahrain',
  ARRAY['Innovation & Entrepreneurship'],
  'Pre-Accelerator',
  'recurring',
  'BHD 10,000 equity investment per startup (up to 2 winners per cohort)',
  'recurring',
  'https://hopefund.bh/program/bidaya/',
  'Hope Ventures Bahrain''s pre-accelerator training Bahraini founders from ideation to MVP, with BHD 10,000 equity investment per selected startup upon Demo Day.',
  '2026-05-31'::date,
  'Bahrain'
WHERE NOT EXISTS (
  SELECT 1 FROM opportunities WHERE application_link = 'https://hopefund.bh/program/bidaya/'
);

-- 19. Themar AgriTech Acceleration
INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT
  gen_random_uuid()::text,
  'Themar AgriTech Acceleration Program',
  'Flat6Labs & SANAD Entrepreneurship Academy',
  'Egypt',
  ARRAY['Agriculture & Food Processing'],
  'Accelerator',
  'recurring',
  NULL,
  'recurring',
  'https://flat6labs.com/program/themar/',
  'Flat6Labs and SANAD Academy''s 2-month accelerator supporting 10–12 Egyptian agritech startups per cycle in smart farming, precision agriculture, agri-SaaS, and agri-logistics.',
  '2026-05-31'::date,
  'Egypt'
WHERE NOT EXISTS (
  SELECT 1 FROM opportunities WHERE application_link = 'https://flat6labs.com/program/themar/'
);

-- 20. DICE Program
INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT
  gen_random_uuid()::text,
  'DICE Program – Developing Inclusive and Creative Economies',
  'Flat6Labs, Hatch Ideas & British Council',
  'Egypt',
  ARRAY['Innovation & Entrepreneurship'],
  'Accelerator',
  'recurring',
  'EGP 225,000 total prize money (top 3 startups)',
  'recurring',
  'https://flat6labs.com/program/dice-program/',
  'British Council-funded creative economy accelerator by Flat6Labs and Hatch Ideas, empowering Egyptian social and creative startups with mentorship, training, and EGP 225K in prizes.',
  '2026-05-31'::date,
  'Egypt'
WHERE NOT EXISTS (
  SELECT 1 FROM opportunities WHERE application_link = 'https://flat6labs.com/program/dice-program/'
);
