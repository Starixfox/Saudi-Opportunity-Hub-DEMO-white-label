-- Migration: Insert 20 new verified opportunities
-- Date: 2026-06-09
-- Sources: saudimf.sa, momah.gov.sa, filming.experiencealula.com (2),
--          ssa.gov.sa (2), redseaglobal.com, eparticipation.my.gov.sa (13)
-- Agent pipeline: discovery → URL liveness → validity → data accuracy → insert
-- All URLs confirmed NOT pre-existing in DB before insert.

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Saudi MIB 2026 – Media Innovation Bootcamp', 'Saudi Media Forum', 'Saudi Arabia', ARRAY['Media & Entertainment'], 'Bootcamp', 'closed', NULL, 'closed', 'https://saudimf.sa/saudi-mib', 'AI-driven media innovation bootcamp covering augmented journalism, intelligent content creation, and virtual presenters; open to international teams of 3–6 aged 18–40.', '2026-06-09'::date, 'Global'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://saudimf.sa/saudi-mib');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Saudi Sandbox Initiative – Municipal and Housing Sectors', 'Ministry of Municipalities and Housing', 'Saudi Arabia', ARRAY['Innovation & Entrepreneurship'], 'Innovation Program', 'open', NULL, 'open', 'https://momah.gov.sa/en/form/sandbox-application-form', 'Regulatory sandbox enabling entities to test innovative solutions for Saudi municipal and housing services in a real-world, supported environment; launched April 2026.', '2026-06-09'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://momah.gov.sa/en/form/sandbox-application-form');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'AlUla Creates Film Programme', 'Film AlUla – Royal Commission for AlUla', 'Saudi Arabia', ARRAY['Creative Industries'], 'Grant', 'open', 'USD 20,000', 'open', 'https://filming.experiencealula.com/en/alula-creates/film-programme', 'Production grant of USD 20,000 plus three months of professional mentoring for three Saudi women filmmakers to produce short films, with access to the international film marketplace in London.', '2026-06-09'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://filming.experiencealula.com/en/alula-creates/film-programme');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Film AlUla – Production Financial Incentives', 'Film AlUla – Royal Commission for AlUla', 'Saudi Arabia', ARRAY['Creative Industries'], 'Grant', 'open', 'Up to 60% production rebate', 'open', 'https://filming.experiencealula.com/en/filming-in-alula/financial-incentives', 'Production cash rebate of up to 60% for film and TV productions shooting in AlUla, Saudi Arabia; open to international productions with facilitated access to the Saudi national film incentive program.', '2026-06-09'::date, 'Global'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://filming.experiencealula.com/en/filming-in-alula/financial-incentives');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Madak Space Competition – Second Edition', 'Saudi Space Agency', 'Saudi Arabia', ARRAY['Technology & Innovation'], 'Competition', 'closed', 'SAR 600,000', '2026-05-30', 'https://ssa.gov.sa/Madak2/', 'Space sciences competition for Arab students aged 6–18; winning experiments are sent to the International Space Station, with total cash prizes of SAR 600,000 for 10 winning teams.', '2026-06-09'::date, 'Arab World'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://ssa.gov.sa/Madak2/');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Abaad Astrophotography Platform', 'Saudi Space Agency', 'Saudi Arabia', ARRAY['Technology & Innovation'], 'Competition', 'recurring', NULL, 'recurring', 'https://ssa.gov.sa/Abaad/', 'Monthly astrophotography competition platform launched April 2026; tracks include deep space, solar system, star trails, and space heritage; best images published across Saudi Space Agency platforms.', '2026-06-09'::date, 'Arab World'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://ssa.gov.sa/Abaad/');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Red Sea Global Scholarship – International Hospitality Management', 'Red Sea Global', 'Saudi Arabia', ARRAY['Tourism & Quality of Life'], 'Scholarship', 'open', 'Full scholarship', 'open', 'https://www.redseaglobal.com/en/rsg-scholarship/', 'Fully-funded Bachelor''s degree in International Hospitality Management with University of Prince Mugrin and EHL for Saudi nationals under 23; recipients commit to work at Red Sea Global destinations upon graduation.', '2026-06-09'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://www.redseaglobal.com/en/rsg-scholarship/');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Innovation Hackathon for Better Change – Second Edition', 'Ministry of Human Resources and Social Development', 'Saudi Arabia', ARRAY['Social Impact & Inclusion'], 'Hackathon', 'closed', NULL, '2026-03-31', 'https://eparticipation.my.gov.sa/en/co-creation/initiatives/innovation-hackathon-for-better-change-second-edition/', 'Open innovation hackathon with student, government, and professional tracks to design technology-driven solutions for Saudi social development challenges; ran July 2025–March 2026.', '2026-06-09'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://eparticipation.my.gov.sa/en/co-creation/initiatives/innovation-hackathon-for-better-change-second-edition/');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Achievement Hackathon – AI for Public and Private Sector Efficiency', 'Saudi Data and Artificial Intelligence Authority (SDAIA)', 'Saudi Arabia', ARRAY['ICT'], 'Hackathon', 'closed', NULL, '2025-01-14', 'https://eparticipation.my.gov.sa/en/co-creation/initiatives/achievement-hackathon/', 'AI hackathon exploring how artificial intelligence can achieve high efficiency and reduce resource waste in public and private sector operations; held at Al-Garage, Riyadh, January 2025.', '2026-06-09'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://eparticipation.my.gov.sa/en/co-creation/initiatives/achievement-hackathon/');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Digital Innovation Hackathon', 'Human Resources Development Fund (HRDF)', 'Saudi Arabia', ARRAY['ICT'], 'Hackathon', 'closed', NULL, '2024-05-01', 'https://eparticipation.my.gov.sa/en/co-creation/initiatives/digital-innovation-hackathon/', 'Hackathon for university students and HRDF employees to develop digital solutions improving HRDF programs and services; held April–May 2024 in Riyadh.', '2026-06-09'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://eparticipation.my.gov.sa/en/co-creation/initiatives/digital-innovation-hackathon/');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Water Hackathon', 'Ministry of Environment, Water and Agriculture', 'Saudi Arabia', ARRAY['Water & Environment'], 'Hackathon', 'closed', NULL, '2025-02-17', 'https://eparticipation.my.gov.sa/en/co-creation/initiatives/water-hackathon/', 'Hackathon stimulating digital innovation for water resource management challenges in Saudi Arabia; held in Riyadh, December 2024–February 2025.', '2026-06-09'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://eparticipation.my.gov.sa/en/co-creation/initiatives/water-hackathon/');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Innovation Path Hackathon 2025', 'Ministry of National Guard Health Affairs', 'Saudi Arabia', ARRAY['Healthcare & Life Sciences'], 'Hackathon', 'closed', NULL, 'closed', 'https://eparticipation.my.gov.sa/en/co-creation/initiatives/innovation-path-hackathon/', 'Healthcare innovation hackathon presenting public challenges to improve Ministry of National Guard Health Affairs services; launched 2025.', '2026-06-09'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://eparticipation.my.gov.sa/en/co-creation/initiatives/innovation-path-hackathon/');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Hackathon: Combating Malicious Litigation Using AI and Emerging Technologies', 'Ministry of Justice – Saudi Arabia', 'Saudi Arabia', ARRAY['ICT'], 'Hackathon', 'closed', NULL, '2024-10-23', 'https://eparticipation.my.gov.sa/en/co-creation/initiatives/artificial-intelligence/', 'Two-day hackathon to develop AI and emerging technology solutions combating malicious litigation in Saudi courts; held October 22–23, 2024.', '2026-06-09'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://eparticipation.my.gov.sa/en/co-creation/initiatives/artificial-intelligence/');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Oxagon Hackathon – Industrial Innovation Leadership', 'NEOM – Oxagon', 'Saudi Arabia', ARRAY['Industrial & Manufacturing'], 'Hackathon', 'closed', NULL, 'closed', 'https://eparticipation.my.gov.sa/en/co-creation/initiatives/hackathon-oxygen/', 'Annual hackathon organized by NEOM Oxagon in partnership with the Ministry of Education, focusing on sustainable industrial innovation including green hydrogen, smart automation, and clean industrial solutions.', '2026-06-09'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://eparticipation.my.gov.sa/en/co-creation/initiatives/hackathon-oxygen/');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Halathon Challenge – Ambulance Services Innovation', 'Saudi Red Crescent Authority', 'Saudi Arabia', ARRAY['Healthcare & Life Sciences'], 'Hackathon', 'closed', NULL, 'closed', 'https://eparticipation.my.gov.sa/en/co-creation/initiatives/halathon-challenge/', 'Two-day innovation hackathon by the Saudi Red Crescent Authority and IMSIU to develop creative digital solutions enhancing ambulance and emergency medical services in Saudi Arabia.', '2026-06-09'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://eparticipation.my.gov.sa/en/co-creation/initiatives/halathon-challenge/');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Sidra (Sedrah) Hackathon – Environmental Sustainability', 'Ministry of Environment, Water and Agriculture', 'Saudi Arabia', ARRAY['Water & Environment'], 'Hackathon', 'closed', NULL, '2024-04-28', 'https://eparticipation.my.gov.sa/en/co-creation/initiatives/sidra-hackathon/', 'Environmental sustainability hackathon with three tracks: Circular Economy, Breathable Futures (air quality), and Afforestation and Green Horizons; held April 26–28, 2024, Riyadh.', '2026-06-09'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://eparticipation.my.gov.sa/en/co-creation/initiatives/sidra-hackathon/');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Eastern Hackathon', 'Emir of the Eastern Province – Saudi Arabia', 'Saudi Arabia', ARRAY['ICT'], 'Hackathon', 'closed', NULL, 'closed', 'https://eparticipation.my.gov.sa/en/co-creation/initiatives/eastern-hackathon/', 'Innovation hackathon for participants from the Eastern Province of Saudi Arabia to develop technology-driven solutions for regional challenges.', '2026-06-09'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://eparticipation.my.gov.sa/en/co-creation/initiatives/eastern-hackathon/');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'DigitalGov Hack', 'Digital Government Authority (DGA)', 'Saudi Arabia', ARRAY['ICT'], 'Hackathon', 'closed', NULL, 'closed', 'https://eparticipation.my.gov.sa/en/co-creation/initiatives/digitalgov-hack/', 'Virtual hackathon by the Digital Government Authority in cooperation with the ITU connecting global innovators to develop digital government solutions; ran October–December 2024.', '2026-06-09'::date, 'Global'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://eparticipation.my.gov.sa/en/co-creation/initiatives/digitalgov-hack/');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'Absher Challenge – Ministry of Interior Digital Innovation', 'Ministry of Interior – Absher Program', 'Saudi Arabia', ARRAY['ICT'], 'Hackathon', 'closed', NULL, 'closed', 'https://eparticipation.my.gov.sa/en/co-creation/initiatives/absher-challenge/', 'Innovation challenge seeking creative solutions and e-business ideas for the Ministry of Interior''s Absher digital platform using AI, IoT, drones, and AR/VR technologies.', '2026-06-09'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://eparticipation.my.gov.sa/en/co-creation/initiatives/absher-challenge/');

INSERT INTO opportunities (id, title, sponsor_institution, country, sectors, type, status, funding_amount, deadline_date, application_link, description_short, last_verified, eligibility_region)
SELECT gen_random_uuid()::text, 'GovJam 2025 Innovation Challenge', 'Digital Government Authority (DGA)', 'Saudi Arabia', ARRAY['ICT'], 'Hackathon', 'closed', NULL, 'closed', 'https://eparticipation.my.gov.sa/en/co-creation/initiatives/govjam-2025/', 'Annual innovation challenge by the Digital Government Authority activating open co-creation with beneficiaries to enhance satisfaction with government services; 2025 edition of the annual GovJam program.', '2026-06-09'::date, 'Saudi Arabia'
WHERE NOT EXISTS (SELECT 1 FROM opportunities WHERE application_link = 'https://eparticipation.my.gov.sa/en/co-creation/initiatives/govjam-2025/');
