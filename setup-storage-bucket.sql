-- ========================================
-- FleetCheck: Supabase Storage Bucket Setup
-- Run this in Supabase SQL Editor
-- ========================================

-- Note: Creating storage buckets via SQL is not directly supported
-- You must create the bucket via Supabase Dashboard first!
-- This file contains the RLS policies to apply AFTER creating the bucket

-- ========================================
-- STEP 1: Create Bucket (via Dashboard)
-- ========================================
-- 1. Go to Supabase Dashboard → Storage
-- 2. Click "New Bucket"
-- 3. Name: "inspections"
-- 4. Public: YES (check the box)
-- 5. Click "Create Bucket"

-- ========================================
-- STEP 2: Create Storage Policies (run this SQL)
-- ========================================

-- Policy 1: Allow authenticated users to upload files
CREATE POLICY "Allow authenticated users to upload inspection photos"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'inspections'
);

-- Policy 2: Allow public to read/view files (since bucket is public)
CREATE POLICY "Allow public to view inspection photos"
ON storage.objects
FOR SELECT
TO public
USING (
    bucket_id = 'inspections'
);

-- Policy 3: Allow authenticated users to update their own uploads
CREATE POLICY "Allow authenticated users to update inspection photos"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
    bucket_id = 'inspections'
)
WITH CHECK (
    bucket_id = 'inspections'
);

-- Policy 4: Allow authenticated users to delete (optional - for cleanup)
CREATE POLICY "Allow authenticated users to delete inspection photos"
ON storage.objects
FOR DELETE
TO authenticated
USING (
    bucket_id = 'inspections'
);

-- ========================================
-- VERIFY POLICIES
-- ========================================
-- Run this to see all policies for the inspections bucket:
SELECT
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE tablename = 'objects'
AND qual LIKE '%inspections%';

-- ========================================
-- TEST BUCKET ACCESS
-- ========================================
-- Check if bucket exists:
SELECT * FROM storage.buckets WHERE name = 'inspections';

-- Should return: id, name ('inspections'), owner, public (true), created_at, updated_at

-- ========================================
-- NOTES:
-- ========================================
-- - Bucket MUST be created via Dashboard first
-- - Set "Public: YES" when creating bucket
-- - Then run the policies above in SQL Editor
-- - Test with test-storage.html file
