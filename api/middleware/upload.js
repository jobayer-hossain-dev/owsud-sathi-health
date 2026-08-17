const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { v4: uuidv4 } = require('uuid');
const config = require('../config/config');

// Ensure upload directory exists
const uploadDir = path.join(__dirname, '..', config.upload.dir, 'prescriptions');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    // Create per-user directory securely
    const userId = req.user && req.user.id ? req.user.id : 'anonymous';
    const userDir = path.join(uploadDir, `user_${userId}`);
    if (!fs.existsSync(userDir)) {
      fs.mkdirSync(userDir, { recursive: true });
    }
    cb(null, userDir);
  },
  filename: function (req, file, cb) {
    // Random UUID file name to prevent path traversal & overwrites
    const extMap = {
      'image/jpeg': '.jpg',
      'image/jpg': '.jpg',
      'image/png': '.png',
      'image/webp': '.webp',
    };
    const ext = extMap[file.mimetype] || path.extname(file.originalname).toLowerCase();
    cb(null, `rx_${uuidv4()}${ext}`);
  },
});

const fileFilter = (req, file, cb) => {
  const allowedMimeTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
  if (allowedMimeTypes.includes(file.mimetype.toLowerCase())) {
    cb(null, true);
  } else {
    cb(new Error('শুধুমাত্র JPG, PNG, বা WebP প্রেসক্রিপশন ছবি আপলোড করা যাবে'), false);
  }
};

const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: config.upload.maxFileSize || 5242880, // 5MB limit
    files: 5,
  },
});

module.exports = upload;
