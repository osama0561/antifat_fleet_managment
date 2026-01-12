-- ========================================
-- FleetCheck: Kitchen Food Delivery System
-- Run this in Supabase SQL Editor
-- ========================================

-- 1. Create food_batches table
CREATE TABLE IF NOT EXISTS food_batches (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    batch_code TEXT NOT NULL UNIQUE,
    kitchen_staff_id UUID REFERENCES drivers(id),
    driver_id UUID REFERENCES drivers(id),
    client_name TEXT NOT NULL,
    meal_count INTEGER NOT NULL DEFAULT 1,
    delivered_count INTEGER DEFAULT 0,
    delivery_location TEXT,
    notes TEXT,
    kitchen_signature TEXT,
    driver_signature TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'assigned', 'in_progress', 'completed', 'cancelled')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    assigned_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ
);

-- 2. Create meal_deliveries table for individual meal tracking
CREATE TABLE IF NOT EXISTS meal_deliveries (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    batch_id UUID REFERENCES food_batches(id) ON DELETE CASCADE,
    meal_number INTEGER NOT NULL,
    recipient_name TEXT,
    photo_url TEXT,
    gps_latitude DOUBLE PRECISION,
    gps_longitude DOUBLE PRECISION,
    delivered_at TIMESTAMPTZ DEFAULT NOW(),
    notes TEXT
);

-- 3. Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_food_batches_status ON food_batches(status);
CREATE INDEX IF NOT EXISTS idx_food_batches_kitchen_staff ON food_batches(kitchen_staff_id);
CREATE INDEX IF NOT EXISTS idx_food_batches_driver ON food_batches(driver_id);
CREATE INDEX IF NOT EXISTS idx_food_batches_created ON food_batches(created_at);
CREATE INDEX IF NOT EXISTS idx_meal_deliveries_batch ON meal_deliveries(batch_id);

-- 4. Add comments for documentation
COMMENT ON TABLE food_batches IS 'Food delivery batches created by kitchen staff';
COMMENT ON TABLE meal_deliveries IS 'Individual meal deliveries within a batch';
COMMENT ON COLUMN food_batches.kitchen_signature IS 'Base64 signature image from kitchen staff';
COMMENT ON COLUMN food_batches.driver_signature IS 'Base64 signature image from driver on pickup';
COMMENT ON COLUMN meal_deliveries.meal_number IS 'Sequential number of meal within batch (1 to meal_count)';

-- 5. Enable Row Level Security
ALTER TABLE food_batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE meal_deliveries ENABLE ROW LEVEL SECURITY;

-- 6. Create policies for food_batches
CREATE POLICY "Allow authenticated users to view food_batches"
ON food_batches FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Allow authenticated users to insert food_batches"
ON food_batches FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "Allow authenticated users to update food_batches"
ON food_batches FOR UPDATE
TO authenticated
USING (true);

-- 7. Create policies for meal_deliveries
CREATE POLICY "Allow authenticated users to view meal_deliveries"
ON meal_deliveries FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Allow authenticated users to insert meal_deliveries"
ON meal_deliveries FOR INSERT
TO authenticated
WITH CHECK (true);

-- 8. Verification queries
SELECT 'food_batches table created' as status
WHERE EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'food_batches');

SELECT 'meal_deliveries table created' as status
WHERE EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'meal_deliveries');

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'food_batches'
ORDER BY ordinal_position;

-- ========================================
-- 9. ADD KITCHEN STAFF ROLE (if not exists)
-- ========================================
-- Update drivers table to support kitchen role
-- Role values: 'driver', 'admin', 'kitchen'

-- Example: Add a kitchen staff member
-- INSERT INTO drivers (driver_code, full_name, email, phone, role, is_active)
-- VALUES ('KITCHEN-001', 'موظف المطبخ', 'kitchen@antifat.com', '0500000000', 'kitchen', true);

-- Don't forget to create auth user in Supabase Auth:
-- Go to Authentication > Users > Add user
-- Email: kitchen@antifat.com, Password: password123

-- ========================================
-- VERIFICATION COMPLETE
-- ========================================
SELECT 'Kitchen Food Batches Migration Complete' as status;