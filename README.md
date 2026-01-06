# FleetCheck - Antifat Vehicle Inspection System

**Simple vehicle inspection web app for Antifat fleet management**

## 📁 Project Structure

```
fleetcheck-antifat/
├── PRD.md                          # Product Requirements Document
├── README.md                       # This file
├── index.html                      # Main web form (Arabic/English)
├── styles.css                      # Custom styling
├── app.js                          # Form logic & validation
├── n8n-workflow.json               # n8n workflow export
├── deployment/
│   ├── netlify.toml               # Netlify config
│   └── vercel.json                # Vercel config
└── docs/
    ├── API.md                     # API documentation
    └── DEPLOYMENT.md              # Deployment guide
```

## 🚀 Quick Start

### For Development
1. Open `index.html` in browser
2. Test the form locally
3. Set up n8n workflow from `n8n-workflow.json`
4. Update webhook URL in `app.js`

### For Deployment
- **Netlify:** `netlify deploy --prod`
- **Vercel:** `vercel --prod`
- **Or:** Upload to any static hosting

## 🔧 n8n Workflow Setup

1. Import `n8n-workflow.json` to your n8n instance (nahrai.com)
2. Configure Google Sheets credentials
3. Configure Tekrar API credentials (when available)
4. Copy webhook URL
5. Update `WEBHOOK_URL` in `app.js`

## 📱 Testing Checklist

- [ ] Form loads on mobile
- [ ] Arabic text displays correctly (RTL)
- [ ] Can upload 4 photos
- [ ] Photo preview works
- [ ] Form validation works
- [ ] Submission sends to n8n webhook
- [ ] Data appears in Google Sheets
- [ ] Success message displays
- [ ] Error handling works

## 🎯 MVP Features

✅ Simple web form (mobile-responsive)  
✅ Upload 4 photos (front, back, left, right sides)  
✅ Driver name + van ID input  
✅ Submit to Google Sheets via n8n  
✅ Tekrar integration ready  
✅ Arabic/English support  

## 📊 Tech Stack

- **Frontend:** HTML5, Tailwind CSS, Vanilla JS
- **Automation:** n8n workflow
- **Storage:** Google Sheets + Tekrar
- **Hosting:** Netlify/Vercel (free tier)

## 🔐 Environment Variables

Create `.env` file (not committed):
```
WEBHOOK_URL=https://n8n.srv1200431.hstgr.cloud/webhook/fleetcheck
GOOGLE_SHEET_ID=your_sheet_id
TEKRAR_API_KEY=your_api_key (when available)
```

## 👥 Users

- **Drivers:** 80 users (mobile access)
- **Operations Team:** View data in Google Sheets

## 📈 Next Steps (After MVP Approval)

1. Get feedback from Mohammed Al-Jameh
2. Iterate based on driver testing
3. Add violation tracking
4. Add shift scheduling
5. Add fuel estimation
6. Build analytics dashboard

## 🤝 Stakeholders

- **Client:** Antifat Management
- **Primary Contact:** Mohammed Al-Jameh
- **Developer:** Osama (nahrai.com)
- **Production Build:** Video Studio Team

## 📝 Version History

- **v1.0** - MVP (Current)
  - Basic inspection form
  - Photo upload
  - Google Sheets integration
  - Tekrar ready

---

Built with ❤️ using vibe coding best practices
