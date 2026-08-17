const fs = require('fs');
const path = require('path');
const zlib = require('zlib');

// Generate a high-res 512x512 PNG with Emerald Green (#047857) background and Medical Pill / Cross icon
function createMedicalAppIconPNG(width, height) {
  // Simple uncompressed/deflated raw RGBA buffer -> PNG generator
  const buffer = Buffer.alloc(width * height * 4);

  const primaryR = 0x04, primaryG = 0x78, primaryB = 0x57; // #047857
  const darkR = 0x0F, darkG = 0x29, darkB = 0x1E;       // #0F291E

  const cx = width / 2;
  const cy = height / 2;
  const radius = width * 0.45;

  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const idx = (y * width + x) * 4;

      // Distance from center
      const dx = x - cx;
      const dy = y - cy;
      const dist = Math.sqrt(dx * dx + dy * dy);

      // Squircle background corner calculation
      const n = 4; // Squircle power
      const squircleDist = Math.pow(Math.abs(dx / (width * 0.46)), n) + Math.pow(Math.abs(dy / (height * 0.46)), n);

      let r = primaryR, g = primaryG, b = primaryB, a = 255;

      if (squircleDist <= 1.0) {
        // Gradient background
        const t = (x + y) / (width + height);
        r = Math.round(primaryR * (1 - t * 0.3));
        g = Math.round(primaryG * (1 - t * 0.3));
        b = Math.round(primaryB * (1 - t * 0.3));

        // Outer white border ring
        if (squircleDist > 0.88) {
          r = 255; g = 255; b = 255;
        }

        // Draw Medical Cross in center
        const crossWidth = width * 0.12;
        const crossHeight = height * 0.36;

        const inVerticalBar = Math.abs(dx) <= crossWidth && Math.abs(dy) <= crossHeight;
        const inHorizontalBar = Math.abs(dy) <= crossWidth && Math.abs(dx) <= crossHeight;

        if (inVerticalBar || inHorizontalBar) {
          r = 255; g = 255; b = 255; // Crisp White Emblem
        }

        // Draw pill accent inside cross center
        if (Math.abs(dx) <= crossWidth * 0.6 && Math.abs(dy) <= crossWidth * 0.6) {
          r = 4; g = 120; b = 87; // Primary emerald pill core
        }
      } else {
        // Transparent outside squircle
        r = 0; g = 0; b = 0; a = 0;
      }

      buffer[idx] = r;
      buffer[idx + 1] = g;
      buffer[idx + 2] = b;
      buffer[idx + 3] = a;
    }
  }

  return encodeRawRGBAToPNG(buffer, width, height);
}

function encodeRawRGBAToPNG(rgbaBuffer, width, height) {
  const signature = Buffer.from([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);

  // IHDR Chunk
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8; // Bit depth
  ihdr[9] = 6; // Color type (RGBA)
  ihdr[10] = 0; // Compression method
  ihdr[11] = 0; // Filter method
  ihdr[12] = 0; // Interlace method
  const ihdrChunk = makeChunk('IHDR', ihdr);

  // IDAT Chunk (Scanlines with 0 filter byte)
  const scanlineLength = width * 4 + 1;
  const rawScanlines = Buffer.alloc(height * scanlineLength);

  for (let y = 0; y < height; y++) {
    const srcStart = y * width * 4;
    const destStart = y * scanlineLength;
    rawScanlines[destStart] = 0; // Filter type None
    rgbaBuffer.copy(rawScanlines, destStart + 1, srcStart, srcStart + width * 4);
  }

  const compressedData = zlib.deflateSync(rawScanlines);
  const idatChunk = makeChunk('IDAT', compressedData);

  // IEND Chunk
  const iendChunk = makeChunk('IEND', Buffer.alloc(0));

  return Buffer.concat([signature, ihdrChunk, idatChunk, iendChunk]);
}

function makeChunk(type, data) {
  const len = data.length;
  const buf = Buffer.alloc(4 + 4 + len + 4);
  buf.writeUInt32BE(len, 0);
  buf.write(type, 4, 4, 'ascii');
  data.copy(buf, 8);

  const crcVal = crc32(buf.slice(4, 4 + 4 + len));
  buf.writeUInt32BE(crcVal, 4 + 4 + len);
  return buf;
}

// Standard CRC32
function crc32(buf) {
  let crc = -1;
  for (let i = 0; i < buf.length; i++) {
    const byte = buf[i];
    for (let j = 0; j < 8; j++) {
      if ((crc ^ (byte >> j)) & 1) {
        crc = (crc >>> 1) ^ 0xEDB88320;
      } else {
        crc = crc >>> 1;
      }
    }
  }
  return (crc ^ -1) >>> 0;
}

// Generate Icons for Mobile & Web
const appIconDir = path.join(__dirname, '../mobile_app/assets/icon');
if (!fs.existsSync(appIconDir)) {
  fs.mkdirSync(appIconDir, { recursive: true });
}

console.log('Generating OshudhSathi Branding App Icons...');

const icon512 = createMedicalAppIconPNG(512, 512);
const icon192 = createMedicalAppIconPNG(192, 192);
const icon96 = createMedicalAppIconPNG(96, 96);
const icon48 = createMedicalAppIconPNG(48, 48);

// Write Assets Icon
fs.writeFileSync(path.join(appIconDir, 'app_icon.png'), icon512);

// Write Web Icons
const webIconDir = path.join(__dirname, '../mobile_app/web/icons');
if (!fs.existsSync(webIconDir)) fs.mkdirSync(webIconDir, { recursive: true });

fs.writeFileSync(path.join(webIconDir, 'Icon-512.png'), icon512);
fs.writeFileSync(path.join(webIconDir, 'Icon-maskable-512.png'), icon512);
fs.writeFileSync(path.join(webIconDir, 'Icon-192.png'), icon192);
fs.writeFileSync(path.join(webIconDir, 'Icon-maskable-192.png'), icon192);
fs.writeFileSync(path.join(__dirname, '../mobile_app/web/favicon.png'), icon48);

// Write Android Launcher Mipmap Icons
const resDir = path.join(__dirname, '../mobile_app/android/app/src/main/res');
if (fs.existsSync(resDir)) {
  const mipmaps = [
    { dir: 'mipmap-xxxhdpi', size: 192, data: icon192 },
    { dir: 'mipmap-xxhdpi', size: 144, data: createMedicalAppIconPNG(144, 144) },
    { dir: 'mipmap-xhdpi', size: 96, data: icon96 },
    { dir: 'mipmap-hdpi', size: 72, data: createMedicalAppIconPNG(72, 72) },
    { dir: 'mipmap-mdpi', size: 48, data: icon48 },
  ];

  for (const m of mipmaps) {
    const targetDir = path.join(resDir, m.dir);
    if (fs.existsSync(targetDir)) {
      fs.writeFileSync(path.join(targetDir, 'ic_launcher.png'), m.data);
    }
  }
}

console.log('App icons generated successfully across Android mipmap, Web icons, and assets/icon/app_icon.png!');
