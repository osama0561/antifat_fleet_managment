-- ========================================
-- FleetCheck: Phase 3 - Accident Report Updates
-- Run this in Supabase SQL Editor
-- ========================================

-- Add new columns to accident_reports table
ALTER TABLE accident_reports
ADD COLUMN IF NOT EXISTS damage_location TEXT[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS fault_percentage INTEGER DEFAULT 0;

-- Add comments for documentation
COMMENT ON COLUMN accident_reports.damage_location IS 'Array of damage locations: front, back, left, right, top, multiple';
COMMENT ON COLUMN accident_reports.fault_percentage IS 'Driver fault percentage 0-100 from Najm/Police report';

-- Verify the changes
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'accident_reports'
AND column_name IN ('damage_location', 'fault_percentage');

-- ========================================
-- VERIFICATION QUERY
-- ========================================
SELECT 'Phase 3 Migration Complete' as status;
