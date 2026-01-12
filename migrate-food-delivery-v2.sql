-- ========================================
-- FleetCheck: Food Delivery v2 - Daily Reports & Transfers
-- Run this in Supabase SQL Editor
-- ========================================

-- Drop old tables if they exist (optional - remove if you want to keep old data)
-- DROP TABLE IF EXISTS meal_deliveries;
-- DROP TABLE IF EXISTS food_batches;

-- ========================================
-- 1. Daily Reports Table
-- ========================================
CREATE TABLE IF NOT EXISTS daily_reports (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    driver_id UUID NOT NULL REFERENCES drivers(id),
    report_date DATE NOT NULL,

    -- Brand quantities
    brand_mawzon INTEGER DEFAULT 0,
    brand_antifat INTEGER DEFAULT 0,
    brand_ck INTEGER DEFAULT 0,
    brand_routine INTEGER DEFAULT 0,
    brand_myhealthy INTEGER DEFAULT 0,
    total_meals INTEGER DEFAULT 0,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- One report per driver per day
    UNIQUE(driver_id, report_date)
);

-- Index for fast lookups
CREATE INDEX IF NOT EXISTS idx_daily_reports_driver_date ON daily_reports(driver_id, report_date);

-- ========================================
-- 2. Meal Transfers Table
-- ========================================
CREATE TABLE IF NOT EXISTS meal_transfers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    from_driver_id UUID NOT NULL REFERENCES drivers(id),
    to_driver_id UUID NOT NULL REFERENCES drivers(id),
    transfer_date DATE NOT NULL,

    -- Client/Order info
    client_name VARCHAR(255),
    subscription_id VARCHAR(50),
    district VARCHAR(100),
    duration VARCHAR(20) DEFAULT 'permanent',  -- permanent, temporary, today

    -- Brand quantities
    brand_mawzon INTEGER DEFAULT 0,
    brand_antifat INTEGER DEFAULT 0,
    brand_ck INTEGER DEFAULT 0,
    brand_routine INTEGER DEFAULT 0,
    brand_myhealthy INTEGER DEFAULT 0,

    -- Status: pending, accepted, rejected
    status VARCHAR(20) DEFAULT 'pending',

    created_at TIMESTAMPTZ DEFAULT NOW(),
    accepted_at TIMESTAMPTZ,

    -- Prevent self-transfers
    CONSTRAINT no_self_transfer CHECK (from_driver_id != to_driver_id)
);

-- Indexes for fast lookups
CREATE INDEX IF NOT EXISTS idx_meal_transfers_from ON meal_transfers(from_driver_id, transfer_date);
CREATE INDEX IF NOT EXISTS idx_meal_transfers_to ON meal_transfers(to_driver_id, transfer_date, status);

-- ========================================
-- 3. Enable Row Level Security (RLS)
-- ========================================
ALTER TABLE daily_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE meal_transfers ENABLE ROW LEVEL SECURITY;

-- Allow all authenticated users to read/write (adjust as needed)
CREATE POLICY "daily_reports_all" ON daily_reports FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "meal_transfers_all" ON meal_transfers FOR ALL USING (true) WITH CHECK (true);

-- ========================================
-- 4. Grant permissions
-- ========================================
GRANT ALL ON daily_reports TO anon, authenticated;
GRANT ALL ON meal_transfers TO anon, authenticated;

-- ========================================
-- Done!
-- ========================================
SELECT 'Food Delivery v2 tables created successfully!' as status;