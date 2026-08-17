require('dotenv').config();

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const path = require('path');

const config = require('./config/config');
const { testConnection } = require('./config/database');

// Import routes
const authRoutes = require('./routes/auth.routes');
const medicineRoutes = require('./routes/medicine.routes');
const userMedicineRoutes = require('./routes/userMedicine.routes');
const doseLogRoutes = require('./routes/doseLog.routes');
const healthLogRoutes = require('./routes/healthLog.routes');
const prescriptionRoutes = require('./routes/prescription.routes');
const familyRoutes = require('./routes/family.routes');
const appointmentRoutes = require('./routes/appointment.routes');
const adminRoutes = require('./routes/admin.routes');

const app = express();

// ─── Security ───────────────────────────────────────
app.use(helmet());

// ─── CORS ───────────────────────────────────────────
app.use(cors());

// ─── Rate Limiting ──────────────────────────────────
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 2000, // 2000 requests per 15 minutes for smooth search & app usage
  message: {
    success: false,
    message: 'অনেক বেশি অনুরোধ পাঠিয়েছেন, কিছুক্ষণ পর চেষ্টা করুন',
  },
});
app.use('/api/', limiter);

// Stricter rate limit for OTP endpoints
const otpLimiter = rateLimit({
  windowMs: 10 * 60 * 1000, // 10 minutes
  max: 5, // 5 OTP requests per 10 min
  message: {
    success: false,
    message: 'অনেকবার OTP পাঠানো হয়েছে, ১০ মিনিট পর চেষ্টা করুন',
  },
});

// ─── Body Parsing ───────────────────────────────────
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// ─── Static Files (Prescription photos) ─────────────
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// ─── API Routes ─────────────────────────────────────
app.use('/api/v1/auth/send-otp', otpLimiter);
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/medicines', medicineRoutes);
app.use('/api/v1/user-medicines', userMedicineRoutes);
app.use('/api/v1/dose-logs', doseLogRoutes);
app.use('/api/v1/health-logs', healthLogRoutes);
app.use('/api/v1/prescriptions', prescriptionRoutes);
app.use('/api/v1/family', familyRoutes);
app.use('/api/v1/appointments', appointmentRoutes);
app.use('/api/v1/admin', adminRoutes);

// ─── Health Check ───────────────────────────────────
app.get('/api/v1/health', (req, res) => {
  res.json({
    success: true,
    message: 'OshudhSathi API is running! ✅',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
  });
});

// ─── 404 Handler ────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Route ${req.method} ${req.originalUrl} not found`,
  });
});

// ─── Global Error Handler ───────────────────────────
app.use((err, req, res, next) => {
  console.error('💥 Error:', err.message);

  // Multer file size error
  if (err.code === 'LIMIT_FILE_SIZE') {
    return res.status(400).json({
      success: false,
      message: 'ফাইলের সাইজ ৫MB এর বেশি হতে পারবে না',
    });
  }

  res.status(err.status || 500).json({
    success: false,
    message: config.app.env === 'development' ? err.message : 'সার্ভারে সমস্যা হয়েছে',
  });
});

// ─── Start Server ───────────────────────────────────
async function startServer() {
  await testConnection();

  app.listen(config.app.port, '0.0.0.0', () => {
    console.log(`\n🚀 OshudhSathi API running on port ${config.app.port} (0.0.0.0)`);
    console.log(`📌 Environment: ${config.app.env}`);
    console.log(`🔗 Local LAN: http://192.168.31.106:${config.app.port}/api/v1/health\n`);
  });
}

startServer();

module.exports = app;
