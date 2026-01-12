// ========================================
// FleetCheck Supabase Configuration
// ========================================

const SUPABASE_CONFIG = {
    url: 'https://fwatvgxueajvjcwdokwh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ3YXR2Z3h1ZWFqdmpjd2Rva3doIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2OTUyMTMsImV4cCI6MjA4MzI3MTIxM30.agTQDa2tEM7nvV6fzW_9K-RTK-o3vwxMatgUvuROXdA',
    serviceRoleKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ3YXR2Z3h1ZWFqdmpjd2Rva3doIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NzY5NTIxMywiZXhwIjoyMDgzMjcxMjEzfQ.MaqKAlb1S9r_yyLZpwszRm0uvYoPP3LVupNl6dI_tlI'
};

// Project Reference: fwatvgxueajvjcwdokwh
// Region: (check Supabase dashboard)

// REST API Endpoints:
// - Database: https://fwatvgxueajvjcwdokwh.supabase.co/rest/v1/
// - Auth: https://fwatvgxueajvjcwdokwh.supabase.co/auth/v1/
// - Storage: https://fwatvgxueajvjcwdokwh.supabase.co/storage/v1/

// Tables:
// - drivers (users with roles: admin, driver, kitchen)
// - vehicles
// - inspections
// - maintenance_reports
// - accident_reports
// - food_batches
// - meal_deliveries

module.exports = SUPABASE_CONFIG;