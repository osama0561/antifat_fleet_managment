-- ========================================
-- FleetCheck: Test Data for Admin Dashboard
-- Run this in Supabase SQL Editor
-- ========================================

-- ========================================
-- 1. INSERT TEST DRIVERS
-- ========================================
INSERT INTO drivers (email, full_name, driver_code, phone, is_active, role, driver_type, license_expiry)
VALUES
    ('ahmed@antifat.com', 'أحمد محمد الغامدي', 'DRV-001', '0501234567', true, 'admin', 'permanent', '2027-06-15'),
    ('mohammed@antifat.com', 'محمد عبدالله السعيد', 'DRV-002', '0552345678', true, 'driver', 'permanent', '2026-08-20'),
    ('khalid@antifat.com', 'خالد سعد العتيبي', 'DRV-003', '0563456789', true, 'driver', 'permanent', '2026-12-10'),
    ('omar@antifat.com', 'عمر فهد القحطاني', 'DRV-004', '0574567890', true, 'driver', 'permanent', '2027-03-25'),
    ('saad@antifat.com', 'سعد ناصر الدوسري', 'DRV-005', '0585678901', true, 'driver', 'permanent', '2026-09-30'),
    ('fahad@antifat.com', 'فهد علي المطيري', 'DRV-006', '0596789012', false, 'driver', 'permanent', '2026-05-15'),
    ('yousef@antifat.com', 'يوسف حمد الشمري', 'DRV-007', '0507890123', true, 'driver', 'temporary', '2026-11-20'),
    ('abdulrahman@antifat.com', 'عبدالرحمن سالم الحربي', 'DRV-008', '0518901234', true, 'driver', 'permanent', '2027-01-10')
ON CONFLICT (email) DO NOTHING;

-- ========================================
-- 2. INSERT TEST VEHICLES
-- ========================================
INSERT INTO vehicles (van_code, plate_number, location, status, registration_expiry, insurance_expiry)
VALUES
    ('VAN-001', 'أ ب ت 1234', 'الرياض - المستودع الرئيسي', 'active', '2026-06-30', '2026-08-15'),
    ('VAN-002', 'ج د ه 5678', 'الرياض - المستودع الرئيسي', 'active', '2026-09-15', '2026-11-20'),
    ('VAN-003', 'و ز ح 9012', 'الرياض - فرع الشرق', 'idle', '2026-12-01', '2027-02-10'),
    ('VAN-004', 'ط ي ك 3456', 'الرياض - فرع الشمال', 'active', '2027-03-20', '2027-05-25'),
    ('VAN-005', 'ل م ن 7890', 'الرياض - المستودع الرئيسي', 'maintenance', '2026-07-10', '2026-09-05'),
    ('VAN-006', 'س ع ف 2345', 'جدة - المستودع', 'active', '2026-10-25', '2026-12-30'),
    ('VAN-007', 'ص ق ر 6789', 'جدة - المستودع', 'accident', '2027-01-15', '2027-03-20'),
    ('VAN-008', 'ش ت ث 0123', 'الدمام - المستودع', 'idle', '2026-08-05', '2026-10-10')
ON CONFLICT (van_code) DO NOTHING;

-- ========================================
-- 3. CREATE DRIVER-VEHICLE ASSIGNMENTS
-- ========================================
-- First get the IDs
DO $$
DECLARE
    drv1_id UUID; drv2_id UUID; drv3_id UUID; drv4_id UUID; drv5_id UUID;
    van1_id UUID; van2_id UUID; van3_id UUID; van4_id UUID; van5_id UUID;
BEGIN
    SELECT id INTO drv1_id FROM drivers WHERE driver_code = 'DRV-002';
    SELECT id INTO drv2_id FROM drivers WHERE driver_code = 'DRV-003';
    SELECT id INTO drv3_id FROM drivers WHERE driver_code = 'DRV-004';
    SELECT id INTO drv4_id FROM drivers WHERE driver_code = 'DRV-005';
    SELECT id INTO drv5_id FROM drivers WHERE driver_code = 'DRV-008';

    SELECT id INTO van1_id FROM vehicles WHERE van_code = 'VAN-001';
    SELECT id INTO van2_id FROM vehicles WHERE van_code = 'VAN-002';
    SELECT id INTO van3_id FROM vehicles WHERE van_code = 'VAN-004';
    SELECT id INTO van4_id FROM vehicles WHERE van_code = 'VAN-006';
    SELECT id INTO van5_id FROM vehicles WHERE van_code = 'VAN-008';

    INSERT INTO driver_vehicle_assignments (driver_id, vehicle_id, is_current)
    VALUES
        (drv1_id, van1_id, true),
        (drv2_id, van2_id, true),
        (drv3_id, van3_id, true),
        (drv4_id, van4_id, true),
        (drv5_id, van5_id, true)
    ON CONFLICT DO NOTHING;
END $$;

-- ========================================
-- 4. INSERT TEST INSPECTIONS (Today + Yesterday)
-- ========================================
DO $$
DECLARE
    drv_id UUID;
    van_id UUID;
BEGIN
    -- Get driver and vehicle IDs
    SELECT d.id, v.id INTO drv_id, van_id
    FROM drivers d
    JOIN driver_vehicle_assignments dva ON d.id = dva.driver_id
    JOIN vehicles v ON dva.vehicle_id = v.id
    WHERE d.driver_code = 'DRV-002' AND dva.is_current = true;

    IF drv_id IS NOT NULL THEN
        INSERT INTO inspections (
            inspection_code, driver_id, vehicle_id, inspection_type,
            photo_front, photo_back, photo_right, photo_left, photo_dashboard,
            light_front, light_back, signal_right, signal_left,
            fridge_status, declaration_accepted, notes, submitted_at
        ) VALUES
        -- Today morning receive
        (
            'INS-' || EXTRACT(EPOCH FROM NOW())::BIGINT || '1',
            drv_id, van_id, 'receive',
            'https://via.placeholder.com/400x300?text=Front',
            'https://via.placeholder.com/400x300?text=Back',
            'https://via.placeholder.com/400x300?text=Right',
            'https://via.placeholder.com/400x300?text=Left',
            'https://via.placeholder.com/400x300?text=Dashboard',
            true, true, true, true, 'working', true,
            'المركبة بحالة ممتازة',
            NOW() - INTERVAL '2 hours'
        ),
        -- Yesterday release
        (
            'INS-' || EXTRACT(EPOCH FROM NOW())::BIGINT || '2',
            drv_id, van_id, 'release',
            'https://via.placeholder.com/400x300?text=Front',
            'https://via.placeholder.com/400x300?text=Back',
            'https://via.placeholder.com/400x300?text=Right',
            'https://via.placeholder.com/400x300?text=Left',
            'https://via.placeholder.com/400x300?text=Dashboard',
            true, true, true, true, 'working', true,
            'تم التسليم بدون مشاكل',
            NOW() - INTERVAL '1 day'
        );
    END IF;

    -- Another driver inspection
    SELECT d.id, v.id INTO drv_id, van_id
    FROM drivers d
    JOIN driver_vehicle_assignments dva ON d.id = dva.driver_id
    JOIN vehicles v ON dva.vehicle_id = v.id
    WHERE d.driver_code = 'DRV-003' AND dva.is_current = true;

    IF drv_id IS NOT NULL THEN
        INSERT INTO inspections (
            inspection_code, driver_id, vehicle_id, inspection_type,
            photo_front, photo_back, photo_right, photo_left, photo_dashboard,
            light_front, light_back, signal_right, signal_left,
            fridge_status, declaration_accepted, notes, submitted_at
        ) VALUES
        (
            'INS-' || EXTRACT(EPOCH FROM NOW())::BIGINT || '3',
            drv_id, van_id, 'receive',
            'https://via.placeholder.com/400x300?text=Front',
            'https://via.placeholder.com/400x300?text=Back',
            'https://via.placeholder.com/400x300?text=Right',
            'https://via.placeholder.com/400x300?text=Left',
            'https://via.placeholder.com/400x300?text=Dashboard',
            true, true, true, false, 'working', true,
            'إشارة اليسار لا تعمل - تم إبلاغ الصيانة',
            NOW() - INTERVAL '30 minutes'
        );
    END IF;
END $$;

-- ========================================
-- 5. INSERT TEST MAINTENANCE REPORTS
-- ========================================
DO $$
DECLARE
    drv_id UUID;
    van_id UUID;
BEGIN
    SELECT d.id, v.id INTO drv_id, van_id
    FROM drivers d
    JOIN driver_vehicle_assignments dva ON d.id = dva.driver_id
    JOIN vehicles v ON dva.vehicle_id = v.id
    WHERE d.driver_code = 'DRV-003' AND dva.is_current = true;

    IF drv_id IS NOT NULL THEN
        INSERT INTO maintenance_reports (
            report_code, driver_id, vehicle_id, issue_types, urgency,
            description, odometer_reading, status, submitted_at
        ) VALUES
        (
            'MNT-' || EXTRACT(EPOCH FROM NOW())::BIGINT || '1',
            drv_id, van_id,
            ARRAY['lights'],
            'medium',
            'إشارة اليسار لا تعمل. لاحظت المشكلة اليوم أثناء الفحص الصباحي.',
            45230,
            'pending',
            NOW() - INTERVAL '30 minutes'
        );
    END IF;

    SELECT d.id, v.id INTO drv_id, van_id
    FROM drivers d
    JOIN driver_vehicle_assignments dva ON d.id = dva.driver_id
    JOIN vehicles v ON dva.vehicle_id = v.id
    WHERE d.driver_code = 'DRV-004' AND dva.is_current = true;

    IF drv_id IS NOT NULL THEN
        INSERT INTO maintenance_reports (
            report_code, driver_id, vehicle_id, issue_types, urgency,
            description, odometer_reading, status, submitted_at
        ) VALUES
        (
            'MNT-' || EXTRACT(EPOCH FROM NOW())::BIGINT || '2',
            drv_id, van_id,
            ARRAY['brakes', 'tires'],
            'high',
            'صوت غريب من الفرامل عند الضغط عليها. الإطار الأمامي الأيمن يحتاج تبديل.',
            62150,
            'pending',
            NOW() - INTERVAL '2 hours'
        ),
        (
            'MNT-' || EXTRACT(EPOCH FROM NOW())::BIGINT || '3',
            drv_id, van_id,
            ARRAY['ac'],
            'low',
            'التكييف ضعيف قليلاً، يحتاج فحص الفريون.',
            62100,
            'in_progress',
            NOW() - INTERVAL '2 days'
        );
    END IF;

    SELECT d.id, v.id INTO drv_id, van_id
    FROM drivers d
    JOIN driver_vehicle_assignments dva ON d.id = dva.driver_id
    JOIN vehicles v ON dva.vehicle_id = v.id
    WHERE d.driver_code = 'DRV-005' AND dva.is_current = true;

    IF drv_id IS NOT NULL THEN
        INSERT INTO maintenance_reports (
            report_code, driver_id, vehicle_id, issue_types, urgency,
            description, odometer_reading, status, submitted_at
        ) VALUES
        (
            'MNT-' || EXTRACT(EPOCH FROM NOW())::BIGINT || '4',
            drv_id, van_id,
            ARRAY['fridge'],
            'high',
            'الثلاجة لا تعمل نهائياً. يجب إصلاحها فوراً لنقل المواد الغذائية.',
            38900,
            'pending',
            NOW() - INTERVAL '1 hour'
        );
    END IF;
END $$;

-- ========================================
-- 6. INSERT TEST ACCIDENT REPORTS
-- ========================================
DO $$
DECLARE
    drv_id UUID;
    van_id UUID;
BEGIN
    -- Get VAN-007 which is marked as accident
    SELECT id INTO van_id FROM vehicles WHERE van_code = 'VAN-007';
    SELECT id INTO drv_id FROM drivers WHERE driver_code = 'DRV-005';

    IF drv_id IS NOT NULL AND van_id IS NOT NULL THEN
        INSERT INTO accident_reports (
            report_code, driver_id, vehicle_id, accident_type,
            description, accident_location, status, submitted_at
        ) VALUES
        (
            'ACC-' || EXTRACT(EPOCH FROM NOW())::BIGINT || '1',
            drv_id, van_id,
            'collision',
            'تصادم خفيف مع سيارة أخرى عند إشارة المرور. الطرف الآخر توقف فجأة. أضرار في الصدام الأمامي.',
            'الرياض - تقاطع شارع الملك فهد مع شارع العليا',
            'pending',
            NOW() - INTERVAL '3 hours'
        );
    END IF;

    -- Another minor accident
    SELECT d.id, v.id INTO drv_id, van_id
    FROM drivers d
    JOIN driver_vehicle_assignments dva ON d.id = dva.driver_id
    JOIN vehicles v ON dva.vehicle_id = v.id
    WHERE d.driver_code = 'DRV-002' AND dva.is_current = true;

    IF drv_id IS NOT NULL THEN
        INSERT INTO accident_reports (
            report_code, driver_id, vehicle_id, accident_type,
            description, accident_location, status, submitted_at
        ) VALUES
        (
            'ACC-' || EXTRACT(EPOCH FROM NOW())::BIGINT || '2',
            drv_id, van_id,
            'scratch',
            'خدش بسيط في الجانب الأيمن أثناء الركن في موقف ضيق. لا توجد سيارة أخرى متضررة.',
            'جدة - موقف مجمع الأندلس التجاري',
            'under_investigation',
            NOW() - INTERVAL '5 days'
        );
    END IF;
END $$;

-- ========================================
-- VERIFY DATA
-- ========================================
SELECT 'Drivers:' as table_name, COUNT(*) as count FROM drivers
UNION ALL
SELECT 'Vehicles:', COUNT(*) FROM vehicles
UNION ALL
SELECT 'Assignments:', COUNT(*) FROM driver_vehicle_assignments
UNION ALL
SELECT 'Inspections:', COUNT(*) FROM inspections
UNION ALL
SELECT 'Maintenance:', COUNT(*) FROM maintenance_reports
UNION ALL
SELECT 'Accidents:', COUNT(*) FROM accident_reports;
