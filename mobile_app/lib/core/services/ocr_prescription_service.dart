import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrPrescriptionResult {
  final String? doctorName;
  final String? hospitalName;
  final String? visitDate;
  final String? diagnosisNotes;
  final List<String> detectedMedicines;
  final String fullText;

  OcrPrescriptionResult({
    this.doctorName,
    this.hospitalName,
    this.visitDate,
    this.diagnosisNotes,
    this.detectedMedicines = const [],
    required this.fullText,
  });
}

class OcrPrescriptionService {
  /// Primary API: scan prescription from raw image bytes.
  /// Returns ONLY real data extracted from the image — no hardcoded values.
  static Future<OcrPrescriptionResult> scanFromBytes(Uint8List imageBytes, {String? filePath}) async {
    String rawText = '';

    if (!kIsWeb) {
      if (filePath != null && filePath.isNotEmpty) {
        try {
          final inputImage = InputImage.fromFilePath(filePath);
          final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
          final recognized = await recognizer.processImage(inputImage);
          rawText = recognized.text;
          await recognizer.close();
        } catch (e) {
          debugPrint('MLKit filePath OCR error: $e');
        }
      }
      if (rawText.isEmpty) {
        rawText = await _mobileOcr(imageBytes);
      }
    }

    return _parseRawText(rawText);
  }

  /// Legacy API: scan by file path (works on mobile only).
  static Future<OcrPrescriptionResult> scanPrescriptionImage(String imagePath) async {
    if (kIsWeb) {
      return OcrPrescriptionResult(fullText: '');
    }

    String rawText = '';
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognized = await recognizer.processImage(inputImage);
      rawText = recognized.text;
      await recognizer.close();
    } catch (e) {
      debugPrint('MLKit OCR error: $e');
    }

    return _parseRawText(rawText);
  }

  // ── MOBILE: Google MLKit from bytes ──
  static Future<String> _mobileOcr(Uint8List bytes) async {
    try {
      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: const Size(1080, 1920), // Safe fallback resolution
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: 1080,
        ),
      );
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognized = await recognizer.processImage(inputImage);
      await recognizer.close();
      return recognized.text;
    } catch (e) {
      debugPrint('MLKit bytes OCR error: $e');
      return '';
    }
  }

  // ── TEXT PARSER: Only returns REAL extracted data ──
  static OcrPrescriptionResult _parseRawText(String rawText) {
    if (rawText.trim().isEmpty) {
      return OcrPrescriptionResult(fullText: '');
    }

    String? docName;
    String? hospital;
    String? date;
    String? diagnosis;
    final List<String> medicines = [];

    final lines = rawText.split('\n');

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final lower = trimmed.toLowerCase();

      // 1. Doctor Name
      if (docName == null && _matchAny(lower, [
        'dr.', 'dr ', 'doctor', 'prof.', 'prof ',
        'mbbs', 'fcps', 'md,', 'ms,', 'frcs',
        'surgeon', 'specialist', 'consultant',
        'ডাঃ', 'ডাক্তার', 'অধ্যাপক',
      ])) {
        docName = trimmed;
      }

      // 2. Hospital / Chamber
      if (hospital == null && _matchAny(lower, [
        'hospital', 'clinic', 'medical', 'chamber',
        'diagnostic', 'center', 'centre', 'institute',
        'nursing', 'polyclinic',
        'হাসপাতাল', 'চেম্বার', 'মেডিকেল', 'ডায়াগনস্টিক',
      ])) {
        hospital = trimmed;
      }

      // 3. Date  YYYY-MM-DD  DD/MM/YYYY  DD-MM-YYYY  DD.MM.YYYY
      if (date == null) {
        final m = RegExp(
          r'(\d{4}[-/.]\d{1,2}[-/.]\d{1,2}|\d{1,2}[-/.]\d{1,2}[-/.]\d{2,4})',
        ).firstMatch(trimmed);
        if (m != null) date = m.group(0);
      }

      // 4. Medicines / Rx lines
      if (_matchAny(lower, [
        'rx', 'tab ', 'cap ', 'syr ', 'susp', 'inj ',
        'drop', 'ointment', 'cream', 'gel ',
        '1+0+1', '1+1+1', '1+0+0', '0+0+1', '0+1+0',
      ])) {
        medicines.add(trimmed);
      }

      // 5. Diagnosis
      if (diagnosis == null && _matchAny(lower, [
        'diag', 'problem', 'complaint', 'finding',
        'fever', 'diabetes', 'hypertension', 'asthma',
        'gastric', 'ulcer', 'infection', 'allergy',
        'রোগ', 'সমস্যা', 'জ্বর',
      ])) {
        diagnosis = trimmed;
      }
    }

    return OcrPrescriptionResult(
      doctorName: docName,
      hospitalName: hospital,
      visitDate: date,
      diagnosisNotes: diagnosis,
      detectedMedicines: medicines,
      fullText: rawText,
    );
  }

  static bool _matchAny(String src, List<String> keys) =>
      keys.any((k) => src.contains(k));
}