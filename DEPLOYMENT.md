# 🚀 OshudhSathi (ওষুধসাথী) — cPanel Deployment Guide

## 📁 Directory Mapping

```
public_html/
├── api/                    ← Node.js Express API (cPanel Node.js App)
├── index.html              ← Landing page (React Vite build output from landing/dist)
├── assets/                 ← Landing page static assets
├── admin/                  ← Admin panel (React Vite build output from admin/dist)
│   ├── index.html
│   └── assets/
└── .htaccess               ← URL rewriting for SPA + API proxying
```

## 🛠️ Deployment Steps

1. **MySQL Database Setup (cPanel phpMyAdmin)**
   - Create database `oshudhsathi_db` in cPanel.
   - Run SQL file `api/database/schema.sql`.

2. **Backend API Deployment**
   - Go to cPanel → **Setup Node.js App**.
   - Set Application root: `api`
   - Set Application URL: `api`
   - Set Startup file: `app.js`
   - Configure Environment Variables (`DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, `JWT_SECRET`, `SMS_API_KEY`).
   - Run `npm install` and Start App.

3. **Landing Page Deployment**
   - Run `npm run build` inside `landing/`.
   - Upload all contents of `landing/dist/` into `public_html/`.

4. **Admin Panel Deployment**
   - Run `npm run build` inside `admin/`.
   - Upload all contents of `admin/dist/` into `public_html/admin/`.

5. **.htaccess Configuration**
   - Ensure `.htaccess` is uploaded to `public_html/.htaccess`.
