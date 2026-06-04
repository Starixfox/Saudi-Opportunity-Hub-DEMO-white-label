-- Seed: 20 new investment opportunities (Agent 1–4 pipeline, 2026-06-04)
-- All URLs verified NOT in DB before insert; WHERE NOT EXISTS prevents duplicates.

INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
  'Misk Innovation Diwan — Community Challenge Prize Program',
  'Mohammed bin Salman Foundation (Misk)', 'Saudi Arabia',
  ARRAY['Innovation & Entrepreneurship'], 'Grant / Competition', 'recurring',
  'SAR 50,000 – SAR 150,000 per winning solution', 'recurring',
  'https://hub.misk.org.sa/programs/community/the-innovation-diwan/',
  'Annual crowdsourcing competition awarding SAR 50,000–150,000 prizes to innovative Saudi community solutions across health, environment, education, and economic development challenges.',
  '2026-05-17'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://hub.misk.org.sa/programs/community/the-innovation-diwan/');

INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
  'Misk × Midad Traineeship Program at NUPCO',
  'Mohammed bin Salman Foundation (Misk) / NUPCO', 'Saudi Arabia',
  ARRAY['Healthcare & Life Sciences'], 'Training Program', 'open',
  'Paid traineeship; monthly stipend provided', 'open',
  'https://hub.misk.org.sa/programs/skills/misk-x-midad-program-at-nupco/',
  'Intensive traineeship for Saudi fresh graduates at NUPCO (National Unified Procurement Company for Medical Supplies), developing skills in pharmaceutical supply chain and healthcare operations aligned with Vision 2030.',
  '2026-05-17'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://hub.misk.org.sa/programs/skills/misk-x-midad-program-at-nupco/');

INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
  'Misk 2030 Leaders Program — Senior Leadership Development',
  'Mohammed bin Salman Foundation (Misk)', 'Saudi Arabia',
  ARRAY['Education'], 'Training Program', 'open',
  'Fully sponsored (estimated SAR 179,500 value per cohort)', 'open',
  'https://hub.misk.org.sa/programs/leadership/2030-leaders/',
  '9-month fully sponsored leadership journey for experienced Saudi leaders (10+ years of experience), designed to equip influencers across public, private, and nonprofit sectors to realize Vision 2030. Cohort 7 included 90 leaders from 80+ entities.',
  '2026-05-17'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://hub.misk.org.sa/programs/leadership/2030-leaders/');

INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
  'Arab Monetary Fund — SME Conducive Environment Support Facility',
  'Arab Monetary Fund (AMF)', 'Regional',
  ARRAY['Financial Services'], 'Loan', 'open',
  'Up to 100% of member country paid-up subscription in convertible currencies', 'open',
  'https://www.amf.org.ae/en/programs-support/small-medium-enterprises',
  'AMF concessional financing facility supporting regulatory and financial environment reforms for SMEs across 22 Arab member countries, enabling improved access to credit and business development services for small and medium enterprises.',
  '2026-05-17'::date, 'MENA'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://www.amf.org.ae/en/programs-support/small-medium-enterprises');

INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
  'ALAT — PIF Advanced Manufacturing & Technology Investment Platform',
  'Public Investment Fund (PIF)', 'Saudi Arabia',
  ARRAY['Industrial & Manufacturing'], 'Investment', 'open',
  'USD 100 billion investment platform; partnership and co-investment opportunities', 'open',
  'https://www.pif.gov.sa/en/our-investments/our-portfolio/alat/',
  'PIF''s flagship manufacturing and technology company transforming Saudi Arabia into a global hub for advanced industries including smart appliances, smart health, smart devices, AI data centers, and next-generation infrastructure. Lenovo partnership begins production in 2026.',
  '2026-05-17'::date, 'International'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://www.pif.gov.sa/en/our-investments/our-portfolio/alat/');

INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
  'National Cybersecurity Authority — Innovation & Investment Hub',
  'National Cybersecurity Authority (NCA)', 'Saudi Arabia',
  ARRAY['ICT'], 'Grant', 'open',
  'Multiple tracks: CyberIC accelerator, research pioneer grants, cybersecurity challenges', 'open',
  'https://nca.gov.sa/en/innovation-and-investment/',
  'NCA''s hub for cybersecurity innovation featuring the CyberIC Innovation Program (with NEOM), research pioneer grants for researchers and innovators, annual accelerator cohorts for startups, and cybersecurity challenge competitions.',
  '2026-05-17'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://nca.gov.sa/en/innovation-and-investment/');

INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
  'Hadaf for Leadership — Private Sector Establishments Program',
  'Human Resources Development Fund (HRDF / Hadaf)', 'Saudi Arabia',
  ARRAY['Private Sector'], 'Training Program', 'open',
  'Fully subsidized by HRDF (no cost to participants)', 'open',
  'https://www.hrdf.org.sa/en/products-and-services/programs/facilities/training/hadaf-leadership-program/',
  '12-week free leadership development program for Saudi nationals employed in the private sector (5+ years experience, 2+ years in supervisory role), using in-person, distance, and workplace application training to build next-generation business leaders.',
  '2026-05-17'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://www.hrdf.org.sa/en/products-and-services/programs/facilities/training/hadaf-leadership-program/');

INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
  'TONOMUS "The Next Billion" Venture Competition',
  'TONOMUS (NEOM Technology & Digital Company)', 'Saudi Arabia',
  ARRAY['Innovation & Entrepreneurship'], 'Competition', 'open',
  'USD 1.4 billion committed through Venture Studio; winning teams receive 12-week incubation and seed funding', 'open',
  'https://learn.tonomuscompetitions.com/',
  'Global venture competition from TONOMUS seeking technology-driven ideas to build tomorrow''s cognitive communities. Up to 20 semi-finalists receive expert coaching; up to 4 winning teams join the Venture Studio with Silicon Valley-style incubation and seed investment.',
  '2026-05-17'::date, 'International'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://learn.tonomuscompetitions.com/');

INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
  'SABIC Ventures — Corporate Venture Capital Investment Program',
  'SABIC', 'Saudi Arabia',
  ARRAY['Chemicals'], 'Investment', 'open',
  'USD 20–30 million invested annually; portfolio stage from Seed to Series C', 'open',
  'https://ventures.sabic.com/en/investment-process',
  'SABIC''s corporate VC arm investing in startups in advanced materials, alternative energy, renewable feedstocks, circular economy, agri-nutrients, and cleantech. Assesses strategic fit, technology potential, IP strength, and alignment with global sustainability goals.',
  '2026-05-17'::date, 'International'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://ventures.sabic.com/en/investment-process');

INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
  'Monshaat University Entrepreneurs — Campus Startup Competition',
  'Monshaat (Small and Medium Enterprises General Authority)', 'Saudi Arabia',
  ARRAY['Innovation & Entrepreneurship'], 'Competition', 'open',
  'Prize funding for winning startups (amounts announced per cohort)', 'open',
  'https://monshaat.gov.sa/en/node/334535',
  'Annual Monshaat competition to discover and develop campus-based startups at Saudi universities, providing mentorship, business support services, and prize funding to help student entrepreneurs transform early-stage ideas into scalable ventures.',
  '2026-05-17'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://monshaat.gov.sa/en/node/334535');

INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
  'Badir Soft Landing Program — International Startup Market Entry',
  'Badir Program for Technology Incubators (KACST)', 'Saudi Arabia',
  ARRAY['Innovation & Entrepreneurship'], 'Accelerator', 'open',
  'Incubation support, office space, and market entry facilitation (non-equity)', 'open',
  'https://www.badir.com.sa/en/programs/attract-global-projects',
  'International program attracting foreign startups from the GCC, Arab countries, USA, UK, Europe, and Asia into the Saudi market, providing licensing assistance, government introductions, partnership facilitation, and incubation space across Badir''s 8 nationwide locations.',
  '2026-05-17'::date, 'International'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://www.badir.com.sa/en/programs/attract-global-projects');

INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
  'Badir Accelerator Bootcamps — Tech Startup 90-Day Acceleration',
  'Badir Program for Technology Incubators (KACST)', 'Saudi Arabia',
  ARRAY['Innovation & Entrepreneurship'], 'Accelerator', 'open',
  'Incubation support, mentorship, workshops, and investor access (non-dilutive)', 'open',
  'https://www.badir.com.sa/en/accelerators/bootcamps-badir',
  '90-day tech startup acceleration bootcamp supporting Saudi entrepreneurs in developing ideas into market-ready products, with expert mentorship, specialized workshops, and access to Badir''s investor network across 8 incubator locations in the Kingdom.',
  '2026-05-17'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://www.badir.com.sa/en/accelerators/bootcamps-badir');

INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
  'SDAIA GAIA Accelerator — Leading Businesses in Data & AI',
  'Saudi Data and AI Authority (SDAIA)', 'Saudi Arabia',
  ARRAY['ICT'], 'Accelerator', 'open',
  'SAR 150,000 non-dilutive grant per startup; follow-on investment access', 'open',
  'https://sdaia.gov.sa/en/Investment/Pages/AboutEntrepreneurship.aspx',
  'SDAIA''s GAIA accelerator empowers early-stage AI and data startups with SAR 150,000 non-dilutive grants, institutional mentorship from national AI partners, regulatory advisory support, and connections to Saudi Arabia''s growing AI unicorn ecosystem.',
  '2026-05-17'::date, 'International'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://sdaia.gov.sa/en/Investment/Pages/AboutEntrepreneurship.aspx');

INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
  'HUMAIN — PIF-Backed AI Investment & Partnership Platform',
  'HUMAIN / Public Investment Fund (PIF)', 'Saudi Arabia',
  ARRAY['ICT'], 'Investment', 'open',
  'USD 10 billion venture fund for AI companies; USD 100 billion AI ecosystem', 'open',
  'https://humain.ai/',
  'Saudi Arabia''s flagship AI company backed by PIF, offering strategic partnership and investment opportunities for global AI startups and technology companies across compute infrastructure, foundation models, AI-enabled applications, and intelligent data services.',
  '2026-05-17'::date, 'International'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://humain.ai/');

INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
  'LEAP East 2026 — Startup & Scaleup Pitch Competition',
  'LEAP (Saudi Ministry of Communications and IT)', 'Saudi Arabia',
  ARRAY['Innovation & Entrepreneurship'], 'Competition', 'open',
  'Equity-free prize pool; curated access to 2,000+ investors', 'open',
  'https://leapeast.com/',
  'LEAP East 2026 startup competition connecting global innovators with hundreds of thousands of tech leaders, offering equity-free prize funding, curated investor meetings, and strategic market access in Saudi Arabia for startups from idea stage through growth stage.',
  '2026-05-17'::date, 'International'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://leapeast.com/');

INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
  'Fikra — Monshaat Commercial Innovation & Technology Adoption Portal',
  'Monshaat (Small and Medium Enterprises General Authority)', 'Saudi Arabia',
  ARRAY['Innovation & Entrepreneurship'], 'Grant', 'open',
  'Annual Fikra Innovation Award (amounts vary per cohort)', 'open',
  'https://fikra.monshaat.gov.sa/en/about',
  'Monshaat''s commercial innovation portal connecting Saudi SMEs with 100+ government, private, and nonprofit entities offering 200+ support services; includes an annual award recognizing enterprises that adopt emerging technologies to transform their products or business models.',
  '2026-05-17'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://fikra.monshaat.gov.sa/en/about');

INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
  'Saudi National Gaming & Esports Strategy — Investment & Partnership Program',
  'General Entertainment Authority / Saudi Esports Federation', 'Saudi Arabia',
  ARRAY['Tourism & Quality of Life'], 'Investment', 'open',
  'SAR 50 billion gaming ecosystem investment; partnership and co-investment opportunities available', 'open',
  'https://nges.sa/',
  'Saudi Arabia''s National Gaming & Esports Strategy (NGES) driving SAR 50 billion in ecosystem investment to build a world-class gaming hub, with partnership, co-investment, and market entry opportunities for global gaming companies and esports organizations through Vision 2030.',
  '2026-05-17'::date, 'International'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://nges.sa/');

INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
  'Saudi Esports Federation — Saudi eLeague Prize Competition',
  'Saudi Esports Federation (SEF)', 'Saudi Arabia',
  ARRAY['Tourism & Quality of Life'], 'Competition', 'recurring',
  'SAR 4 million prize pool per season; SAR 1 million grand prize for season champion', 'recurring',
  'https://saudiesports.sa/',
  'Annual Saudi eLeague competition operated by the Saudi Esports Federation, offering SAR 4 million in prize money across Elite, Challenge, Women''s eLeague, and Fighting League tiers for Saudi esports clubs competing under the National Gaming & Esports Strategy.',
  '2026-05-17'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://saudiesports.sa/');

INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
  'Qiddiya — PIF Giga-Project Entertainment & Sports Investment Opportunities',
  'Qiddiya Investment Company (QIC) / Public Investment Fund', 'Saudi Arabia',
  ARRAY['Tourism & Quality of Life'], 'Investment', 'open',
  'Multi-billion SAR development with partnerships across theme parks, sports, and entertainment', 'open',
  'https://www.pif.gov.sa/en/our-investments/giga-projects/qiddiya/',
  'Qiddiya is Saudi Arabia''s Capital of Entertainment, Sports and the Arts — a PIF giga-project offering investment and partnership opportunities for international operators in theme park management, stadium operations, immersive entertainment, branded attractions, and hospitality ventures.',
  '2026-05-17'::date, 'International'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://www.pif.gov.sa/en/our-investments/giga-projects/qiddiya/');

INSERT INTO opportunities (
  id, title, sponsor_institution, country, sectors, type, status,
  funding_amount, deadline_date, application_link, description_short,
  last_verified, eligibility_region
)
SELECT gen_random_uuid()::text,
  'Ma''aden Tharwah — Local Content & Supplier Development Program',
  'Saudi Arabian Mining Company (Ma''aden)', 'Saudi Arabia',
  ARRAY['Mining & Metals'], 'Investment', 'open',
  'SAR 55 billion in goods and services procurement by 2040; SAR 88 billion total GDP impact', 'open',
  'https://www.maaden.com.sa/en/sustainability/localcontent',
  'Ma''aden''s Tharwah (Wealth) local content program connecting Saudi and international suppliers to mining supply chain and downstream investment opportunities, with technical support, fast-track supplier registration, framework agreements, and funding introductions.',
  '2026-05-17'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://www.maaden.com.sa/en/sustainability/localcontent');
