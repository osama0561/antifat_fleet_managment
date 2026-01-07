-- ========================================
-- FleetCheck Phase 1: Database Migration
-- Run this in Supabase SQL Editor
-- ========================================

-- Add new columns to inspections table
ALTER TABLE inspections
ADD COLUMN IF NOT EXISTS photo_dashboard TEXT,
ADD COLUMN IF NOT EXISTS light_front BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS light_back BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS signal_right BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS signal_left BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS fridge_status TEXT,
ADD COLUMN IF NOT EXISTS gps_latitude DECIMAL(10, 8),
ADD COLUMN IF NOT EXISTS gps_longitude DECIMAL(11, 8),
ADD COLUMN IF NOT EXISTS gps_accuracy DECIMAL(10, 2),
ADD COLUMN IF NOT EXISTS submitted_at TIMESTAMPTZ DEFAULT NOW();

-- Verify the columns were added
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'inspections'
ORDER BY ordinal_position;

-- ========================================
-- NOTES:
-- ========================================
-- photo_dashboard: URL to dashboard/odometer photo
-- light_front: Front lights working (true/false)
-- light_back: Back lights working (true/false)
-- signal_right: Right signal working (true/false)
-- signal_left: Left signal working (true/false)
-- fridge_status: 'working', 'not_working', or 'no_fridge'
-- gps_latitude: GPS latitude coordinate
-- gps_longitude: GPS longitude coordinate
-- gps_accuracy: GPS accuracy in meters
-- submitted_at: Exact timestamp of submission
