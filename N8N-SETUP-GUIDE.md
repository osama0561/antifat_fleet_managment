# n8n Notification System Setup Guide

This guide explains how to set up the FleetCheck notification system using n8n.

## Prerequisites

1. **n8n Instance** - Either:
   - Self-hosted: https://docs.n8n.io/hosting/
   - n8n Cloud: https://n8n.io/cloud/

2. **Email Service** - One of:
   - Gmail (with App Password)
   - SMTP server
   - SendGrid
   - Mailgun

3. **Supabase Access**:
   - URL: `https://fwatvgxueajvjcwdokwh.supabase.co`
   - Anon Key: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ3YXR2Z3h1ZWFqdmpjd2Rva3doIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2OTUyMTMsImV4cCI6MjA4MzI3MTIxM30.agTQDa2tEM7nvV6fzW_9K-RTK-o3vwxMatgUvuROXdA`

---

## Step 1: Run Database Migrations

First, run the SQL functions in Supabase SQL Editor:

```sql
-- Copy contents from: migrate-oil-change-function.sql
```

This creates the following functions:
- `get_vehicles_needing_oil_change()` - Returns vehicles that need oil change
- `get_expiring_vehicle_documents(days)` - Returns expiring registrations/insurance
- `get_expiring_driver_licenses(days)` - Returns expiring driver licenses
- `get_overdue_maintenance()` - Returns pending maintenance > 48 hours

---

## Step 2: Create n8n Workflows

### Workflow 1: New Maintenance Report Alert

**Purpose:** Send email when driver submits maintenance report

**Nodes:**

```
[Webhook] --> [IF Urgency High?] --> [Send Urgent Email]
                    |
                    +--> [Send Normal Email]
```

**1. Webhook Node:**
- HTTP Method: `POST`
- Path: `maintenance-alert`
- Authentication: None (or Header Auth for security)

**2. IF Node:**
- Condition: `{{ $json.urgency }}` equals `high`

**3. Send Email Node (High Priority):**
- To: `maintenance@antifat.com, fleet@antifat.com`
- Subject: `🔴 صيانة عاجلة - {{ $json.vehicle_code }} - {{ $json.issue_types }}`
- Body Type: HTML
- Body:
```html
<div dir="rtl" style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
  <div style="background: #dc2626; color: white; padding: 20px; border-radius: 10px 10px 0 0;">
    <h2 style="margin: 0;">🔴 طلب صيانة عاجل</h2>
  </div>

  <div style="background: white; padding: 20px; border: 1px solid #e5e7eb;">
    <table style="width: 100%; border-collapse: collapse;">
      <tr>
        <td style="padding: 10px; border-bottom: 1px solid #e5e7eb; font-weight: bold; width: 40%;">كود التقرير:</td>
        <td style="padding: 10px; border-bottom: 1px solid #e5e7eb;">{{ $json.report_code }}</td>
      </tr>
      <tr>
        <td style="padding: 10px; border-bottom: 1px solid #e5e7eb; font-weight: bold;">السائق:</td>
        <td style="padding: 10px; border-bottom: 1px solid #e5e7eb;">{{ $json.driver_name }} ({{ $json.driver_code }})</td>
      </tr>
      <tr>
        <td style="padding: 10px; border-bottom: 1px solid #e5e7eb; font-weight: bold;">المركبة:</td>
        <td style="padding: 10px; border-bottom: 1px solid #e5e7eb;">{{ $json.vehicle_code }}</td>
      </tr>
      <tr>
        <td style="padding: 10px; border-bottom: 1px solid #e5e7eb; font-weight: bold;">نوع المشكلة:</td>
        <td style="padding: 10px; border-bottom: 1px solid #e5e7eb; color: #dc2626; font-weight: bold;">{{ $json.issue_types }}</td>
      </tr>
      <tr>
        <td style="padding: 10px; border-bottom: 1px solid #e5e7eb; font-weight: bold;">الأولوية:</td>
        <td style="padding: 10px; border-bottom: 1px solid #e5e7eb;">
          <span style="background: #dc2626; color: white; padding: 3px 10px; border-radius: 20px;">{{ $json.urgency }}</span>
        </td>
      </tr>
      <tr>
        <td style="padding: 10px; border-bottom: 1px solid #e5e7eb; font-weight: bold;">قراءة العداد:</td>
        <td style="padding: 10px; border-bottom: 1px solid #e5e7eb;">{{ $json.odometer }} كم</td>
      </tr>
    </table>

    <div style="background: #fef3c7; padding: 15px; border-radius: 8px; margin-top: 20px;">
      <strong>الوصف:</strong>
      <p style="margin: 10px 0 0 0;">{{ $json.description }}</p>
    </div>

    <p style="margin-top: 20px; text-align: center;">
      <a href="https://your-app-url/admin.html" style="background: #dc2626; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; display: inline-block;">
        فتح لوحة التحكم
      </a>
    </p>
  </div>

  <div style="background: #f3f4f6; padding: 15px; border-radius: 0 0 10px 10px; text-align: center; color: #6b7280; font-size: 12px;">
    FleetCheck - نظام إدارة الأسطول | Antifat
  </div>
</div>
```

---

### Workflow 2: Inspection Issues Alert

**Purpose:** Send email when driver reports lights/fridge not working

**Nodes:**

```
[Webhook] --> [Send Email]
```

**1. Webhook Node:**
- HTTP Method: `POST`
- Path: `inspection-issues`

**2. Send Email Node:**
- To: `maintenance@antifat.com`
- Subject: `⚠️ مشاكل في فحص المركبة - {{ $json.vehicle_code }}`
- Body:
```html
<div dir="rtl" style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
  <div style="background: #f59e0b; color: white; padding: 20px; border-radius: 10px 10px 0 0;">
    <h2 style="margin: 0;">⚠️ تم اكتشاف مشاكل أثناء الفحص</h2>
  </div>

  <div style="background: white; padding: 20px; border: 1px solid #e5e7eb;">
    <table style="width: 100%; border-collapse: collapse;">
      <tr>
        <td style="padding: 10px; border-bottom: 1px solid #e5e7eb; font-weight: bold;">كود الفحص:</td>
        <td style="padding: 10px; border-bottom: 1px solid #e5e7eb;">{{ $json.inspection_code }}</td>
      </tr>
      <tr>
        <td style="padding: 10px; border-bottom: 1px solid #e5e7eb; font-weight: bold;">نوع الفحص:</td>
        <td style="padding: 10px; border-bottom: 1px solid #e5e7eb;">{{ $json.inspection_type === 'receive' ? 'استلام' : 'تسليم' }}</td>
      </tr>
      <tr>
        <td style="padding: 10px; border-bottom: 1px solid #e5e7eb; font-weight: bold;">السائق:</td>
        <td style="padding: 10px; border-bottom: 1px solid #e5e7eb;">{{ $json.driver_name }} ({{ $json.driver_code }})</td>
      </tr>
      <tr>
        <td style="padding: 10px; border-bottom: 1px solid #e5e7eb; font-weight: bold;">المركبة:</td>
        <td style="padding: 10px; border-bottom: 1px solid #e5e7eb;">{{ $json.vehicle_code }} - {{ $json.plate_number }}</td>
      </tr>
    </table>

    <div style="background: #fef3c7; padding: 15px; border-radius: 8px; margin-top: 20px; border-right: 4px solid #f59e0b;">
      <strong style="color: #92400e;">المشاكل المكتشفة ({{ $json.issues_count }}):</strong>
      <pre style="white-space: pre-wrap; margin: 10px 0 0 0; font-family: Arial;">{{ $json.issues_list }}</pre>
    </div>

    <table style="width: 100%; margin-top: 20px; border-collapse: collapse;">
      <tr>
        <td style="padding: 8px; text-align: center; {{ $json.light_front ? 'background: #d1fae5; color: #065f46;' : 'background: #fee2e2; color: #991b1b;' }}">
          الأنوار الأمامية: {{ $json.light_front ? '✅' : '❌' }}
        </td>
        <td style="padding: 8px; text-align: center; {{ $json.light_back ? 'background: #d1fae5; color: #065f46;' : 'background: #fee2e2; color: #991b1b;' }}">
          الأنوار الخلفية: {{ $json.light_back ? '✅' : '❌' }}
        </td>
      </tr>
      <tr>
        <td style="padding: 8px; text-align: center; {{ $json.signal_right ? 'background: #d1fae5; color: #065f46;' : 'background: #fee2e2; color: #991b1b;' }}">
          إشارة اليمين: {{ $json.signal_right ? '✅' : '❌' }}
        </td>
        <td style="padding: 8px; text-align: center; {{ $json.signal_left ? 'background: #d1fae5; color: #065f46;' : 'background: #fee2e2; color: #991b1b;' }}">
          إشارة اليسار: {{ $json.signal_left ? '✅' : '❌' }}
        </td>
      </tr>
      <tr>
        <td colspan="2" style="padding: 8px; text-align: center; {{ $json.fridge_status === 'working' ? 'background: #d1fae5; color: #065f46;' : 'background: #fee2e2; color: #991b1b;' }}">
          الثلاجة: {{ $json.fridge_status === 'working' ? '✅ تعمل' : '❌ لا تعمل' }}
        </td>
      </tr>
    </table>
  </div>
</div>
```

---

### Workflow 3: Daily Oil Change Alert (Scheduled)

**Purpose:** Daily check for vehicles needing oil change

**Nodes:**

```
[Schedule] --> [HTTP Request to Supabase] --> [IF Has Results] --> [Send Email]
```

**1. Schedule Trigger:**
- Trigger Time: `07:00`
- Timezone: `Asia/Riyadh`

**2. HTTP Request Node:**
- Method: `POST`
- URL: `https://fwatvgxueajvjcwdokwh.supabase.co/rest/v1/rpc/get_vehicles_needing_oil_change`
- Headers:
  - `apikey`: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (anon key)
  - `Authorization`: `Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (anon key)
  - `Content-Type`: `application/json`

**3. IF Node:**
- Condition: `{{ $json.length }}` greater than `0`

**4. Send Email Node:**
- Subject: `🛢️ تنبيه تغيير زيت - {{ $json.length }} مركبات`

---

### Workflow 4: Document Expiry Alert (Scheduled)

**Purpose:** Daily check for expiring documents

**Nodes:**

```
[Schedule] --> [HTTP: Vehicle Docs] --> [HTTP: Driver Licenses] --> [Merge] --> [IF Any] --> [Send Email]

```

**1. Schedule Trigger:**
- Trigger Time: `08:00`
- Timezone: `Asia/Riyadh`

**2. HTTP Request - Vehicle Documents:**
- Method: `POST`
- URL: `https://fwatvgxueajvjcwdokwh.supabase.co/rest/v1/rpc/get_expiring_vehicle_documents`
- Body: `{"days_ahead": 30}`

**3. HTTP Request - Driver Licenses:**
- Method: `POST`
- URL: `https://fwatvgxueajvjcwdokwh.supabase.co/rest/v1/rpc/get_expiring_driver_licenses`
- Body: `{"days_ahead": 30}`

**4. Send Email:**
- Subject: `📅 تنبيه انتهاء وثائق - {{ $now.format('yyyy-MM-dd') }}`

---

### Workflow 5: Overdue Maintenance Alert (Scheduled)

**Purpose:** Alert for maintenance pending > 48 hours

**Nodes:**

```
[Schedule] --> [HTTP Request] --> [IF Has Results] --> [Send Email]
```

**1. Schedule Trigger:**
- Trigger Interval: Every 6 hours
- Timezone: `Asia/Riyadh`

**2. HTTP Request:**
- Method: `POST`
- URL: `https://fwatvgxueajvjcwdokwh.supabase.co/rest/v1/rpc/get_overdue_maintenance`

**3. Send Email:**
- Subject: `⏰ تقارير صيانة متأخرة - {{ $json.length }} تقرير`

---

### Workflow 6: Daily Summary (Scheduled)

**Purpose:** Daily maintenance summary at end of day

**Nodes:**

```
[Schedule 6PM] --> [HTTP: Pending] --> [HTTP: In Progress] --> [HTTP: Completed Today] --> [Merge] --> [Send Email]
```

---

## Step 3: Update App Webhook URLs

After creating the workflows in n8n, copy the webhook URLs and update:

### maintenance.html (Line ~272):
```javascript
const N8N_WEBHOOK_URL = 'https://your-n8n-instance.com/webhook/maintenance-alert';
```

### inspection.html (Line ~433):
```javascript
const N8N_INSPECTION_WEBHOOK_URL = 'https://your-n8n-instance.com/webhook/inspection-issues';
```

---

## Step 4: Test the Workflows

### Test Maintenance Webhook:
```bash
curl -X POST https://your-n8n-webhook-url/maintenance-alert \
  -H "Content-Type: application/json" \
  -d '{
    "report_code": "MNT-TEST-001",
    "driver_name": "أحمد محمد",
    "driver_code": "DRV-001",
    "vehicle_code": "VAN-023",
    "issue_types": "engine, brakes",
    "urgency": "high",
    "description": "صوت غريب من المحرك عند السرعات العالية",
    "odometer": "87432",
    "photo_count": 2,
    "has_video": true,
    "submitted_at": "2024-01-15T10:30:00Z"
  }'
```

### Test Inspection Webhook:
```bash
curl -X POST https://your-n8n-webhook-url/inspection-issues \
  -H "Content-Type: application/json" \
  -d '{
    "inspection_code": "INS-TEST-001",
    "inspection_type": "receive",
    "driver_name": "فاطمة علي",
    "driver_code": "DRV-002",
    "vehicle_code": "VAN-045",
    "plate_number": "ABC 1234",
    "odometer": 45000,
    "light_front": true,
    "light_back": false,
    "signal_right": true,
    "signal_left": false,
    "fridge_status": "not_working",
    "issues_list": "الأنوار الخلفية لا تعمل\nإشارة اليسار لا تعمل\nالثلاجة لا تعمل",
    "issues_count": 3,
    "submitted_at": "2024-01-15T06:45:00Z"
  }'
```

### Test Supabase Functions:
```bash
# Test oil change function
curl -X POST https://fwatvgxueajvjcwdokwh.supabase.co/rest/v1/rpc/get_vehicles_needing_oil_change \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json"

# Test expiring documents
curl -X POST https://fwatvgxueajvjcwdokwh.supabase.co/rest/v1/rpc/get_expiring_vehicle_documents \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"days_ahead": 30}'
```

---

## Notification Summary

| Notification | Trigger | Schedule | Email To |
|-------------|---------|----------|----------|
| New Maintenance Report | Webhook (real-time) | - | maintenance@antifat.com |
| Inspection Issues | Webhook (real-time) | - | maintenance@antifat.com |
| Oil Change Due | Scheduled | Daily 7 AM | fleet@antifat.com |
| Document Expiry | Scheduled | Daily 8 AM | fleet@antifat.com |
| Overdue Maintenance | Scheduled | Every 6 hours | maintenance@antifat.com |
| Daily Summary | Scheduled | Daily 6 PM | management@antifat.com |

---

## Security Notes

1. **Webhook Security**: Consider adding authentication to webhooks:
   - Header authentication with a secret key
   - IP whitelisting if possible

2. **API Keys**: The anon key is safe to expose in client-side code as it has limited permissions through RLS

3. **Email Configuration**: Use environment variables for email credentials in n8n

---

## Troubleshooting

### Webhook not receiving data:
1. Check webhook URL is correct in app code
2. Verify n8n workflow is active
3. Check browser console for CORS errors
4. Test webhook manually with curl

### Scheduled workflows not running:
1. Verify timezone is set correctly (Asia/Riyadh)
2. Check n8n execution logs
3. Verify Supabase functions exist and work

### Emails not sending:
1. Check email credentials in n8n
2. Verify SMTP settings
3. Check spam folder
4. Review n8n execution logs for errors
