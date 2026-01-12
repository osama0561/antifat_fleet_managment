-- ========================================
-- FleetCheck: Phase 1 - Inspection Form Updates
-- Run this in Supabase SQL Editor
-- ========================================

-- Add new columns to inspections table
ALTER TABLE inspections
ADD COLUMN IF NOT EXISTS odometer_reading INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS photo_notes TEXT;

-- Add comment for documentation
COMMENT ON COLUMN inspections.odometer_reading IS 'Manual odometer reading in km';
COMMENT ON COLUMN inspections.photo_notes IS 'Optional photo URL for notes/issues';

-- Verify the changes
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'inspections'
AND column_name IN ('odometer_reading', 'photo_notes');

-- ========================================
-- VERIFICATION QUERY
-- ========================================
SELECT 'Phase 1 Migration Complete' as status;
