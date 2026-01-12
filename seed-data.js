/**
 * FleetCheck - Seed Test Data Script
 * Best practice: Use Supabase REST API with proper headers
 *
 * Run with: node seed-data.js
 */

const SUPABASE_URL = 'https://fwatvgxueajvjcwdokwh.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ3YXR2Z3h1ZWFqdmpjd2Rva3doIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2OTUyMTMsImV4cCI6MjA4MzI3MTIxM30.agTQDa2tEM7nvV6fzW_9K-RTK-o3vwxMatgUvuROXdA';

// Common headers for all requests
const headers = {
    'apikey': SUPABASE_ANON_KEY,
    'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
    'Content-Type': 'application/json',
    'Prefer': 'return=minimal'  // Best practice: don't return data for faster inserts
};

// Helper function to make API requests
async function supabaseInsert(table, data, upsert = false) {
    const url = `${SUPABASE_URL}/rest/v1/${table}`;
    const prefer = upsert
        ? 'return=minimal,resolution=merge-duplicates'
        : 'return=minimal';

    const response = await fetch(url, {
        method: 'POST',
        headers: { ...headers, 'Prefer': prefer },
        body: JSON.stringify(data)
    });

    if (!response.ok) {
        const error = await response.text();
        throw new Error(`${table}: ${response.status} - ${error}`);
    }

    return true;
}

// Test data
const testDrivers = [
    {
        id: '11111111-1111-1111-1111-111111111111',
        email: 'test.driver1@antifat.com',
        full_name: 'Ahmed Test Driver',
        driver_code: 'DRV-TEST-001',
        phone: '+966501234567',
        role: 'driver',
        is_active: true,
        driver_type: 'permanent'
    },
    {
        id: '22222222-2222-2222-2222-222222222222',
        email: 'test.driver2@antifat.com',
        full_name: 'Fatima Test Driver',
        driver_code: 'DRV-TEST-002',
        phone: '+966502345678',
        role: 'driver',
        is_active: true,
        driver_type: 'permanent'
    },
    {
        id: '33333333-3333-3333-3333-333333333333',
        email: 'test.driver3@antifat.com',
        full_name: 'Mohammed Test Driver',
        driver_code: 'DRV-TEST-003',
        phone: '+966503456789',
        role: 'driver',
        is_active: true,
        driver_type: 'permanent'
    }
];

const testVehicles = [
    {
        id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        van_code: 'VAN-TEST-001',
        plate_number: 'ABC 1234',
        status: 'active',
        location: 'Jeddah'
    },
    {
        id: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
        van_code: 'VAN-TEST-002',
        plate_number: 'DEF 5678',
        status: 'active',
        location: 'Riyadh'
    },
    {
        id: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
        van_code: 'VAN-TEST-003',
        plate_number: 'GHI 9012',
        status: 'active',
        location: 'Jeddah'
    }
];

const testAssignments = [
    {
        driver_id: '11111111-1111-1111-1111-111111111111',
        vehicle_id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        is_current: true
    },
    {
        driver_id: '22222222-2222-2222-2222-222222222222',
        vehicle_id: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
        is_current: true
    },
    {
        driver_id: '33333333-3333-3333-3333-333333333333',
        vehicle_id: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
        is_current: true
    }
];

// Helper to get timestamps
const hoursAgo = (hours) => new Date(Date.now() - hours * 60 * 60 * 1000).toISOString();
const daysAgo = (days) => new Date(Date.now() - days * 24 * 60 * 60 * 1000).toISOString();

const testMaintenanceReports = [
    // HIGH URGENCY (3)
    {
        report_code: 'MNT-TEST-001',
        driver_id: '11111111-1111-1111-1111-111111111111',
        vehicle_id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        issue_types: ['brakes'],
        urgency: 'high',
        description: 'صوت صرير قوي عند الضغط على الفرامل - Brake squealing noise',
        odometer_reading: 87500,
        status: 'pending',
        submitted_at: hoursAgo(2)
    },
    {
        report_code: 'MNT-TEST-002',
        driver_id: '22222222-2222-2222-2222-222222222222',
        vehicle_id: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
        issue_types: ['engine'],
        urgency: 'high',
        description: 'المحرك يصدر صوت طقطقة - Engine clicking noise on startup',
        odometer_reading: 45200,
        status: 'pending',
        submitted_at: hoursAgo(5)
    },
    {
        report_code: 'MNT-TEST-003',
        driver_id: '33333333-3333-3333-3333-333333333333',
        vehicle_id: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
        issue_types: ['engine', 'brakes'],
        urgency: 'high',
        description: 'الفرامل والمحرك - Brakes not responsive and engine overheating (OVERDUE >48h)',
        odometer_reading: 92100,
        status: 'pending',
        submitted_at: hoursAgo(50)  // Overdue for testing
    },
    // MEDIUM URGENCY (3)
    {
        report_code: 'MNT-TEST-004',
        driver_id: '11111111-1111-1111-1111-111111111111',
        vehicle_id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        issue_types: ['tires'],
        urgency: 'medium',
        description: 'الإطار الأمامي يحتاج تبديل - Front tire needs replacement',
        odometer_reading: 87600,
        status: 'pending',
        submitted_at: daysAgo(1)
    },
    {
        report_code: 'MNT-TEST-005',
        driver_id: '22222222-2222-2222-2222-222222222222',
        vehicle_id: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
        issue_types: ['battery'],
        urgency: 'medium',
        description: 'البطارية ضعيفة - Battery weak, slow start',
        odometer_reading: 45300,
        status: 'in_progress',
        submitted_at: daysAgo(3)
    },
    {
        report_code: 'MNT-TEST-006',
        driver_id: '33333333-3333-3333-3333-333333333333',
        vehicle_id: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
        issue_types: ['tires', 'battery'],
        urgency: 'medium',
        description: 'إطارات وبطارية - Tires and battery need replacement (OVERDUE >48h)',
        odometer_reading: 92200,
        status: 'pending',
        submitted_at: hoursAgo(60)  // Overdue for testing
    },
    // LOW URGENCY (4)
    {
        report_code: 'MNT-TEST-007',
        driver_id: '11111111-1111-1111-1111-111111111111',
        vehicle_id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        issue_types: ['oil_change'],
        urgency: 'low',
        description: 'تغيير زيت دوري - Regular oil change due',
        odometer_reading: 87700,
        status: 'pending',
        submitted_at: hoursAgo(12)
    },
    {
        report_code: 'MNT-TEST-008',
        driver_id: '22222222-2222-2222-2222-222222222222',
        vehicle_id: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
        issue_types: ['ac'],
        urgency: 'low',
        description: 'التكييف لا يبرد - AC not cooling enough',
        odometer_reading: 45400,
        status: 'completed',
        submitted_at: daysAgo(5)
    },
    {
        report_code: 'MNT-TEST-009',
        driver_id: '33333333-3333-3333-3333-333333333333',
        vehicle_id: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
        issue_types: ['lights'],
        urgency: 'low',
        description: 'الضوء الخلفي لا يعمل - Rear light not working',
        odometer_reading: 92300,
        status: 'pending',
        submitted_at: hoursAgo(6)
    },
    {
        report_code: 'MNT-TEST-010',
        driver_id: '11111111-1111-1111-1111-111111111111',
        vehicle_id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        issue_types: ['fridge'],
        urgency: 'low',
        description: 'الثلاجة تصدر صوت - Fridge making noise',
        odometer_reading: 87800,
        status: 'pending',
        submitted_at: hoursAgo(3)
    }
];

const testInspections = [
    {
        inspection_code: 'INS-TEST-001',
        driver_id: '11111111-1111-1111-1111-111111111111',
        vehicle_id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        inspection_type: 'receive',
        light_front: true,
        light_back: false,  // Issue!
        signal_right: true,
        signal_left: true,
        fridge_status: 'working',
        odometer_reading: 87500,
        submitted_at: daysAgo(1)
    },
    {
        inspection_code: 'INS-TEST-002',
        driver_id: '22222222-2222-2222-2222-222222222222',
        vehicle_id: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
        inspection_type: 'receive',
        light_front: true,
        light_back: true,
        signal_right: false,  // Issue!
        signal_left: false,   // Issue!
        fridge_status: 'not_working',  // Issue!
        odometer_reading: 45200,
        submitted_at: hoursAgo(12)
    },
    {
        inspection_code: 'INS-TEST-003',
        driver_id: '33333333-3333-3333-3333-333333333333',
        vehicle_id: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
        inspection_type: 'release',
        light_front: true,
        light_back: true,
        signal_right: true,
        signal_left: true,
        fridge_status: 'working',
        odometer_reading: 92100,
        submitted_at: hoursAgo(6)
    }
];

// Main execution
async function seedData() {
    console.log('🚀 FleetCheck Test Data Seeder');
    console.log('================================\n');

    try {
        // Step 1: Insert drivers (using upsert to handle conflicts)
        console.log('1️⃣  Inserting test drivers...');
        await supabaseInsert('drivers', testDrivers, true);
        console.log('   ✅ 3 drivers inserted\n');

        // Step 2: Insert vehicles
        console.log('2️⃣  Inserting test vehicles...');
        await supabaseInsert('vehicles', testVehicles, true);
        console.log('   ✅ 3 vehicles inserted\n');

        // Step 3: Insert assignments
        console.log('3️⃣  Inserting driver-vehicle assignments...');
        await supabaseInsert('driver_vehicle_assignments', testAssignments, true);
        console.log('   ✅ 3 assignments inserted\n');

        // Step 4: Insert maintenance reports
        console.log('4️⃣  Inserting 10 maintenance reports...');
        await supabaseInsert('maintenance_reports', testMaintenanceReports, true);
        console.log('   ✅ 10 maintenance reports inserted');
        console.log('      - 3 HIGH urgency (brakes, engine)');
        console.log('      - 3 MEDIUM urgency (tires, battery)');
        console.log('      - 4 LOW urgency (oil, ac, lights, fridge)');
        console.log('      - 2 are OVERDUE (>48 hours)\n');

        // Step 5: Insert inspections
        console.log('5️⃣  Inserting test inspections...');
        await supabaseInsert('inspections', testInspections, true);
        console.log('   ✅ 3 inspections inserted');
        console.log('      - INS-TEST-001: back light not working');
        console.log('      - INS-TEST-002: signals + fridge not working');
        console.log('      - INS-TEST-003: all OK\n');

        console.log('================================');
        console.log('✅ ALL TEST DATA INSERTED SUCCESSFULLY!');
        console.log('================================\n');

        console.log('📋 Summary:');
        console.log('   • Drivers: DRV-TEST-001, 002, 003');
        console.log('   • Vehicles: VAN-TEST-001, 002, 003');
        console.log('   • Maintenance: MNT-TEST-001 to 010');
        console.log('   • Inspections: INS-TEST-001, 002, 003\n');

        console.log('🗑️  To delete later, run delete-test-data.sql in Supabase SQL Editor');

    } catch (error) {
        console.error('❌ Error:', error.message);
        process.exit(1);
    }
}

// Run
seedData();
