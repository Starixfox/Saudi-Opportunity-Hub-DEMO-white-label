-- 19 new investment opportunities added via Agent 1-4 pipeline (2026-06-03)
-- All records verified: URL liveness, primary source, data accuracy
-- Dedup guard: WHERE NOT EXISTS on application_link

INSERT INTO opportunities (id, title, description_short, type, sponsor_institution, country, eligibility_region, funding_amount, funding_type, application_link, deadline_date, status, language, sectors, "isNew", last_verified)
SELECT gen_random_uuid()::text, 'IGNITE Saudi Digital Content Program',
  'Saudi Arabia''s SAR 4.2B digital content program with 36 initiatives supporting startups in gaming, film, digital advertising, and creative digital content sectors under Vision 2030.',
  'Government Program', 'Digital Content Council', 'Saudi Arabia', 'Saudi Arabia',
  'SAR 4.2B total program (36 initiatives)', 'Grant', 'https://ignite.gov.sa/en',
  'open', 'open', 'English', ARRAY['ICT'], true, '2026-06-03'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://ignite.gov.sa/en');

INSERT INTO opportunities (id, title, description_short, type, sponsor_institution, country, eligibility_region, funding_amount, funding_type, application_link, deadline_date, status, language, sectors, "isNew", last_verified)
SELECT gen_random_uuid()::text, 'Ashoka Arab World Fellowship',
  'Ashoka Arab World Fellowship identifying and supporting leading social entrepreneurs across the Arab World with lifetime fellowship membership, financial support, professional services, and access to Ashoka''s global network of changemakers.',
  'Fellowship', 'Ashoka Arab World', 'Saudi Arabia', 'Arab_World',
  'Financial stipend + professional services', 'Grant', 'https://ashoka.org/en-aaw/program/ashoka-arab-world-fellowship',
  'open', 'open', 'English', ARRAY['Innovation & Entrepreneurship'], true, '2026-06-03'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://ashoka.org/en-aaw/program/ashoka-arab-world-fellowship');

INSERT INTO opportunities (id, title, description_short, type, sponsor_institution, country, eligibility_region, funding_amount, funding_type, application_link, deadline_date, status, language, sectors, "isNew", last_verified)
SELECT gen_random_uuid()::text, 'Startupbootcamp Energy & Climate III',
  'Startupbootcamp Energy & Climate accelerator program cohort III supporting startups innovating in clean energy, climate tech, and sustainable solutions with mentorship, investment readiness, and corporate partner connections across the MENA region.',
  'Accelerator', 'Startupbootcamp', 'Saudi Arabia', 'Global_including_Saudi',
  'EUR 15,000 + in-kind support', 'Grant', 'https://startupbootcamp.org/energy-climate-3',
  'open', 'open', 'English', ARRAY['Energy'], true, '2026-06-03'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://startupbootcamp.org/energy-climate-3');

INSERT INTO opportunities (id, title, description_short, type, sponsor_institution, country, eligibility_region, funding_amount, funding_type, application_link, deadline_date, status, language, sectors, "isNew", last_verified)
SELECT gen_random_uuid()::text, 'SDAIA Personal Data Protection Regulatory Sandbox',
  'Periodic regulatory sandbox by SDAIA allowing startups and companies to test innovative personal data protection and AI solutions under Saudi Arabia''s Personal Data Protection Law (PDPL) in a secure, controlled environment.',
  'Regulatory Sandbox', 'Saudi Data and Artificial Intelligence Authority (SDAIA)', 'Saudi Arabia', 'Saudi Arabia',
  'Regulatory support and flexible testing framework', 'other', 'https://dgp.sdaia.gov.sa',
  'recurring', 'recurring', 'English', ARRAY['ICT'], true, '2026-06-03'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://dgp.sdaia.gov.sa');

INSERT INTO opportunities (id, title, description_short, type, sponsor_institution, country, eligibility_region, funding_amount, funding_type, application_link, deadline_date, status, language, sectors, "isNew", last_verified)
SELECT gen_random_uuid()::text, 'ABHI Middle East Accelerator',
  'UK-based health tech accelerator by ABHI (Association of British HealthTech Industries) connecting British and international health technology companies with Saudi Arabia and wider Middle East market opportunities, supporting market entry and business development.',
  'Accelerator', 'ABHI (Association of British HealthTech Industries)', 'Saudi Arabia', 'Global_including_Saudi',
  'Varies by cohort', 'other', 'https://abhi.org.uk/international/abhi-middle-east-accelerator/',
  'open', 'open', 'English', ARRAY['Healthcare & Life Sciences'], true, '2026-06-03'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://abhi.org.uk/international/abhi-middle-east-accelerator/');

INSERT INTO opportunities (id, title, description_short, type, sponsor_institution, country, eligibility_region, funding_amount, funding_type, application_link, deadline_date, status, language, sectors, "isNew", last_verified)
SELECT gen_random_uuid()::text, 'SEU Sports Tech Accelerator',
  'Saudi Electronic University Sports Tech Accelerator supporting startups developing innovative technology solutions for the sports sector, offering mentorship, funding connections, and market access within Saudi Arabia''s growing sports economy under Vision 2030.',
  'Accelerator', 'Saudi Electronic University (SEU)', 'Saudi Arabia', 'Saudi Arabia',
  'Varies by cohort', 'other', 'https://sportstechaccelerator.seu.edu.sa/en/start-up',
  'open', 'open', 'English', ARRAY['Innovation & Entrepreneurship'], true, '2026-06-03'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://sportstechaccelerator.seu.edu.sa/en/start-up');

INSERT INTO opportunities (id, title, description_short, type, sponsor_institution, country, eligibility_region, funding_amount, funding_type, application_link, deadline_date, status, language, sectors, "isNew", last_verified)
SELECT gen_random_uuid()::text, 'MBSC Venture Lab',
  'Prince Mohammad Bin Salman College of Business and Entrepreneurship (MBSC) Venture Lab supporting Saudi entrepreneurs and startups with mentorship, co-working resources, investor introductions, and access to funding from the MBSC ecosystem.',
  'Accelerator', 'Prince Mohammad Bin Salman College (MBSC)', 'Saudi Arabia', 'Saudi Arabia',
  'Varies by program', 'other', 'https://campaigns.mbsc.edu.sa/venture-lab',
  'open', 'open', 'English', ARRAY['Innovation & Entrepreneurship'], true, '2026-06-03'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://campaigns.mbsc.edu.sa/venture-lab');

INSERT INTO opportunities (id, title, description_short, type, sponsor_institution, country, eligibility_region, funding_amount, funding_type, application_link, deadline_date, status, language, sectors, "isNew", last_verified)
SELECT gen_random_uuid()::text, 'GAIA Generative AI Accelerator',
  'Global Generative AI Accelerator (GAIA) by New Native supporting startups building innovative products on generative AI technologies, offering compute resources, technical mentorship, partnership introductions, and go-to-market support across multiple cohorts.',
  'Accelerator', 'New Native', 'Saudi Arabia', 'Global_including_Saudi',
  'Varies by cohort', 'other', 'https://gaia.newnative.ai',
  'recurring', 'recurring', 'English', ARRAY['ICT'], true, '2026-06-03'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://gaia.newnative.ai');

INSERT INTO opportunities (id, title, description_short, type, sponsor_institution, country, eligibility_region, funding_amount, funding_type, application_link, deadline_date, status, language, sectors, "isNew", last_verified)
SELECT gen_random_uuid()::text, 'Misk x AECOM Graduate Development Program',
  'Graduate development program through Misk Hub in partnership with AECOM, providing Saudi graduates with professional training opportunities in engineering, infrastructure planning, and project management to accelerate career development.',
  'Training Program', 'Misk Foundation / AECOM', 'Saudi Arabia', 'Saudi Arabia',
  'Paid traineeship', 'other', 'https://hub.misk.org.sa/programs/skills/aecom-graduate-development-program/',
  'open', 'open', 'English', ARRAY['Transport & Logistics'], true, '2026-06-03'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://hub.misk.org.sa/programs/skills/aecom-graduate-development-program/');

INSERT INTO opportunities (id, title, description_short, type, sponsor_institution, country, eligibility_region, funding_amount, funding_type, application_link, deadline_date, status, language, sectors, "isNew", last_verified)
SELECT gen_random_uuid()::text, 'Misk x Hyundai Motor Group Traineeship Program',
  'Traineeship program through Misk Hub in partnership with Hyundai Motor Group, offering Saudi youth hands-on experience in automotive engineering, manufacturing, and innovation at Hyundai facilities, supporting Saudi Vision 2030 workforce localization goals.',
  'Training Program', 'Misk Foundation / Hyundai Motor Group', 'Saudi Arabia', 'Saudi Arabia',
  'Paid traineeship', 'other', 'https://hub.misk.org.sa/programs/skills/misk-traineeship-program-x-hyundai-motor-company/',
  'recurring', 'recurring', 'English', ARRAY['Industrial & Manufacturing'], true, '2026-06-03'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://hub.misk.org.sa/programs/skills/misk-traineeship-program-x-hyundai-motor-company/');

INSERT INTO opportunities (id, title, description_short, type, sponsor_institution, country, eligibility_region, funding_amount, funding_type, application_link, deadline_date, status, language, sectors, "isNew", last_verified)
SELECT gen_random_uuid()::text, 'Misk Nonprofit Sector Skills Program',
  'Misk Hub program equipping Saudi youth with skills and practical experience in nonprofit management, social impact measurement, fundraising, and organizational leadership to strengthen the Kingdom''s third sector under Vision 2030.',
  'Training Program', 'Misk Foundation', 'Saudi Arabia', 'Saudi Arabia',
  'Free program', 'other', 'https://hub.misk.org.sa/programs/skills/nonprofit-sector-skills-program/',
  'recurring', 'recurring', 'English', ARRAY['Humanitarian'], true, '2026-06-03'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://hub.misk.org.sa/programs/skills/nonprofit-sector-skills-program/');

INSERT INTO opportunities (id, title, description_short, type, sponsor_institution, country, eligibility_region, funding_amount, funding_type, application_link, deadline_date, status, language, sectors, "isNew", last_verified)
SELECT gen_random_uuid()::text, 'Misk Ignited Voices Program',
  'Misk Hub leadership program cultivating Saudi youth''s public speaking, storytelling, and communication skills to become influential voices in their communities, inspiring the next generation of Saudi leaders and changemakers under Vision 2030.',
  'Training Program', 'Misk Foundation', 'Saudi Arabia', 'Saudi Arabia',
  'Free program', 'other', 'https://hub.misk.org.sa/programs/leadership/ignited-voices/',
  'recurring', 'recurring', 'English', ARRAY['Private Sector'], true, '2026-06-03'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://hub.misk.org.sa/programs/leadership/ignited-voices/');

INSERT INTO opportunities (id, title, description_short, type, sponsor_institution, country, eligibility_region, funding_amount, funding_type, application_link, deadline_date, status, language, sectors, "isNew", last_verified)
SELECT gen_random_uuid()::text, 'Misk Qimah Program',
  'Misk Hub''s Qimah Program developing leadership capabilities and professional excellence in Saudi youth through immersive training, executive mentorship, and exposure to top private sector organizations driving Saudi Arabia''s economic transformation.',
  'Training Program', 'Misk Foundation', 'Saudi Arabia', 'Saudi Arabia',
  'Free program', 'other', 'https://hub.misk.org.sa/programs/skills/misk-qimah-program/',
  'open', 'open', 'English', ARRAY['Private Sector'], true, '2026-06-03'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://hub.misk.org.sa/programs/skills/misk-qimah-program/');

INSERT INTO opportunities (id, title, description_short, type, sponsor_institution, country, eligibility_region, funding_amount, funding_type, application_link, deadline_date, status, language, sectors, "isNew", last_verified)
SELECT gen_random_uuid()::text, 'Misk Immersive Programs',
  'Misk Hub immersive learning experiences offering Saudi youth deep-dive technology and innovation workshops in areas including artificial intelligence, digital transformation, and emerging technologies delivered by leading global tech companies.',
  'Training Program', 'Misk Foundation', 'Saudi Arabia', 'Saudi Arabia',
  'Free program', 'other', 'https://hub.misk.org.sa/programs/skills/misk-immersive-programs/',
  'recurring', 'recurring', 'English', ARRAY['ICT'], true, '2026-06-03'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://hub.misk.org.sa/programs/skills/misk-immersive-programs/');

INSERT INTO opportunities (id, title, description_short, type, sponsor_institution, country, eligibility_region, funding_amount, funding_type, application_link, deadline_date, status, language, sectors, "isNew", last_verified)
SELECT gen_random_uuid()::text, 'Misk x EY Traineeship Program',
  'Traineeship program through Misk Hub in partnership with Ernst & Young (EY) offering Saudi graduates hands-on experience in professional services, audit, tax, consulting, and financial advisory to accelerate careers in the Kingdom''s financial sector.',
  'Training Program', 'Misk Foundation / Ernst & Young (EY)', 'Saudi Arabia', 'Saudi Arabia',
  'Paid traineeship', 'other', 'https://hub.misk.org.sa/programs/skills/misk-x-ey-traineeship-program/',
  'recurring', 'recurring', 'English', ARRAY['Financial Services'], true, '2026-06-03'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://hub.misk.org.sa/programs/skills/misk-x-ey-traineeship-program/');

INSERT INTO opportunities (id, title, description_short, type, sponsor_institution, country, eligibility_region, funding_amount, funding_type, application_link, deadline_date, status, language, sectors, "isNew", last_verified)
SELECT gen_random_uuid()::text, 'Misk Traineeship Program x National Events Center',
  'Traineeship program through Misk Hub in partnership with the National Events Center (NEC), providing Saudi youth with practical experience in large-scale event management, hospitality operations, and entertainment sector development under Vision 2030.',
  'Training Program', 'Misk Foundation / National Events Center (NEC)', 'Saudi Arabia', 'Saudi Arabia',
  'Paid traineeship', 'other', 'https://hub.misk.org.sa/programs/skills/misk-traineeship-program-x-national-events-center/',
  'open', 'open', 'English', ARRAY['Tourism & Quality of Life'], true, '2026-06-03'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://hub.misk.org.sa/programs/skills/misk-traineeship-program-x-national-events-center/');

INSERT INTO opportunities (id, title, description_short, type, sponsor_institution, country, eligibility_region, funding_amount, funding_type, application_link, deadline_date, status, language, sectors, "isNew", last_verified)
SELECT gen_random_uuid()::text, 'Misk x Ministry of Education Graduate Training (Tamheer)',
  'Graduate training opportunity through Misk Hub in partnership with Saudi Arabia''s Ministry of Education under the Tamheer program, offering Saudi graduates structured on-the-job training in education administration, policy, and institutional management.',
  'Training Program', 'Misk Foundation / Ministry of Education', 'Saudi Arabia', 'Saudi Arabia',
  'Paid traineeship (Tamheer stipend)', 'other', 'https://hub.misk.org.sa/programs/skills/misk-x-graduate-training-at-the-ministry-of-education-tamheer-program/',
  'open', 'open', 'English', ARRAY['Education'], true, '2026-06-03'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://hub.misk.org.sa/programs/skills/misk-x-graduate-training-at-the-ministry-of-education-tamheer-program/');

INSERT INTO opportunities (id, title, description_short, type, sponsor_institution, country, eligibility_region, funding_amount, funding_type, application_link, deadline_date, status, language, sectors, "isNew", last_verified)
SELECT gen_random_uuid()::text, 'Game Founders Program',
  'Saudi Ministry of Communications and Information Technology (MCIT) Game Founders Program supporting Saudi gaming entrepreneurs and startup founders with training, mentorship, business development resources, and funding access to build globally competitive gaming companies.',
  'Government Program', 'Ministry of Communications and Information Technology (MCIT)', 'Saudi Arabia', 'Saudi Arabia',
  'Varies by cohort', 'other', 'https://code.mcit.gov.sa/en/game-founders',
  'recurring', 'recurring', 'English', ARRAY['ICT'], true, '2026-06-03'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://code.mcit.gov.sa/en/game-founders');

INSERT INTO opportunities (id, title, description_short, type, sponsor_institution, country, eligibility_region, funding_amount, funding_type, application_link, deadline_date, status, language, sectors, "isNew", last_verified)
SELECT gen_random_uuid()::text, 'Developing Gaming Entrepreneurs Program',
  'MCIT program to develop Saudi gaming entrepreneurs through structured training in game design, production, and business development, equipping participants to launch successful ventures in Saudi Arabia''s rapidly growing video gaming industry.',
  'Government Program', 'Ministry of Communications and Information Technology (MCIT)', 'Saudi Arabia', 'Saudi Arabia',
  'Varies by cohort', 'other', 'https://code.mcit.gov.sa/en/competition/creating-entrepreneurs-video-gaming-industry',
  'recurring', 'recurring', 'English', ARRAY['ICT'], true, '2026-06-03'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://code.mcit.gov.sa/en/competition/creating-entrepreneurs-video-gaming-industry');
