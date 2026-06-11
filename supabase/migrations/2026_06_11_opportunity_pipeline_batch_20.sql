-- Opportunity Intelligence Pipeline – Batch 20 (2026-06-11)
-- 20 new investment opportunities discovered across MENA region
-- Countries: Algeria, Egypt (4), Iraq (2), Lebanon (2), Libya, Morocco (2),
--            Oman, Qatar, Saudi Arabia, Tunisia, UAE (4)

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'SAS for Excellence Initiative', 'Ministry of Transport, Communications and Information Technology (MTCIT)', 'Oman', ARRAY['ICT'], 'Program', 'open', 'Up to OMR 1,000,000', 'open', 'https://mtcit.gov.om/platforms/sas', 'Oman government excellence program for AI and cybersecurity startups launched June 2026, offering up to OMR 1M in financing plus wage subsidies for 40 employees.', '2026-06-11'::date, 'Oman'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://mtcit.gov.om/platforms/sas');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'MENA Technology Fund (MTF)', 'MENA Technology Fund', 'UAE', ARRAY['ICT'], 'Venture Capital', 'open', '$50 million', 'open', 'https://menatechfund.com', 'London-headquartered, Dubai-present VC fund investing in early-stage B2B SaaS, Agritech, Logistics, NPL Fintech, and E-commerce startups across the MENA region.', '2026-06-11'::date, 'MENA'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://menatechfund.com');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'BIM Ventures', 'BIM Ventures', 'Saudi Arabia', ARRAY['Real Estate'], 'Venture Capital', 'open', '$32 million', 'open', 'https://bimventures.com', 'Saudi Arabian venture builder with a $32M fund focused on proptech, fintech, and investtech, supporting startups from ideation to scale.', '2026-06-11'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://bimventures.com');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Egypt Ventures', 'Egypt Ventures', 'Egypt', ARRAY['Innovation & Entrepreneurship'], 'Venture Capital', 'open', NULL, 'open', 'https://egyptventures.com/', 'Egyptian government-backed venture capital fund with 29 portfolio investments since 2017, supporting technology startups across Egypt and the MENA region.', '2026-06-11'::date, 'Egypt'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://egyptventures.com/');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Lunate Alternative Investment', 'Lunate', 'UAE', ARRAY['Financial Services'], 'Investment', 'open', '$115 billion AUM', 'open', 'https://lunate.com/', 'Abu Dhabi-based alternative investment firm managing $115B AUM, deploying capital into VC, private equity, real assets, and credit across MENA and global markets.', '2026-06-11'::date, 'Global'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://lunate.com/');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Iliad Partners MENA VC Fund', 'Iliad Partners', 'UAE', ARRAY['ICT'], 'Venture Capital', 'open', '$50 million', 'open', 'https://www.iliad-partners.com/', 'ADGM Abu Dhabi-based VC fund investing in early-stage B2B SaaS, fintech, logistics, and proptech startups at Pre-Series A and Series A stages across MENA.', '2026-06-11'::date, 'MENA'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://www.iliad-partners.com/');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Emirates Growth Fund (EGF)', 'Emirates Growth Fund', 'UAE', ARRAY['Private Sector'], 'Investment', 'open', 'AED 1 billion', 'open', 'https://egf.gov.ae/', 'UAE government AED 1B fund investing AED 10–50M per company in UAE SMEs across manufacturing, healthcare, food security, and advanced technology sectors.', '2026-06-11'::date, 'UAE'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://egf.gov.ae/');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'EdVentures Investment Program', 'Nahdet Misr Group (EdVentures)', 'Egypt', ARRAY['Education'], 'Venture Capital', 'open', 'Up to $300,000', 'open', 'https://www.nmedventures.com/programs/investment-program/', 'Nahdet Misr Group EdTech-focused VC fund investing up to $300K in MENA education technology startups at pre-seed and seed stages.', '2026-06-11'::date, 'MENA'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://www.nmedventures.com/programs/investment-program/');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'IVP Catalyst Fund', 'Iraq Venture Partners (IVP)', 'Iraq', ARRAY['Innovation & Entrepreneurship'], 'Venture Capital', 'open', '$25,000–$100,000', 'open', 'https://www.iraqventurepartners.com/funds-programs/ivp-catalyst-fund', 'First Baghdad-based seed VC fund investing $25K–$100K in Iraqi early-stage startups, managed by Iraq Venture Partners.', '2026-06-11'::date, 'Iraq'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://www.iraqventurepartners.com/funds-programs/ivp-catalyst-fund');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Rasmal Ventures Fund', 'Rasmal Ventures', 'Qatar', ARRAY['Financial Services'], 'Venture Capital', 'open', '$100 million', 'open', 'https://www.rasmalventures.com/', 'Qatar-based $100M VC fund backed by Qatar Investment Authority Fund of Funds, investing in fintech, healthtech, SaaS, and logistics startups across MENA.', '2026-06-11'::date, 'MENA'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://www.rasmalventures.com/');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Egypt Startup Charter', 'Egyptian Government – Ministry of ICT', 'Egypt', ARRAY['Innovation & Entrepreneurship'], 'Program', 'open', '$1 billion over 5 years', 'open', 'https://startup.gov.eg/charter-eng', 'Egypt national startup commitment launched February 2026, pledging $1B over 5 years in funding, regulatory reform, and startup-friendly policies for Egyptian entrepreneurs.', '2026-06-11'::date, 'Egypt'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://startup.gov.eg/charter-eng');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Aria Ventures Deep Tech Fund', 'Aria Ventures', 'Egypt', ARRAY['Healthcare & Life Sciences'], 'Venture Capital', 'open', '$1 million (EGP 50 million)', 'open', 'https://ariaventures.tech/', 'Egypt first deep tech VC fund investing EGP 50M in AI, biotech, and healthcare startups at early stage.', '2026-06-11'::date, 'Egypt'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://ariaventures.tech/');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Maroc Numeric Fund (MNF Ventures)', 'MNF Ventures', 'Morocco', ARRAY['ICT'], 'Venture Capital', 'open', 'MAD 1–10 million per investment', 'open', 'https://mnf.ma/en/', 'Morocco ICT-focused VC fund investing MAD 1–10M at Seed, Pre-Series A, and Series A stages in Moroccan digital technology startups.', '2026-06-11'::date, 'Morocco'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://mnf.ma/en/');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Musha Ventures', 'Musha Ventures', 'Morocco', ARRAY['ICT'], 'Venture Capital', 'open', '$50,000–$200,000', 'open', 'https://www.mushaventures.com/', 'Moroccan seed and pre-seed VC fund investing $50K–$200K in B2B SaaS startups from Morocco and French-speaking Africa.', '2026-06-11'::date, 'Morocco'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://www.mushaventures.com/');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Smart Capital Tunisia – ANAVA Fund of Funds', 'Smart Capital', 'Tunisia', ARRAY['Innovation & Entrepreneurship'], 'Investment', 'open', '€100 million', 'open', 'https://smartcapital.tn/', 'Tunisian Fund of Funds targeting €100M backed by World Bank and KfW, investing in Tunisian VC funds that support technology startups through the ANAVA program.', '2026-06-11'::date, 'Tunisia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://smartcapital.tn/');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'IM Capital Lebanon', 'IM Capital', 'Lebanon', ARRAY['Private Sector'], 'Investment', 'open', '$20 million', 'open', 'https://im-fndng.com/', 'USAID-funded $20M matching capital program providing Lebanese startups with co-investment and technical assistance to restore private sector growth.', '2026-06-11'::date, 'Lebanon'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://im-fndng.com/');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Saned Partners', 'Saned Partners', 'Lebanon', ARRAY['ICT'], 'Venture Capital', 'open', '$1–5 million', 'open', 'https://www.sanedpartners.com/', 'Beirut-based early-stage VC fund investing $1–5M in MENA SaaS, mobile, and e-commerce startups at seed to Series A stages.', '2026-06-11'::date, 'MENA'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://www.sanedpartners.com/');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Scale Iraq Investment Readiness Program', 'Iraq Venture Partners (IVP) / IFC', 'Iraq', ARRAY['Innovation & Entrepreneurship'], 'Accelerator', 'open', NULL, 'open', 'https://www.iraqventurepartners.com/funds-programs/scale-iraq', 'IFC-backed investment readiness program helping Iraqi entrepreneurs grow startup capabilities, gain market access, and connect to local and international investors.', '2026-06-11'::date, 'Iraq'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://www.iraqventurepartners.com/funds-programs/scale-iraq');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Libya Startup Programme (SPARK)', 'SPARK / European Union', 'Libya', ARRAY['Innovation & Entrepreneurship'], 'Incubator', 'open', 'Up to €10,000 (seed competition)', 'open', 'https://spark.ngo/programme/libya-startup/', 'EU-funded startup incubation program in Libya providing seed funding, mentoring, training, and investor networking through incubators in Benghazi, Al-Bayda, and Derna.', '2026-06-11'::date, 'Libya'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://spark.ngo/programme/libya-startup/');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Algeria Startup Label Program', 'Ministry of Knowledge Economy, Startups and Micro-enterprises (Algeria)', 'Algeria', ARRAY['Innovation & Entrepreneurship'], 'Program', 'open', 'Access to government grants, tax exemptions, and VC funding', 'open', 'https://startup.dz/pour-les-startups/', 'Algeria national Startup Label program granting certified startups access to government funding, 15+ fiscal and legal advantages, and the Algerian Startup Fund investment pool.', '2026-06-11'::date, 'Algeria'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://startup.dz/pour-les-startups/');
