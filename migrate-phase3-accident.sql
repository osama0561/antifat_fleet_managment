-- ========================================
-- FleetCheck Phase 3: Accident Reports Table (SIMPLIFIED)
-- Run this in Supabase SQL Editor
-- ========================================

-- ========================================
-- IF YOU ALREADY CREATED THE OLD TABLE, RUN THIS FIRST:
-- ========================================

-- Drop the old table (if exists with old columns)
DROP TABLE IF EXISTS accident_reports;

-- ========================================
-- CREATE NEW SIMPLIFIED TABLE
-- ========================================

CREATE TABLE IF NOT EXISTS accident_reports (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    report_code TEXT NOT NULL UNIQUE,
    driver_id UUID REFERENCES drivers(id),
    vehicle_id UUID REFERENCES vehicles(id),

    -- Accident details
    accident_type TEXT NOT NULL CHECK (accident_type IN ('collision', 'scratch', 'rollover', 'hit_and_run', 'pedestrian', 'other')),
    description TEXT NOT NULL,
    accident_location TEXT,

    -- Damage photos (up to 5)
    photo_1 TEXT,
    photo_2 TEXT,
    photo_3 TEXT,
    photo_4 TEXT,
    photo_5 TEXT,

    -- Official documents (Najm/Police and Taqdir)
    najm_report TEXT,      -- Najm report or Police report (PDF/image URL)
    taqdir_report TEXT,    -- Taqdir damage assessment report (PDF/image URL)

    -- GPS Location
    gps_latitude DECIMAL(10, 8),
    gps_longitude DECIMAL(11, 8),
    gps_accuracy DECIMAL(10, 2),

    -- Status tracking
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'under_investigation', 'resolved', 'closed')),
    insurance_claim_number TEXT,
    insurance_status TEXT,
    resolution_notes TEXT,
    resolved_at TIMESTAMPTZ,

    -- Timestamps
    submitted_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_accident_driver ON accident_reports(driver_id);
CREATE INDEX IF NOT EXISTS idx_accident_vehicle ON accident_reports(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_accident_status ON accident_reports(status);
CREATE INDEX IF NOT EXISTS idx_accident_type ON accident_reports(accident_type);
CREATE INDEX IF NOT EXISTS idx_accident_submitted ON accident_reports(submitted_at DESC);

-- Enable RLS (Row Level Security)
ALTER TABLE accident_reports ENABLE ROW LEVEL SECURITY;

-- Policy: Authenticated users can insert
CREATE POLICY "Authenticated users can insert accident reports"
ON accident_reports
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Policy: Authenticated users can view all accident reports
CREATE POLICY "Authenticated users can view accident reports"
ON accident_reports
FOR SELECT
TO authenticated
USING (true);

-- Policy: Authenticated users can update reports
CREATE POLICY "Authenticated users can update accident reports"
ON accident_reports
FOR UPDATE
TO authenticated
USING (true);

-- ========================================
-- VERIFY TABLE CREATED
-- ========================================
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'accident_reports'
ORDER BY ordinal_position;

-- ========================================
-- NOTES:
-- ========================================
-- report_code: Unique identifier (ACC-timestamp)
-- accident_type: collision, scratch, rollover, hit_and_run, pedestrian, other
-- description: What happened (required)
-- accident_location: Where it happened (text)
-- photo_1 to photo_5: Damage photos (URLs)
-- najm_report: Najm traffic report OR Police report if Najm not available
-- taqdir_report: Taqdir damage assessment report
-- status: pending → under_investigation → resolved/closed

-- ========================================
-- COLUMNS REMOVED (compared to old version):
-- ========================================
-- has_injuries, injury_description
-- has_other_party, other_party_plate, other_party_info
-- police_reported, police_report_number
-- (These are now captured in the Najm/Police report document)
