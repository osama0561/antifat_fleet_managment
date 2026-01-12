-- ========================================
-- FleetCheck: Import Real Drivers
-- Run this in Supabase SQL Editor
-- ========================================

-- ========================================
-- STEP 1: DELETE ALL TEST DATA
-- ========================================
-- Delete in correct order (foreign key constraints)
DELETE FROM food_deliveries;
DELETE FROM accident_reports;
DELETE FROM maintenance_reports;
DELETE FROM inspections;
DELETE FROM driver_vehicle_assignments;
DELETE FROM audit_log;
DELETE FROM vehicles;
DELETE FROM drivers;

-- ========================================
-- STEP 2: INSERT REAL DRIVERS (82 drivers)
-- ========================================
INSERT INTO drivers (email, full_name, driver_code, phone, is_active, role, driver_type, admin_notes) VALUES
-- Riyadh Drivers
('akibantifat@gmail.com', 'Akib Islam', 'DRV-442504', '+966542492248', true, 'driver', 'permanent', 'Riyadh'),
('altyeab@antifat.com', 'Al Tayeb Omar', 'DRV-395219', '+966505050500', true, 'driver', 'permanent', 'Riyadh'),
('muawai@antifat.com', 'Arshad Khan', 'DRV-267989', '+966543301458', true, 'driver', 'permanent', 'Riyadh'),
('abobakr@antifat.com', 'Kawsar Wahid', 'DRV-275070', '+966542486036', true, 'driver', 'permanent', 'Riyadh'),
('hamdi@antifat.com', 'Mohammad Rumman', 'DRV-275064', '+966543301451', true, 'driver', 'permanent', 'Riyadh'),
('aboalqasem@antifat.com', 'Moussa Ahmad', 'DRV-275062', '+966532692205', true, 'driver', 'permanent', 'Riyadh'),
('nasirmiamia@antifat.com', 'Nasir Mia', 'DRV-320120', '+966532975340', true, 'driver', 'permanent', 'Riyadh'),
('alhag@antifat.com', 'Walid Yahaya', 'DRV-235727', '+966500000000', true, 'driver', 'permanent', 'Riyadh'),
('aldrbani@antifat.com', 'Al-Tayyib Al-Darbani', 'DRV-399526', '+966569371534', true, 'driver', 'permanent', 'Riyadh'),
('arshadi@antifat.com', 'Al-Ezz bin Qasim', 'DRV-360614', '+966569295240', true, 'driver', 'permanent', 'Riyadh'),
('ramiantifat@hotmail.com', 'Rami Abd al-Samad', 'DRV-286270', '+966578832760', true, 'driver', 'permanent', 'Riyadh'),
('0570768138@antifatplus.com', 'Salman Qasim', 'DRV-44750', '+966570768138', true, 'driver', 'permanent', 'Riyadh'),
('0555349738@antifatplus.com', 'Ali Saleh', 'DRV-45487', '+966555349738', true, 'driver', 'permanent', 'Riyadh'),
('0548205047@antifatplus.com', 'Monisiya Branch', 'DRV-71508', '+966511111865', true, 'driver', 'permanent', 'Riyadh'),
('0500543674@antifatplus.com', 'Alsmawi', 'DRV-45474', '+966573282501', true, 'driver', 'permanent', 'Riyadh'),
('0583567709@antifatplus.com', 'Mohieldin Azyi', 'DRV-44758', '+966583567709', true, 'driver', 'permanent', 'Riyadh'),
('0581265762@antifatplus.com', 'Al-Hadari', 'DRV-45492', '+966581265762', true, 'driver', 'permanent', 'Riyadh'),
('0510306277@antifatplus.com', 'Bassam Al-Afeefi', 'DRV-45479', '+966510306277', true, 'driver', 'permanent', 'Riyadh'),
('570780714@antifatplus.com', 'Ramadan Mohammed', 'DRV-45470', '+966570780714', true, 'driver', 'permanent', 'Riyadh'),
('0592368090@antifatplus.com', 'Tariq Mohammed', 'DRV-45494', '+966592368090', true, 'driver', 'permanent', 'Riyadh'),
('0564828733@antifatplus.com', 'Abdulaziz Al-Rasheed', 'DRV-45488', '+966564828733', true, 'driver', 'permanent', 'Riyadh'),
('okasha@antifat.com', 'Okasha', 'DRV-300645', '+966501020304', true, 'admin', 'permanent', 'Riyadh - ADMIN'),
('0575627464@antifatplus.com', 'Omar Al-Amin', 'DRV-45489', '+966575627464', true, 'driver', 'permanent', 'Riyadh'),
('isa@antifat.com', 'Issa Mohammed', 'DRV-251947', '+966591084654', true, 'driver', 'permanent', 'Riyadh'),
('0548604262@antifatplus.com', 'Mohammed Al-Samawi', 'DRV-45484', '+966548604262', true, 'driver', 'permanent', 'Riyadh'),
('0537972948@antifatplus.com', 'Mohammed Hassan', 'DRV-44753', '+966552326146', true, 'driver', 'permanent', 'Riyadh'),
('0543804752@antifatplus.com', 'Mohammed Othman', 'DRV-45483', '+966543804752', true, 'driver', 'permanent', 'Riyadh'),
('0510199318@antifatplus.com', 'Mohi Al-Deen', 'DRV-45478', '+966503831190', true, 'driver', 'permanent', 'Riyadh'),
('hisham@gmail.com', 'Mousa Thabet', 'DRV-65256', '+966532010806', true, 'driver', 'permanent', 'Riyadh'),
('0506918598@antifatplus.com', 'Najm Saeed', 'DRV-44759', '+966506918598', true, 'driver', 'permanent', 'Riyadh'),
('05331588370@antifatplus.com', 'Harun Al-Omari', 'DRV-45481', '+966554080244', true, 'driver', 'permanent', 'Riyadh'),
('0507732927@antifatplus.com', 'Hesham Mohammed', 'DRV-45477', '+966510547633', true, 'driver', 'permanent', 'Riyadh'),
('510000000@fladf.com', 'Passport Representative', 'DRV-603119', '+966510000000', true, 'driver', 'permanent', 'Riyadh'),
('soso1991.vip@gmail.com', 'Mousa Al-Omari', 'DRV-64634', '+966531088983', true, 'driver', 'permanent', 'Riyadh'),

-- Jeddah Drivers
('546746452@antifa.com', 'Ibrahim Awad', 'DRV-284566', '+966546746452', true, 'driver', 'permanent', 'Jeddah'),
('504639859@gmail.com', 'Ahmed Jango', 'DRV-413697', '+966504639851', true, 'driver', 'permanent', 'Jeddah'),
('ahmdbahdad24@gmail.com', 'Ahmed Hussein Ahmed', 'DRV-10058', '+966548330352', true, 'driver', 'permanent', 'Jeddah'),
('0543439264@gmail.com', 'Osama', 'DRV-413717', '+966543439261', true, 'driver', 'permanent', 'Jeddah'),
('0592867238@antifa.com', 'Osama Mohammed', 'DRV-247649', '+966543439264', true, 'driver', 'permanent', 'Jeddah'),
('0551489886@antifatplus.com', 'Aseel', 'DRV-69486', '+966551489886', true, 'driver', 'permanent', 'Jeddah'),
('jasemali12@gmail.com', 'Jassim Hashim', 'DRV-44733', '+966535571775', true, 'driver', 'permanent', 'Jeddah'),
('123@antifatplus.com', 'Hamouda', 'DRV-413679', '+966530734411', true, 'driver', 'permanent', 'Jeddah'),
('576844987@antifatplus.com', 'Raed Abu Al-Hussein', 'DRV-45471', '+966577228909', true, 'driver', 'permanent', 'Jeddah'),
('0540326059@gmail.com', 'Tariq - Sabah', 'DRV-413702', '+966540326051', true, 'driver', 'permanent', 'Jeddah'),
('0582843036@antifa.com', 'Abdullah Adam', 'DRV-248354', '+966582843036', true, 'driver', 'permanent', 'Jeddah'),
('0530349876@antifatplus.com', 'Abdullah Alwan', 'DRV-69490', '+966530349876', true, 'driver', 'permanent', 'Jeddah'),
('0538996430@antifatplus.com', 'Omar Sabah', 'DRV-128783', '+966538996430', true, 'driver', 'permanent', 'Jeddah'),
('0543663964@antifatplus.com', 'Ahmed Abdullah', 'DRV-44748', '+966504639859', true, 'driver', 'permanent', 'Jeddah'),
('0566304078@antifatplus.com', 'Ibrahim Mohammed', 'DRV-44747', '+966592867238', true, 'driver', 'permanent', 'Jeddah'),
('541725093@antifatplus.com', 'Ibrahim Omar', 'DRV-44725', '+966541725093', true, 'driver', 'permanent', 'Jeddah'),
('0592496872@antifatplus.com', 'Ayyoub Ahmed', 'DRV-44724', '+966592496872', true, 'driver', 'permanent', 'Jeddah'),
('0546050754@antifatplus.com', 'Bilal Khayyat', 'DRV-44731', '+966546050754', true, 'driver', 'permanent', 'Jeddah'),
('0549030419@antifatplus.com', 'Turki Ghaban', 'DRV-44732', '+966549030419', true, 'driver', 'permanent', 'Jeddah'),
('533485220@antifatplus.com', 'Jamal', 'DRV-44734', '+966533485220', true, 'driver', 'permanent', 'Jeddah'),
('55@antifatplus.com', 'Rayan', 'DRV-44721', '+966544075772', true, 'driver', 'permanent', 'Jeddah'),
('0540326059@antifatplus.com', 'Tariq Mansour', 'DRV-44742', '+966540326059', true, 'driver', 'permanent', 'Jeddah'),
('0541719994@antifatplus.com', 'Abed Bakhsh', 'DRV-44744', '+966541719994', true, 'driver', 'permanent', 'Jeddah'),
('0509675795@antifatplus.com', 'Abdulrahman Alwan', 'DRV-44745', '+966509675795', true, 'driver', 'permanent', 'Jeddah'),
('0547993733@antifatplus.com', 'Ali Abu Bakr', 'DRV-44749', '+966547993733', true, 'driver', 'permanent', 'Jeddah'),
('0504251470@antifatplus.com', 'Omar Daghnyo', 'DRV-44751', '+966504251470', true, 'driver', 'permanent', 'Jeddah'),
('0530734415@antifatplus.com', 'Mohammed Hammouda', 'DRV-44752', '+966530734415', true, 'driver', 'permanent', 'Jeddah'),
('58@antifatplus.com', 'Mohammed Abdulrahman', 'DRV-44728', '+966547074800', true, 'driver', 'permanent', 'Jeddah'),
('595058771@antifa.com', 'Mohammed Hamed', 'DRV-615528', '+966595058771', true, 'driver', 'permanent', 'Jeddah'),
('0575032653@antifatplus.com', 'Mohammed Nasser', 'DRV-69497', '+966575032653', true, 'driver', 'permanent', 'Jeddah'),
('0566219864@gmail.com', 'Mahmoud Sabah', 'DRV-424680', '+966566219861', true, 'driver', 'permanent', 'Jeddah'),
('0566219864@antifatplus.com', 'Mahmoud Abdelqader', 'DRV-44740', '+966566219864', true, 'driver', 'permanent', 'Jeddah'),

-- Makkah Drivers
('000000@gmail.com', 'Alaa Al-Deen', 'DRV-314698', '+966510672608', true, 'driver', 'permanent', 'Makkah'),
('0563396789@antifatplus.com', 'Imran Bifari', 'DRV-69495', '+966563396789', true, 'driver', 'permanent', 'Makkah'),
('0541401300@antfifatplus.com', 'Mustafa Saeed', 'DRV-69496', '+966541401300', true, 'driver', 'permanent', 'Makkah'),
('0561597678@antifatplus.com', 'Yasser Hussein', 'DRV-44746', '+966561597678', true, 'driver', 'permanent', 'Makkah'),

-- Eastern Province Drivers
('0572513265@antifat.com', 'Tawfeer Raz', 'DRV-144222', '+966572513265', true, 'driver', 'permanent', 'Eastern Province'),
('0571894276@antifatp.com', 'Saeedullah Al-Khair', 'DRV-144223', '+966571894276', true, 'driver', 'permanent', 'Eastern Province'),
('0554091647@antifa.com', 'Ali Raza', 'DRV-147877', '+966554091647', true, 'driver', 'permanent', 'Eastern Province'),
('aaaa@aaaa.com', 'Mohammed Yaseen', 'DRV-144226', '+966510773082', true, 'driver', 'permanent', 'Eastern Province'),
('05433501204@antifa.com', 'Arshad Yonash', 'DRV-368961', '+966543302204', true, 'driver', 'permanent', 'Eastern Province'),
('534325027@adsfasd.com', 'Noor Khan', 'DRV-568178', '+966534325027', true, 'driver', 'permanent', 'Eastern Province'),

-- Yanbu Drivers
('ddd@andd.com', 'Osama Fahd', 'DRV-221001', '+966591316004', true, 'driver', 'permanent', 'Yanbu'),
('barcha-9-2009@hotmail.com', 'Abdullah Issa', 'DRV-218302', '+966564469551', true, 'driver', 'permanent', 'Yanbu'),

-- Al Madinah Drivers
('55555@antifatplus.com', 'Anwar Hussein', 'DRV-159827', '+966543310987', true, 'driver', 'permanent', 'Al Madinah'),
('8888fi@antifatplus.com', 'Faisal', 'DRV-159828', '+966543310878', true, 'driver', 'permanent', 'Al Madinah'),

-- Al-Kharj Driver
('0536827897@antifa.com', 'Hazem Hassan Hamad', 'DRV-253592', '+966536827897', true, 'driver', 'permanent', 'Al-Kharj'),

-- Al Qassim Driver
('574738656@hotmail.com', 'Tariq Al-Qassim', 'DRV-512745', '+966574738656', true, 'driver', 'permanent', 'Al Qassim Province')

ON CONFLICT (email) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    driver_code = EXCLUDED.driver_code,
    phone = EXCLUDED.phone,
    admin_notes = EXCLUDED.admin_notes;

-- ========================================
-- STEP 3: VERIFY IMPORT
-- ========================================
SELECT
    role,
    COUNT(*) as count,
    STRING_AGG(DISTINCT admin_notes, ', ') as cities
FROM drivers
GROUP BY role;

-- Show total
SELECT 'Total Drivers:' as info, COUNT(*) as count FROM drivers;

-- ========================================
-- NEXT STEPS (Manual in Supabase Dashboard)
-- ========================================
-- 1. Go to Authentication > Users
-- 2. Click "Add User" for each driver
-- 3. Use their email from this list
-- 4. Set password: Antifat2024
-- 5. Or use "Invite User" to send email
--
-- For bulk user creation, you can also use:
-- Supabase Dashboard > SQL Editor > Run this for each user:
--
-- SELECT auth.create_user(
--   '{"email": "driver@email.com", "password": "Antifat2024", "email_confirmed": true}'
-- );