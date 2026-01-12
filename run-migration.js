const { Client } = require('pg');

// Supabase connection - need database password
// Format: postgresql://postgres.[PROJECT-REF]:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres

const PROJECT_REF = 'fwatvgxueajvjcwdokwh';

// Try different connection methods
async function tryConnection() {
    console.log('========================================');
    console.log('FleetCheck - Database Migration');
    console.log('========================================\n');

    // The SQL to execute
    const migrationSQL = `
-- 1. Daily Reports Table
CREATE TABLE IF NOT EXISTS daily_reports (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    driver_id UUID NOT NULL REFERENCES drivers(id),
    report_date DATE NOT NULL,
    brand_mawzon INTEGER DEFAULT 0,
    brand_antifat INTEGER DEFAULT 0,
    brand_ck INTEGER DEFAULT 0,
    brand_routine INTEGER DEFAULT 0,
    brand_myhealthy INTEGER DEFAULT 0,
    total_meals INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(driver_id, report_date)
);

CREATE INDEX IF NOT EXISTS idx_daily_reports_driver_date ON daily_reports(driver_id, report_date);

-- 2. Meal Transfers Table
CREATE TABLE IF NOT EXISTS meal_transfers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    from_driver_id UUID NOT NULL REFERENCES drivers(id),
    to_driver_id UUID NOT NULL REFERENCES drivers(id),
    transfer_date DATE NOT NULL,
    brand_mawzon INTEGER DEFAULT 0,
    brand_antifat INTEGER DEFAULT 0,
    brand_ck INTEGER DEFAULT 0,
    brand_routine INTEGER DEFAULT 0,
    brand_myhealthy INTEGER DEFAULT 0,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    accepted_at TIMESTAMPTZ,
    CONSTRAINT no_self_transfer CHECK (from_driver_id != to_driver_id)
);

CREATE INDEX IF NOT EXISTS idx_meal_transfers_from ON meal_transfers(from_driver_id, transfer_date);
CREATE INDEX IF NOT EXISTS idx_meal_transfers_to ON meal_transfers(to_driver_id, transfer_date, status);

-- 3. Enable RLS & Policies
ALTER TABLE daily_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE meal_transfers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS daily_reports_all ON daily_reports;
CREATE POLICY daily_reports_all ON daily_reports FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS meal_transfers_all ON meal_transfers;
CREATE POLICY meal_transfers_all ON meal_transfers FOR ALL USING (true) WITH CHECK (true);

-- 4. Grant permissions
GRANT ALL ON daily_reports TO anon, authenticated;
GRANT ALL ON meal_transfers TO anon, authenticated;
    `;

    // Get password from command line args or environment
    const dbPassword = process.argv[2] || process.env.SUPABASE_DB_PASSWORD;

    if (!dbPassword) {
        console.log('ERROR: Database password required!\n');
        console.log('Usage: node run-migration.js YOUR_DATABASE_PASSWORD\n');
        console.log('To find your database password:');
        console.log('1. Go to: https://supabase.com/dashboard/project/fwatvgxueajvjcwdokwh/settings/database');
        console.log('2. Find "Database password" section');
        console.log('3. Click "Reset database password" if you don\'t remember it');
        console.log('4. Copy the password and run: node run-migration.js YOUR_PASSWORD');
        process.exit(1);
    }

    // URL encode the password (@ and other special chars)
    const encodedPassword = encodeURIComponent(dbPassword);

    // Try multiple connection formats
    const connectionStrings = [
        `postgresql://postgres.${PROJECT_REF}:${encodedPassword}@aws-0-us-west-1.pooler.supabase.com:6543/postgres`,
        `postgresql://postgres.${PROJECT_REF}:${encodedPassword}@aws-0-us-east-1.pooler.supabase.com:6543/postgres`,
        `postgresql://postgres.${PROJECT_REF}:${encodedPassword}@aws-0-eu-central-1.pooler.supabase.com:6543/postgres`,
    ];

    for (const connStr of connectionStrings) {
        const region = connStr.match(/aws-0-([^.]+)/)?.[1] || 'unknown';
        console.log(`\nTrying ${region}...`);

        const client = new Client({
            connectionString: connStr,
            ssl: { rejectUnauthorized: false }
        });

        try {
            await client.connect();
            console.log('Connected successfully!\n');

            console.log('Executing migration...');
            await client.query(migrationSQL);

            console.log('\n========================================');
            console.log('SUCCESS! Tables created:');
            console.log('  - daily_reports');
            console.log('  - meal_transfers');
            console.log('========================================');

            await client.end();
            return; // Success, exit

        } catch (error) {
            console.log(`  Failed: ${error.message.substring(0, 50)}...`);
            try { await client.end(); } catch(e) {}
        }
    }

    console.log('\n========================================');
    console.log('All connection attempts failed.');
    console.log('Please run SQL manually at:');
    console.log('https://supabase.com/dashboard/project/fwatvgxueajvjcwdokwh/sql/new');
    console.log('========================================');
}

tryConnection();