-- Add video_url column to maintenance_reports table
ALTER TABLE maintenance_reports ADD COLUMN IF NOT EXISTS video_url TEXT;

-- Add comment for documentation
COMMENT ON COLUMN maintenance_reports.video_url IS 'URL for the uploaded video showing the maintenance issue (stored in Supabase storage)';