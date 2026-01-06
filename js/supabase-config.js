// ========================================
// Supabase Configuration
// FleetCheck - Antifat Fleet Management
// ========================================

// Check if supabase is already defined (avoid duplicate declarations)
if (typeof supabase === 'undefined') {
    const SUPABASE_URL = 'https://fwatvgxueajvjcwdokwh.supabase.co';
    const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ3YXR2Z3h1ZWFqdmpjd2Rva3doIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2OTUyMTMsImV4cCI6MjA4MzI3MTIxM30.agTQDa2tEM7nvV6fzW_9K-RTK-o3vwxMatgUvuROXdA';

    // Initialize Supabase client
    var supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

    console.log('✅ Supabase initialized');
    console.log('📍 Project URL:', SUPABASE_URL);
}
