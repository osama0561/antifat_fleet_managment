-- Add license_photo column to accident_reports table
ALTER TABLE accident_reports ADD COLUMN IF NOT EXISTS license_photo TEXT;

-- Add comment for documentation
COMMENT ON COLUMN accident_reports.license_photo IS 'URL for the uploaded driver license photo (stored in Supabase storage)';