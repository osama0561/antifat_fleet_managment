# FleetCheck - Antifat Vehicle Inspection System
## Product Requirements Document (PRD)

**Project Name:** FleetCheck  
**Client:** Antifat Management  
**Date:** January 6, 2026  
**Version:** 1.0 (MVP)

---

## 1. PROJECT OVERVIEW

### Elevator Pitch
FleetCheck is a simple web-based vehicle inspection system that allows Antifat drivers to document van conditions through photos and data entry, with automatic syncing to Google Sheets and Tekrar software.

### Problem Statement
Antifat manages 80 vans across Jeddah and Riyadh. Current pain points:
- **Penalties (violations/fines)** appearing on vehicles without knowing which car or driver is responsible
- **Shift handover scheduling** issues between drivers
- **Fuel estimation** needs
- No structured way to document vehicle condition during inspections

### Target Users
1. **Drivers (80 users)** - Document vehicle condition at shift start/end
2. **Operations Team (Antifat)** - Review inspections, track violations, manage fleet

---

## 2. MVP SCOPE (Phase 1)

### Core Features - MUST HAVE
1. **Simple Web Form**
   - Mobile-responsive (drivers use phones)
   - Arabic & English support
   - Clean, minimal interface

2. **Photo Upload System**
   - Upload exactly 4 photos (van from all 4 sides)
   - Photo labels: Front, Back, Right Side, Left Side
   - Image compression for faster uploads
   - Preview before submission

3. **Driver Information Form**
   - Driver name (required)
   - Van number/ID (required)
   - Date & time (auto-captured)
   - Location (Jeddah/Riyadh) - dropdown
   - Notes field (optional - any observations)
   - Odometer reading (optional for Phase 1)

4. **Data Flow**
   - Submit button → Data validation
   - Store photos in cloud storage
   - Send data to Google Sheets
   - Sync to Tekrar software
   - Success confirmation message

5. **Google Sheets Integration**
   - Auto-create new row for each submission
   - Columns: Timestamp, Driver Name, Van ID, Location, Photo Links, Notes
   - Real-time sync

6. **Tekrar Integration**
   - Push inspection data to Tekrar database
   - Store in unified database

### Features - NOT IN MVP
- Real-time GPS tracking (future)
- Fuel tracking dashboard (future)
- Violation tracking system (future)
- Shift scheduling (future)
- Desktop app (web only)
- Driver authentication (simple name entry for now)

---

## 3. TECHNICAL ARCHITECTURE

### Tech Stack (Simple & Proven)
- **Frontend:** HTML5, CSS3 (Tailwind CSS), Vanilla JavaScript
- **Backend:** n8n workflow (your expertise!)
- **Storage:** 
  - Images: Cloudinary or Google Drive
  - Data: Google Sheets (primary) → Tekrar (secondary)
- **Hosting:** Vercel or Netlify (free tier)

### Data Flow Diagram
```
Driver Phone → Web Form → Submit
                ↓
         n8n Webhook receives data
                ↓
         ┌──────┴──────┐
         ↓             ↓
   Google Sheets    Tekrar API
         ↓             ↓
   Operations Team   Database
```

### n8n Workflow Components
1. **Webhook Node** - Receives form submission
2. **Image Processing** - Compress & upload to storage
3. **Google Sheets Node** - Append row
4. **HTTP Request Node** - Send to Tekrar API
5. **Response Node** - Send success/error back to form

---

## 4. USER FLOWS

### Driver Inspection Flow
1. Driver opens web form on phone
2. Selects van number from dropdown
3. Enters name
4. Takes/uploads 4 photos (front, back, left, right)
5. Adds any notes
6. Clicks "تسجيل" (Submit)
7. Sees success message: "تم التسجيل بنجاح!"
8. Can start new inspection

### Operations Team Flow (Phase 1 - Google Sheets)
1. Opens Google Sheet
2. Views all inspections in real-time
3. Clicks photo links to review images
4. Can filter by date, driver, van, location

---

## 5. UI/UX REQUIREMENTS

### Design Principles
- **Minimal & Clean** - Mohammed specifically requested "نظام مرة بسيط"
- **Mobile-First** - Drivers use phones
- **Arabic-Friendly** - RTL support, Arabic labels
- **Fast Loading** - Minimal JavaScript, optimized images
- **Clear CTAs** - Big, obvious buttons

### Color Scheme
- Primary: #2563eb (Blue - trust, professional)
- Success: #10b981 (Green)
- Error: #ef4444 (Red)
- Background: #f8fafc (Light gray)
- Text: #1e293b (Dark slate)

### Key Screens
1. **Main Form Screen** (only screen for MVP)
   - Header: Antifat logo + "FleetCheck"
   - Van selection dropdown
   - Driver name input
   - 4 photo upload zones (grid layout)
   - Notes textarea
   - Submit button (full-width, prominent)
   - Success/error messages

---

## 6. SECURITY & VALIDATION

### Data Validation
- Driver name: Required, 2-50 characters
- Van ID: Required, must match van list
- Photos: Required (all 4), max 10MB each, JPG/PNG only
- Notes: Optional, max 500 characters

### Security Measures (Basic for MVP)
- Form validation (client-side + server-side)
- Rate limiting on n8n webhook (prevent spam)
- HTTPS only
- No sensitive data stored (just names, van IDs, photos)
- API keys stored in n8n credentials (not in code)

### Error Handling
- Missing required fields → Clear error message
- Upload failures → "حاول مرة أخرى" (Try again)
- Network errors → Retry mechanism
- Success → Clear confirmation

---

## 7. FUTURE ENHANCEMENTS (Phase 2+)

Based on feedback from Mohammed Al-Jameh:

### Potential Features
1. **Violation Tracking**
   - Link penalties to specific driver/van
   - Photo evidence of violations
   - Cost tracking

2. **Shift Management**
   - Driver schedules
   - Handover checklist
   - Van assignment tracking

3. **Fuel Estimation**
   - Odometer tracking
   - Fuel consumption calculations
   - Cost per kilometer

4. **Advanced Features**
   - Driver authentication (login system)
   - GPS location auto-capture
   - Damage reporting workflow
   - Maintenance scheduling
   - Dashboard analytics
   - Mobile app (PWA first, then native)

5. **Tekrar Deep Integration**
   - Two-way sync
   - Automated workflows
   - Reporting features

---

## 8. SUCCESS METRICS

### MVP Success Criteria
1. Mohammed Al-Jameh approves the prototype
2. Drivers can complete inspection in < 2 minutes
3. 95%+ successful submissions (no errors)
4. Data appears in Google Sheets within 10 seconds
5. Works on all mobile browsers (Chrome, Safari, Samsung Internet)

### KPIs to Track Later
- Daily inspections completed
- Average inspection time
- Photo quality scores
- Violation reduction (after implementing tracking)

---

## 9. TIMELINE & MILESTONES

### Phase 1 (MVP) - Current Sprint
- **Day 1:** PRD + UI Design
- **Day 2:** Build web form (HTML/CSS)
- **Day 3:** n8n workflow setup
- **Day 4:** Integration testing
- **Day 5:** Show prototype to Mohammed
- **Day 6+:** Iterate based on feedback

### Phase 2 (After Approval)
- Add requested features
- Enhance UI based on driver feedback
- Build analytics dashboard
- Deeper Tekrar integration

---

## 10. STAKEHOLDERS & DECISIONS

### Key Decision Maker
- **Mohammed Al-Jameh** - Approve/reject prototype, feature prioritization

### Development Team
- **Osama (You)** - Full-stack automation specialist
- **Video Studio Team** - Can take prototype and build production version

### End Users
- **80 Drivers** - Daily users
- **Operations Team** - Data reviewers

---

## 11. TECHNICAL REQUIREMENTS

### Browser Support
- Mobile: iOS Safari 14+, Chrome 90+, Samsung Internet
- Desktop: Chrome, Firefox, Safari (latest 2 versions)

### Performance Requirements
- Page load: < 3 seconds on 4G
- Photo upload: < 30 seconds for all 4 photos
- Form submission: < 5 seconds total

### Language Support
- Arabic (primary)
- English (secondary)
- RTL layout support

---

## 12. ASSUMPTIONS & CONSTRAINTS

### Assumptions
- Drivers have smartphones with cameras
- Internet connection available (4G/WiFi)
- Google Sheets API access available
- Tekrar API documentation available
- Van IDs are already defined (1-80)

### Constraints
- Budget: Minimal (free/low-cost tools preferred)
- Timeline: Fast prototype needed
- Team: Solo developer (you) for prototype
- Infrastructure: Use existing nahrai.com tools (n8n)

---

## 13. RISKS & MITIGATION

| Risk | Impact | Mitigation |
|------|--------|------------|
| Drivers don't adopt system | High | Simple UI, training, clear value prop |
| Photos too large (slow upload) | Medium | Automatic compression, progress indicator |
| Network issues during submit | Medium | Retry logic, offline detection message |
| Tekrar API unavailable | Low | Google Sheets works independently |
| Google Sheets quota exceeded | Low | Monitor usage, upgrade if needed |

---

## 14. OPEN QUESTIONS

Need to clarify with Mohammed:
1. Exact van numbering system (Van-001 to Van-080?)
2. Tekrar API documentation/credentials
3. Specific photo requirements (resolution, quality)
4. When should drivers do inspections? (shift start/end/both?)
5. Who has access to Google Sheets?

---

## APPROVAL

**Status:** Ready for Development  
**Next Step:** Build prototype web form + n8n workflow  
**Review Date:** After prototype completion  
**Approver:** Mohammed Al-Jameh (Antifat)

---

*Document created following vibe coding best practices - clear requirements before coding begins.*
