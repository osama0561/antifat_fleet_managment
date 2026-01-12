-- Add location_url column to meal_transfers table
ALTER TABLE meal_transfers ADD COLUMN IF NOT EXISTS location_url TEXT;

-- Add comment for documentation
COMMENT ON COLUMN meal_transfers.location_url IS 'Google Maps or other location URL for the delivery address';