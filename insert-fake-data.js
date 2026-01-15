const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = 'https://fwatvgxueajvjcwdokwh.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ3YXR2Z3h1ZWFqdmpjd2Rva3doIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2OTUyMTMsImV4cCI6MjA4MzI3MTIxM30.agTQDa2tEM7nvV6fzW_9K-RTK-o3vwxMatgUvuROXdA';

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

async function insertFakeData() {
    console.log('Starting fake data insertion...\n');

    try {
        // 1. Get existing drivers
        console.log('Fetching existing drivers...');
        const { data: drivers, error: driversError } = await supabase
            .from('drivers')
            .select('id, full_name')
            .neq('role', 'admin')
            .limit(10);

        if (driversError) throw driversError;
        if (!drivers || drivers.length === 0) {
            console.log('ERROR: No drivers found. Please add drivers first.');
            return;
        }
        console.log(`Found ${drivers.length} drivers\n`);

        // 2. Get existing vehicles
        console.log('Fetching existing vehicles...');
        const { data: vehicles, error: vehiclesError } = await supabase
            .from('vehicles')
            .select('id, van_code')
            .limit(10);

        if (vehiclesError) throw vehiclesError;
        console.log(`Found ${vehicles?.length || 0} vehicles\n`);

        // 3. Insert shift templates (if not exist)
        console.log('Checking shift templates...');
        const { data: existingTemplates } = await supabase.from('shift_templates').select('id');

        if (!existingTemplates || existingTemplates.length === 0) {
            console.log('Inserting shift templates...');
            const templates = [
                { name: 'صباحية', start_time: '06:00', end_time: '14:00', color: '#22C55E', is_active: true },
                { name: 'مسائية', start_time: '14:00', end_time: '22:00', color: '#3B82F6', is_active: true },
                { name: 'ليلية', start_time: '22:00', end_time: '06:00', color: '#8B5CF6', is_active: true }
            ];
            const { error: templateError } = await supabase.from('shift_templates').insert(templates);
            if (templateError) throw templateError;
            console.log('Shift templates inserted\n');
        } else {
            console.log('Shift templates already exist\n');
        }

        // Get templates for reference
        const { data: templates } = await supabase.from('shift_templates').select('id, name');

        // 4. Clear existing data first
        console.log('Clearing existing roster data...');
        await supabase.from('vehicle_assignments').delete().neq('id', '00000000-0000-0000-0000-000000000000');
        await supabase.from('time_records').delete().neq('id', '00000000-0000-0000-0000-000000000000');
        await supabase.from('leave_requests').delete().neq('id', '00000000-0000-0000-0000-000000000000');
        await supabase.from('scheduled_shifts').delete().neq('id', '00000000-0000-0000-0000-000000000000');
        console.log('Existing data cleared\n');

        // 5. Insert scheduled shifts for the current week and next week
        console.log('Inserting scheduled shifts...');
        const today = new Date();
        const shifts = [];

        for (let dayOffset = -7; dayOffset <= 14; dayOffset++) {
            const shiftDate = new Date(today);
            shiftDate.setDate(today.getDate() + dayOffset);
            const dateStr = shiftDate.toISOString().split('T')[0];

            // Skip Fridays (day 5)
            if (shiftDate.getDay() === 5) continue;

            // Assign shifts to drivers
            for (let i = 0; i < Math.min(drivers.length, 5); i++) {
                const template = templates[i % templates.length];
                const status = dayOffset < 0 ? (Math.random() > 0.15 ? 'completed' : 'absent') : 'scheduled';

                shifts.push({
                    driver_id: drivers[i].id,
                    template_id: template.id,
                    shift_date: dateStr,
                    start_time: template.name === 'صباحية' ? '06:00' : template.name === 'مسائية' ? '14:00' : '22:00',
                    end_time: template.name === 'صباحية' ? '14:00' : template.name === 'مسائية' ? '22:00' : '06:00',
                    status: status,
                    notes: null
                });
            }
        }

        const { data: insertedShifts, error: shiftsError } = await supabase
            .from('scheduled_shifts')
            .insert(shifts)
            .select();
        if (shiftsError) throw shiftsError;
        console.log(`Inserted ${insertedShifts?.length || 0} scheduled shifts\n`);

        // 6. Insert vehicle assignments for some shifts
        if (vehicles && vehicles.length > 0 && insertedShifts && insertedShifts.length > 0) {
            console.log('Inserting vehicle assignments...');
            const assignments = [];

            for (let i = 0; i < Math.min(insertedShifts.length, 20); i++) {
                const shift = insertedShifts[i];
                const vehicle = vehicles[i % vehicles.length];
                assignments.push({
                    shift_id: shift.id,
                    vehicle_id: vehicle.id,
                    driver_id: shift.driver_id,
                    assignment_date: shift.shift_date
                });
            }

            const { error: assignError } = await supabase.from('vehicle_assignments').insert(assignments);
            if (assignError) throw assignError;
            console.log(`Inserted ${assignments.length} vehicle assignments\n`);
        }

        // 7. Insert leave requests
        console.log('Inserting leave requests...');
        const leaveTypes = ['annual', 'sick', 'personal', 'emergency'];
        const leaveStatuses = ['pending', 'approved', 'rejected'];
        const leaveRequests = [];

        for (let i = 0; i < Math.min(drivers.length, 5); i++) {
            const startDate = new Date(today);
            startDate.setDate(today.getDate() + Math.floor(Math.random() * 30));
            const endDate = new Date(startDate);
            endDate.setDate(startDate.getDate() + Math.floor(Math.random() * 5) + 1);

            leaveRequests.push({
                driver_id: drivers[i].id,
                leave_type: leaveTypes[Math.floor(Math.random() * leaveTypes.length)],
                start_date: startDate.toISOString().split('T')[0],
                end_date: endDate.toISOString().split('T')[0],
                reason: 'طلب إجازة للاختبار',
                status: leaveStatuses[Math.floor(Math.random() * leaveStatuses.length)]
            });
        }

        const { error: leaveError } = await supabase.from('leave_requests').insert(leaveRequests);
        if (leaveError) throw leaveError;
        console.log(`Inserted ${leaveRequests.length} leave requests\n`);

        // 8. Insert time records for past shifts
        console.log('Inserting time records...');
        const timeRecords = [];

        for (let dayOffset = -7; dayOffset <= 0; dayOffset++) {
            const recordDate = new Date(today);
            recordDate.setDate(today.getDate() + dayOffset);

            if (recordDate.getDay() === 5) continue; // Skip Fridays

            for (let i = 0; i < Math.min(drivers.length, 4); i++) {
                const clockIn = new Date(recordDate);
                clockIn.setHours(6 + Math.floor(Math.random() * 2), Math.floor(Math.random() * 30), 0);

                const clockOut = new Date(recordDate);
                clockOut.setHours(14 + Math.floor(Math.random() * 3), Math.floor(Math.random() * 60), 0);

                const totalHours = ((clockOut - clockIn) / (1000 * 60 * 60)).toFixed(2);
                const overtimeHours = Math.max(0, totalHours - 8).toFixed(2);

                timeRecords.push({
                    driver_id: drivers[i].id,
                    clock_in: clockIn.toISOString(),
                    clock_out: clockOut.toISOString(),
                    total_hours: parseFloat(totalHours),
                    overtime_hours: parseFloat(overtimeHours)
                });
            }
        }

        const { error: timeError } = await supabase.from('time_records').insert(timeRecords);
        if (timeError) throw timeError;
        console.log(`Inserted ${timeRecords.length} time records\n`);

        console.log('========================================');
        console.log('All fake data inserted successfully!');
        console.log('========================================');
        console.log('\nYou can now test the roster management features in admin.html');

    } catch (error) {
        console.error('Error:', error.message);
        process.exit(1);
    }
}

insertFakeData();
