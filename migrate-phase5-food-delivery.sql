-- ========================================
-- FleetCheck Phase 5: Food Delivery Tracking
-- Run this in Supabase SQL Editor
-- ========================================

-- ========================================
-- 1. CREATE FOOD DELIVERIES TABLE
-- ========================================
CREATE TABLE IF NOT EXISTS food_deliveries (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    delivery_code TEXT NOT NULL UNIQUE,
    driver_id UUID REFERENCES drivers(id),
    vehicle_id UUID REFERENCES vehicles(id),

    -- Client/Order Info
    client_name TEXT NOT NULL,
    order_details TEXT,

    -- Pickup Phase (from kitchen)
    pickup_location TEXT DEFAULT 'المطبخ المركزي',
    pickup_photo TEXT,
    pickup_time TIMESTAMPTZ,
    pickup_gps_latitude DECIMAL(10, 8),
    pickup_gps_longitude DECIMAL(11, 8),

    -- Delivery Phase (to client)
    delivery_location TEXT,
    delivery_photo TEXT,
    delivery_time TIMESTAMPTZ,
    delivery_gps_latitude DECIMAL(10, 8),
    delivery_gps_longitude DECIMAL(11, 8),

    -- Status tracking
    status TEXT DEFAULT 'picked_up' CHECK (status IN ('picked_up', 'in_transit', 'delivered', 'cancelled')),
    notes TEXT,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_food_driver ON food_deliveries(driver_id);
CREATE INDEX IF NOT EXISTS idx_food_vehicle ON food_deliveries(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_food_status ON food_deliveries(status);
CREATE INDEX IF NOT EXISTS idx_food_created ON food_deliveries(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_food_pickup_time ON food_deliveries(pickup_time DESC);

-- Enable RLS
ALTER TABLE food_deliveries ENABLE ROW LEVEL SECURITY;

-- Policy: Authenticated users can insert
CREATE POLICY "Authenticated users can insert food deliveries"
ON food_deliveries FOR INSERT TO authenticated WITH CHECK (true);

-- Policy: Authenticated users can view
CREATE POLICY "Authenticated users can view food deliveries"
ON food_deliveries FOR SELECT TO authenticated USING (true);

-- Policy: Authenticated users can update
CREATE POLICY "Authenticated users can update food deliveries"
ON food_deliveries FOR UPDATE TO authenticated USING (true);

-- ========================================
-- VERIFY TABLE CREATED
-- ========================================
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'food_deliveries'
ORDER BY ordinal_position;

-- ========================================
-- NOTES
-- ========================================
-- delivery_code: Unique ID (DEL-timestamp)
-- client_name: Where the food is going
-- order_details: Optional description of the order
-- pickup_photo: Photo of food when leaving kitchen
-- delivery_photo: Photo of food when delivered to client
-- status: picked_up -> in_transit -> delivered
--
-- Workflow:
-- 1. Driver at kitchen: Enters client name, takes pickup photo -> status = 'picked_up'
-- 2. Driver en route: status = 'in_transit' (automatic)
-- 3. Driver at client: Takes delivery photo -> status = 'delivered'
