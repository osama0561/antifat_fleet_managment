# FleetCheck - Technical Documentation
## Antifat Fleet Management System

**Version:** 1.0
**Last Updated:** January 2026
**Language:** Arabic (RTL) + English

---

## Table of Contents
1. [Project Overview](#project-overview)
2. [Tech Stack](#tech-stack)
3. [Database Schema](#database-schema)
4. [File Structure](#file-structure)
5. [Page Documentation](#page-documentation)
6. [Functions Reference](#functions-reference)
7. [Supabase Configuration](#supabase-configuration)
8. [How to Modify](#how-to-modify)

---

## Project Overview

FleetCheck is a fleet management system designed for Antifat's 80 van drivers in Saudi Arabia. The system allows drivers to:
- Submit daily vehicle inspection reports (receive/release)
- Report maintenance issues
- Report accidents with photo evidence
- Upload official documents (Najm/Taqdir reports)

Administrators can:
- View all reports with filters
- Manage drivers (add, activate/deactivate)
- Manage vehicles (add, change status)
- Track document expiry dates
- View audit logs of all admin actions

---

## Tech Stack

| Technology | Purpose |
|------------|---------|
| HTML5 | Structure |
| Tailwind CSS (CDN) | Styling |
| Vanilla JavaScript | Logic & Interactivity |
| Supabase | Database, Auth, Storage |

**No build tools required** - All files work directly in browser.

---

## Database Schema

### Tables

#### `drivers`
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| email | TEXT | Login email (unique) |
| full_name | TEXT | Driver's full name |
| driver_code | TEXT | Unique code (e.g., DRV-001) |
| phone | TEXT | Phone number |
| is_active | BOOLEAN | Whether driver can login |
| role | TEXT | 'driver' or 'admin' |
| driver_type | TEXT | 'permanent' or 'temporary' |
| temp_start_date | DATE | For temporary drivers |
| temp_end_date | DATE | For temporary drivers |
| license_expiry | DATE | License expiration date |
| id_expiry | DATE | ID expiration date |
| last_login | TIMESTAMPTZ | Last login timestamp |
| last_inspection | TIMESTAMPTZ | Last inspection timestamp |
| admin_notes | TEXT | Notes from admin |
| created_at | TIMESTAMPTZ | Creation timestamp |

#### `vehicles`
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| van_code | TEXT | Unique code (e.g., VAN-001) |
| plate_number | TEXT | License plate |
| location | TEXT | Base location |
| status | TEXT | 'active', 'idle', 'accident', 'maintenance' |
| registration_expiry | DATE | Registration expiration |
| insurance_expiry | DATE | Insurance expiration |
| last_inspection_date | DATE | Last inspection date |
| admin_notes | TEXT | Notes from admin |
| created_at | TIMESTAMPTZ | Creation timestamp |

#### `driver_vehicle_assignments`
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| driver_id | UUID | FK to drivers |
| vehicle_id | UUID | FK to vehicles |
| is_current | BOOLEAN | Current assignment |
| is_temporary | BOOLEAN | Temporary swap |
| temp_start_date | DATE | Temp assignment start |
| temp_end_date | DATE | Temp assignment end |
| original_driver_id | UUID | Original driver (for swaps) |
| notes | TEXT | Assignment notes |
| assigned_at | TIMESTAMPTZ | Assignment timestamp |

#### `inspections`
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| inspection_code | TEXT | Unique code (INS-timestamp) |
| driver_id | UUID | FK to drivers |
| vehicle_id | UUID | FK to vehicles |
| inspection_type | TEXT | 'receive' or 'release' |
| photo_front | TEXT | Front photo URL |
| photo_back | TEXT | Back photo URL |
| photo_right | TEXT | Right side photo URL |
| photo_left | TEXT | Left side photo URL |
| photo_dashboard | TEXT | Dashboard/odometer URL |
| light_front | BOOLEAN | Front lights working |
| light_back | BOOLEAN | Back lights working |
| signal_right | BOOLEAN | Right signal working |
| signal_left | BOOLEAN | Left signal working |
| fridge_status | TEXT | 'working', 'not_working', 'no_fridge' |
| notes | TEXT | Additional notes |
| declaration_accepted | BOOLEAN | Driver declaration |
| gps_latitude | DECIMAL | GPS latitude |
| gps_longitude | DECIMAL | GPS longitude |
| gps_accuracy | DECIMAL | GPS accuracy (meters) |
| submitted_at | TIMESTAMPTZ | Submission timestamp |

#### `maintenance_reports`
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| report_code | TEXT | Unique code (MNT-timestamp) |
| driver_id | UUID | FK to drivers |
| vehicle_id | UUID | FK to vehicles |
| issue_types | TEXT[] | Array of issue types |
| urgency | TEXT | 'low', 'medium', 'high' |
| description | TEXT | Problem description |
| odometer_reading | INTEGER | Odometer reading |
| photo_1 | TEXT | Photo URL |
| photo_2 | TEXT | Photo URL |
| photo_3 | TEXT | Photo URL |
| status | TEXT | 'pending', 'in_progress', 'completed' |
| gps_latitude | DECIMAL | GPS latitude |
| gps_longitude | DECIMAL | GPS longitude |
| submitted_at | TIMESTAMPTZ | Submission timestamp |

#### `accident_reports`
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| report_code | TEXT | Unique code (ACC-timestamp) |
| driver_id | UUID | FK to drivers |
| vehicle_id | UUID | FK to vehicles |
| accident_type | TEXT | Type of accident |
| description | TEXT | Accident description |
| accident_location | TEXT | Location text |
| photo_1 to photo_5 | TEXT | Damage photo URLs |
| najm_report | TEXT | Najm/Police report URL |
| taqdir_report | TEXT | Taqdir report URL |
| status | TEXT | 'pending', 'under_investigation', 'resolved', 'closed' |
| gps_latitude | DECIMAL | GPS latitude |
| gps_longitude | DECIMAL | GPS longitude |
| submitted_at | TIMESTAMPTZ | Submission timestamp |

#### `audit_log`
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| admin_email | TEXT | Admin who performed action |
| action | TEXT | Action performed |
| target_type | TEXT | 'driver', 'vehicle', 'maintenance', 'accident' |
| target_id | UUID | ID of affected record |
| details | JSONB | Additional details |
| created_at | TIMESTAMPTZ | Action timestamp |

---

## File Structure

```
fleet antifat app/
├── login.html              # Login page (drivers & admins)
├── index.html              # Driver home page (menu)
├── inspection.html         # Receipt/Release form
├── maintenance.html        # Maintenance report form
├── accident.html           # Accident report form
├── admin.html              # Admin dashboard
├── migrate-phase1.sql      # Initial database setup
├── migrate-phase2-maintenance.sql  # Maintenance table
├── migrate-phase3-accident.sql     # Accident table
├── migrate-phase4-admin.sql        # Admin features
├── setup-storage-bucket.sql        # Storage bucket setup
├── test-storage.html       # Storage testing page
└── DOCUMENTATION.md        # This file
```

---

## Page Documentation

### 1. login.html - Login Page

**Purpose:** Authentication for both drivers and admins

**Key Elements:**
- `#email` - Email input field
- `#password` - Password input field
- `#loginForm` - Login form
- `#errorMessage` - Error display div

**Flow:**
1. User enters email/password
2. Authenticates with Supabase Auth
3. Fetches user role from `drivers` table
4. Redirects to `admin.html` (if admin) or `index.html` (if driver)
5. Updates `last_login` timestamp

**Key Functions:**
```javascript
// Login handler
document.getElementById('loginForm').addEventListener('submit', async function(e) {
    // 1. Authenticate with Supabase
    // 2. Check role in drivers table
    // 3. Verify is_active status
    // 4. Update last_login
    // 5. Redirect based on role
});
```

---

### 2. index.html - Driver Home Page

**Purpose:** Main menu for drivers to access forms

**Key Elements:**
- `#driverName` - Shows logged-in driver name
- `#driverCode` - Shows driver code
- `#vehicleName` - Shows assigned vehicle
- `#logoutBtn` - Logout button

**Menu Cards:**
1. Receipt & Release (inspection.html)
2. Maintenance Report (maintenance.html)
3. Accident Report (accident.html)

**Key Functions:**
```javascript
async function init() {
    // 1. Check session
    // 2. Get driver info from drivers table
    // 3. Get assigned vehicle from driver_vehicle_assignments
    // 4. Display info
}
```

---

### 3. inspection.html - Receipt/Release Form

**Purpose:** Daily vehicle inspection with photos

**Key Elements:**
- `input[name="inspectionType"]` - Receive/Release radio buttons
- `#photoFront, #photoBack, #photoRight, #photoLeft` - 4 side photos
- `#photoDashboard` - Dashboard/odometer photo
- `#lightFront, #lightBack, #signalRight, #signalLeft` - Light checkboxes
- `input[name="fridgeStatus"]` - Fridge status radios
- `#declaration` - Declaration checkbox
- `#notes` - Notes textarea

**Flow:**
1. Driver selects inspection type (receive/release)
2. Takes 5 photos (4 sides + dashboard)
3. Checks all lights
4. Selects fridge status
5. Accepts declaration
6. Submits form

**Key Functions:**
```javascript
function handlePhoto(input, side) {
    // Validates file type and size
    // Stores in photos object
    // Updates UI preview
}

async function uploadPhoto(file, inspectionCode, side) {
    // Uploads to Supabase Storage
    // Returns public URL
}

// Form submission
document.getElementById('inspectionForm').addEventListener('submit', async (e) => {
    // 1. Validate all fields
    // 2. Upload 5 photos
    // 3. Save to inspections table
    // 4. Update vehicle status (active/idle)
});
```

**Vehicle Status Updates:**
- Receive (استلام) → Vehicle status = 'active'
- Release (تسليم) → Vehicle status = 'idle'

---

### 4. maintenance.html - Maintenance Report Form

**Purpose:** Report vehicle maintenance issues

**Key Elements:**
- `input[name="issueType"]` - Issue type checkboxes (engine, brakes, tires, ac, lights, battery, fridge, other)
- `input[name="urgency"]` - Urgency radios (low, medium, high)
- `#description` - Problem description
- `#photo1, #photo2, #photo3` - Optional photos
- `#odometer` - Odometer reading

**Key Functions:**
```javascript
function handlePhoto(input, num) {
    // Same as inspection - validates and previews
}

async function uploadPhoto(file, reportCode, num) {
    // Uploads to inspections/maintenance/{reportCode}/
}

// Form submission saves to maintenance_reports table
```

---

### 5. accident.html - Accident Report Form

**Purpose:** Report vehicle accidents with official documents

**Key Elements:**
- `input[name="accidentType"]` - Accident type radios (collision, scratch, rollover, hit_and_run, pedestrian, other)
- `#description` - Accident description
- `#accidentLocation` - Location text input
- `#photo1-5` - Up to 5 damage photos
- `#najmReport` - Najm/Police report upload (PDF/image)
- `#taqdirReport` - Taqdir report upload (PDF/image)

**Key Functions:**
```javascript
function handlePhoto(input, num) {
    // For damage photos - validates images only
}

function handleDocument(input, type) {
    // For official documents - validates PDF and images
}

async function uploadFile(file, reportCode, folder, name) {
    // Uploads to inspections/accidents/{reportCode}/photos/ or /docs/
}

// Form submission:
// 1. Uploads photos
// 2. Uploads documents
// 3. Saves to accident_reports table
// 4. Updates vehicle status to 'accident'
```

---

### 6. admin.html - Admin Dashboard

**Purpose:** Full fleet management for administrators

**Sections:**

#### Stats Cards
- Total vehicles (with breakdown: active/idle/accident)
- Total drivers (active only)
- Today's inspections count
- Pending maintenance count
- Pending accidents count

#### Tab: Drivers (السائقين)
- Search by name or code
- Filter: all, active, inactive, temporary
- Add new driver (permanent or temporary)
- Activate/Deactivate drivers
- View assigned vehicle

#### Tab: Vehicles (المركبات)
- Search by code or plate
- Filter: all, active, idle, accident
- Add new vehicle
- Change vehicle status

#### Tab: Inspections (الفحوصات)
- Filter by date
- Filter by type (receive/release)
- View details with photos

#### Tab: Maintenance (الصيانة)
- Filter by status (pending, in_progress, completed)
- Filter by urgency (high, medium, low)
- Update status
- View details with photos

#### Tab: Accidents (الحوادث)
- Filter by status (pending, under_investigation, resolved, closed)
- Update status
- View details with photos and documents

**Key Functions:**
```javascript
async function init() {
    // 1. Verify session
    // 2. Verify admin role
    // 3. Load stats
    // 4. Load initial data
}

async function loadStats() {
    // Fetches counts for all stats cards
}

async function loadDrivers() {
    // Fetches and displays driver list with filters
}

async function loadVehicles() {
    // Fetches and displays vehicle list with filters
}

async function loadInspections() {
    // Fetches inspections for selected date
}

async function loadMaintenance() {
    // Fetches maintenance reports with filters
}

async function loadAccidents() {
    // Fetches accident reports with filters
}

async function logAction(action, targetType, targetId, details) {
    // Records admin action to audit_log table
}

// Detail view functions:
async function showInspectionDetail(id) { ... }
async function showMaintenanceDetail(id) { ... }
async function showAccidentDetail(id) { ... }

// Status update functions:
async function toggleDriverStatus(id, currentStatus) { ... }
async function updateVehicleStatus(id, newStatus) { ... }
async function updateMaintenanceStatus(id, newStatus) { ... }
async function updateAccidentStatus(id, newStatus) { ... }
```

---

## Functions Reference

### Global Functions (All Pages)

```javascript
// Supabase Client Initialization
const mySupabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_KEY);

// Session Check
const { data: { session } } = await mySupabase.auth.getSession();

// Logout
await mySupabase.auth.signOut();
```

### Photo Handling

```javascript
// Configuration
const CONFIG = {
    MAX_FILE_SIZE: 10 * 1024 * 1024,  // 10MB
    ALLOWED_FILE_TYPES: ['image/jpeg', 'image/jpg', 'image/png']
};

// Upload to Storage
const { data, error } = await mySupabase.storage
    .from('inspections')
    .upload(fileName, file, {
        cacheControl: '3600',
        upsert: true,
        contentType: file.type
    });

// Get Public URL
const { data: urlData } = mySupabase.storage
    .from('inspections')
    .getPublicUrl(fileName);
```

### GPS Location

```javascript
function getLocation() {
    navigator.geolocation.getCurrentPosition(
        (position) => {
            currentLocation = {
                latitude: position.coords.latitude,
                longitude: position.coords.longitude,
                accuracy: position.coords.accuracy
            };
        },
        (error) => { ... },
        { enableHighAccuracy: true, timeout: 10000 }
    );
}
```

---

## Supabase Configuration

### Credentials
```javascript
const SUPABASE_URL = 'https://fwatvgxueajvjcwdokwh.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'; // anon key
```

### Storage Bucket
- Name: `inspections`
- Public access: enabled
- Folder structure:
  ```
  inspections/
  ├── INS-{timestamp}/     # Inspection photos
  │   ├── front.jpg
  │   ├── back.jpg
  │   ├── right.jpg
  │   ├── left.jpg
  │   └── dashboard.jpg
  ├── maintenance/
  │   └── MNT-{timestamp}/
  │       ├── photo1.jpg
  │       ├── photo2.jpg
  │       └── photo3.jpg
  └── accidents/
      └── ACC-{timestamp}/
          ├── photos/
          │   └── damage1-5.jpg
          └── docs/
              ├── najm_report.pdf
              └── taqdir_report.pdf
  ```

### Row Level Security (RLS)
All tables have RLS enabled with policies allowing:
- Authenticated users can INSERT
- Authenticated users can SELECT
- Authenticated users can UPDATE (for status changes)

---

## How to Modify

### Adding a New Field to Driver Form

1. **Database:** Add column to `drivers` table
   ```sql
   ALTER TABLE drivers ADD COLUMN new_field TEXT;
   ```

2. **Admin Form (admin.html):** Add input in `#addDriverForm`
   ```html
   <div>
       <label class="block text-sm font-semibold mb-1">New Field</label>
       <input type="text" name="new_field" class="w-full px-3 py-2 border rounded-lg">
   </div>
   ```

3. **Form Handler:** Add to data object
   ```javascript
   const data = {
       // ... existing fields
       new_field: form.new_field.value || null,
   };
   ```

### Adding a New Report Type

1. Create new HTML file (e.g., `newreport.html`)
2. Copy structure from `maintenance.html`
3. Create database table with migration SQL
4. Add menu card in `index.html`
5. Add tab in `admin.html`

### Changing Supabase Project

1. Update `SUPABASE_URL` and `SUPABASE_KEY` in ALL HTML files:
   - login.html
   - index.html
   - inspection.html
   - maintenance.html
   - accident.html
   - admin.html

2. Run all migration SQL files in order:
   - migrate-phase1.sql
   - migrate-phase2-maintenance.sql
   - migrate-phase3-accident.sql
   - migrate-phase4-admin.sql
   - setup-storage-bucket.sql

### Styling Changes

All styling uses Tailwind CSS classes. Common patterns:
- Cards: `bg-white rounded-xl shadow-sm p-6`
- Buttons: `bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 rounded-lg`
- Inputs: `w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500`

### Adding Arabic Text

The app uses RTL layout. When adding text:
- Arabic text displays automatically RTL
- Use `dir="ltr"` for English-only elements (like phone numbers)
- Font: Segoe UI (system font)

---

## Troubleshooting

### Common Issues

1. **"User not found" error on login**
   - User exists in Supabase Auth but not in `drivers` table
   - Solution: Add user to `drivers` table with matching email

2. **Photos not uploading**
   - Check storage bucket exists and is public
   - Check file size (max 10MB)
   - Check file type (JPG/PNG only)

3. **Admin can't access dashboard**
   - User's role column must be 'admin'
   - Run: `UPDATE drivers SET role = 'admin' WHERE email = 'user@email.com';`

4. **Vehicle status not updating**
   - Check RLS policies allow UPDATE
   - Check vehicle ID is correct

---

## Support

For issues or questions, check:
1. Browser console for JavaScript errors
2. Supabase dashboard for database/auth issues
3. Network tab for API request failures

---

*Documentation generated for FleetCheck v1.0*
