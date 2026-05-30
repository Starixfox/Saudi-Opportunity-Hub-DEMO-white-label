-- Migration: Add 20 new verified opportunities (pipeline run 2026-05-30)
-- Sectors covered: ICT, Financial Services, Agriculture & Food Processing,
-- Industrial & Manufacturing, Innovation & Entrepreneurship, Mining & Metals,
-- Tourism & Quality of Life, Private Sector, Energy, Transport & Logistics,
-- Humanitarian, Education, Healthcare & Life Sciences, Environment Services

-- 1. TONOMUS Venture Studio (ICT – Saudi Arabia)
INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'TONOMUS Venture Studio', 'TONOMUS', 'Saudi Arabia', ARRAY['ICT'], 'accelerator', 'open', NULL, 'open', 'https://tonomus.neom.com/en-us/what-we-do/venture-studio', 'TONOMUS''s venture-building arm inside NEOM, creating AI-and-technology startups with equity co-investment, 12-week build sprints, and Silicon Valley expert support.', '2026-05-17'::date, 'Global_including_Saudi'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://tonomus.neom.com/en-us/what-we-do/venture-studio');

-- 2. Arab Trade Financing Program (Financial Services – UAE)
INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Arab Trade Financing Program (ATFP)', 'Arab Trade Financing Program (ATFP)', 'UAE', ARRAY['Financial Services'], 'financing', 'open', NULL, 'open', 'https://atfp.org.ae', 'Pan-Arab trade finance institution with $1B authorized capital providing concessional export and import financing to Arab producers and exporters through national agency banks.', '2026-05-17'::date, 'MENA'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://atfp.org.ae');

-- 3. AAAID Agricultural Investment (Agriculture & Food Processing – Global/Arab)
INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'AAAID Agricultural Investment Program', 'Arab Authority for Agricultural Investment and Development (AAAID)', 'Global', ARRAY['Agriculture & Food Processing'], 'investment_program', 'open', NULL, 'open', 'https://www.aaaid.org/en/apply-investment', 'AAAID offers Arab investors equity partnerships, revolving loans, and co-investment in agricultural and agri-food companies across 21 Arab member states, with ~$1.1B capital base.', '2026-05-17'::date, 'MENA'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://www.aaaid.org/en/apply-investment');

-- 4. Land and Industrial Loan Program (Industrial & Manufacturing – Saudi Arabia)
INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Land and Industrial Loan Program', 'MODON & Saudi Industrial Development Fund (SIDF)', 'Saudi Arabia', ARRAY['Industrial & Manufacturing'], 'financing', 'open', NULL, 'open', 'https://www.landloan.gov.sa', 'Joint MODON–SIDF product enabling industrial investors to apply once for both an industrial land allocation and a project loan, with annual rent discounts in early production years.', '2026-05-17'::date, 'Global_including_Saudi'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://www.landloan.gov.sa');

-- 5. startAD Corporate Sprint Accelerator (Innovation & Entrepreneurship – UAE)
INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'startAD Corporate Sprint Accelerator', 'startAD (NYU Abu Dhabi)', 'UAE', ARRAY['Innovation & Entrepreneurship'], 'accelerator', 'open', 'USD 50,000–250,000', 'open', 'https://startad.ae/programs/csa/', 'NYU Abu Dhabi accelerator connecting GCC startups with corporations and government entities, offering seed funding up to $250K, corporate pilots, mentorship, and investor access.', '2026-05-17'::date, 'GCC'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://startad.ae/programs/csa/');

-- 6. MODON Industrial Lands Leasing (Industrial & Manufacturing – Saudi Arabia)
INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'MODON Industrial Lands Leasing Program', 'Saudi Authority for Industrial Cities and Technology Zones (MODON)', 'Saudi Arabia', ARRAY['Industrial & Manufacturing'], 'investment_program', 'open', NULL, 'open', 'https://modon.gov.sa/en/Products/industrial/Pages/industriallands.aspx', 'MODON offers regulated industrial land plots for lease across 36+ Saudi industrial cities, enabling investors to establish licensed manufacturing operations with 16-day permitting.', '2026-05-17'::date, 'Global_including_Saudi'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://modon.gov.sa/en/Products/industrial/Pages/industriallands.aspx');

-- 7. MODON Ready-Built Factories (Industrial & Manufacturing – Saudi Arabia)
INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'MODON Ready-Built Factories Program', 'Saudi Authority for Industrial Cities and Technology Zones (MODON)', 'Saudi Arabia', ARRAY['Industrial & Manufacturing'], 'investment_program', 'open', NULL, 'open', 'https://modon.gov.sa/en/Products/ReadyBuildings/Pages/About.aspx', 'MODON''s ready-built factory units in Saudi industrial cities let investors start production immediately without construction, with rent deferral linked to industrial loan approval.', '2026-05-17'::date, 'Global_including_Saudi'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://modon.gov.sa/en/Products/ReadyBuildings/Pages/About.aspx');

-- 8. ADF Development Loan Services (Agriculture & Food Processing – Saudi Arabia)
INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Saudi Agricultural Development Fund – Development Loan Services', 'Agricultural Development Fund (ADF)', 'Saudi Arabia', ARRAY['Agriculture & Food Processing'], 'financing', 'open', NULL, 'open', 'https://adf.gov.sa/en/ServicesCatalog/Pages/Services100.aspx', 'ADF provides soft, interest-free development loans to Saudi farmers, livestock breeders, fisheries operators, agro-processors, and rural enterprises across all regions of the Kingdom.', '2026-05-17'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://adf.gov.sa/en/ServicesCatalog/Pages/Services100.aspx');

-- 9. Tamkeen AI Skills Training (ICT – Bahrain)
INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Tamkeen AI Skills Training Initiative (50,000 Bahrainis)', 'Tamkeen (Labour Fund Bahrain)', 'Bahrain', ARRAY['ICT'], 'Training Program', 'open', NULL, 'open', 'https://www.tamkeen.bh/en/ai-training-bundles/', 'Tamkeen''s initiative to train 50,000 Bahrainis in AI by 2030 via three subsidized tracks: AI for Executives, AI Generalists, and AI Specialists, open to Bahraini private-sector employees.', '2026-05-17'::date, 'Bahrain'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://www.tamkeen.bh/en/ai-training-bundles/');

-- 10. SFD Saudi Export Program Financing (Financial Services – Saudi Arabia)
INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Saudi Export Program (SEP) Financing Facilities', 'Saudi Fund for Development (SFD)', 'Saudi Arabia', ARRAY['Financial Services'], 'financing', 'open', 'Up to 100% of export transaction value', 'open', 'https://www.sfd.gov.sa/en/node/87', 'SFD''s Saudi Export Program offers direct/indirect financing and credit insurance for Saudi non-oil national exporters, covering up to 100% of transaction value with 1–12 year repayment terms.', '2026-05-17'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://www.sfd.gov.sa/en/node/87');

-- 11. SGS National Fund for Exploration Services (Mining & Metals – Saudi Arabia)
INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Saudi Geological Survey – National Fund for Exploration Services', 'Saudi Geological Survey (SGS)', 'Saudi Arabia', ARRAY['Mining & Metals'], 'grant', 'open', 'Up to 50% co-funding of exploration capital', 'open', 'https://sgs.gov.sa/en/pages/sgs-initiatives', 'SGS co-funds geological exploration activities for SMEs (up to 50% of capital costs) and shares accelerated geoscience data to attract mining investors and develop Saudi mineral resources.', '2026-05-17'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://sgs.gov.sa/en/pages/sgs-initiatives');

-- 12. DGDA Partner & Vendor Program (Tourism & Quality of Life – Saudi Arabia)
INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Diriyah Gate Development Authority – Partner & Vendor Program', 'Diriyah Gate Development Authority (DGDA)', 'Saudi Arabia', ARRAY['Tourism & Quality of Life'], 'tender', 'open', NULL, 'open', 'https://dgda.gov.sa/Partner', 'DGDA''s vendor qualification and partner program inviting contractors, consultants, and service companies to register for tenders and business partnerships on the Diriyah heritage mega-development.', '2026-05-17'::date, 'Global_including_Saudi'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://dgda.gov.sa/Partner');

-- 13. SDB Business Franchise Financing (Private Sector – Saudi Arabia)
INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Saudi Social Development Bank – Business Franchise Financing Program', 'Saudi Social Development Bank (SDB)', 'Saudi Arabia', ARRAY['Private Sector'], 'financing', 'open', 'Up to SAR 4,000,000', 'open', 'https://www.sdb.gov.sa/en/facilities/facilities-financing/business-franchise-program/', 'SDB financing up to SAR 4M for Saudi nationals to establish franchise businesses, with up to 8-year repayment, 7% admin fee, and fully digital application — no branch visit required.', '2026-05-17'::date, 'Saudi_only'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://www.sdb.gov.sa/en/facilities/facilities-financing/business-franchise-program/');

-- 14. Masdar WiSER Pioneers Program (Energy – UAE/Global)
INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Masdar WiSER Pioneers Program 2026', 'Masdar (Abu Dhabi Future Energy Company)', 'UAE', ARRAY['Energy'], 'fellowship', 'open', NULL, 'open', 'https://masdar.ae/en/strategic-global-initiatives/wiser/wiser-pioneers-program', 'Year-long global program for women aged 25–35 in sustainability, energy, and STEM, offering workshops, one-to-one mentoring, and global networking to develop female clean-energy leaders.', '2026-05-17'::date, 'Global_including_Saudi'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://masdar.ae/en/strategic-global-initiatives/wiser/wiser-pioneers-program');

-- 15. NIDLP Logistics Private Sector Engagement Council (Transport & Logistics – Saudi Arabia)
INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'NIDLP Logistics Private Sector Engagement Council', 'National Industrial Development and Logistics Program (NIDLP)', 'Saudi Arabia', ARRAY['Transport & Logistics'], 'investment_program', 'open', NULL, 'open', 'https://lpsec.nidlp.gov.sa/en', 'Saudi logistics private-sector council under NIDLP, enabling logistics companies to shape policy, resolve sector challenges, and access government partnerships to position Saudi Arabia as a global logistics hub.', '2026-05-17'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://lpsec.nidlp.gov.sa/en');

-- 16. KSrelief Specific Humanitarian Programs (Humanitarian – Saudi Arabia)
INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'KSrelief Specific Humanitarian Programs', 'King Salman Humanitarian Aid and Relief Centre (KSrelief)', 'Saudi Arabia', ARRAY['Humanitarian'], 'grant', 'open', NULL, 'open', 'https://www.ksrelief.org/en/Programs/ProgramsList', 'KSrelief''s portfolio of specific humanitarian programs including Masam landmine clearance in Yemen, rehabilitation of conflict-affected children, and artificial limbs delivery across crisis zones.', '2026-05-17'::date, 'Global_including_Saudi'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://www.ksrelief.org/en/Programs/ProgramsList');

-- 17. MoE Scholarships at Saudi Public Universities (Education – Saudi Arabia)
INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Ministry of Education – Scholarships at Saudi Public Universities', 'Saudi Ministry of Education (MoE)', 'Saudi Arabia', ARRAY['Education'], 'grant', 'open', NULL, 'recurring', 'https://moe.gov.sa/en/education/ResidentsAndvisitors/pages/publicuniversitiesscholarships.aspx', 'Saudi MoE fully-funded scholarships for international students at 27 Saudi public universities, covering tuition, housing, and living allowances for distinguished students in scientific disciplines.', '2026-05-17'::date, 'Global_including_Saudi'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://moe.gov.sa/en/education/ResidentsAndvisitors/pages/publicuniversitiesscholarships.aspx');

-- 18. NHRSP National Health Research Portal (Healthcare & Life Sciences – Saudi Arabia)
INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'National Health Research and Studies Portal (NHRSP)', 'Saudi Health Council (SHC)', 'Saudi Arabia', ARRAY['Healthcare & Life Sciences'], 'Research Grant', 'open', NULL, 'open', 'https://nhrsp.shc.gov.sa/Home/About', 'Saudi Health Council''s NHRSP facilitates funded national health research collaborations, enabling researchers and health institutions to access and participate in priority-driven health studies aligned with Vision 2030.', '2026-05-17'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://nhrsp.shc.gov.sa/Home/About');

-- 19. Saudi Environment Fund Incentives & Grants (Environment Services – Saudi Arabia)
INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Saudi Environment Fund – Incentives and Grants Program', 'Saudi Environment Fund', 'Saudi Arabia', ARRAY['Environment Services'], 'grant', 'open', NULL, 'open', 'https://efund.ef.gov.sa/about-program', 'National initiative supporting Saudi Arabia''s transition to environmental sustainability, stimulating investment in meteorology, waste management, wildlife conservation, circular economy, and eco-tech.', '2026-05-17'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://efund.ef.gov.sa/about-program');

-- 20. SEEC Energy Efficiency Project Opportunities (Energy – Saudi Arabia)
INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'SEEC Energy Efficiency Project Opportunities', 'Saudi Energy Efficiency Center (SEEC)', 'Saudi Arabia', ARRAY['Energy'], 'investment_program', 'open', NULL, 'open', 'https://www.seec.gov.sa/en/online-services/energy-efficiency-project-opportunities', 'SEEC''s Foras platform connecting facility owners with licensed energy-efficiency service providers, enabling energy performance contracting and efficiency upgrade projects across Saudi Arabia.', '2026-05-17'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://www.seec.gov.sa/en/online-services/energy-efficiency-project-opportunities');
