import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/prescription_provider.dart';
import '../../core/services/ocr_prescription_service.dart';

class AddPrescriptionScreen extends ConsumerStatefulWidget {
  const AddPrescriptionScreen({super.key});

  @override
  ConsumerState<AddPrescriptionScreen> createState() => _AddPrescriptionScreenState();
}

class _AddPrescriptionScreenState extends ConsumerState<AddPrescriptionScreen> {
  final _doctorController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _visitDateController = TextEditingController(
    text: DateTime.now().toIso8601String().split('T')[0],
  );
  final List<XFile> _selectedImages = [];
  final List<Uint8List> _selectedImageBytes = [];
  bool _isOcrScanning = false;

  @override
  void dispose() {
    _doctorController.dispose();
    _hospitalController.dispose();
    _diagnosisController.dispose();
    _visitDateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final img = await picker.pickImage(source: source);
      if (img != null) {
        final bytes = await img.readAsBytes();
        setState(() {
          _selectedImages.add(img);
          _selectedImageBytes.add(bytes);
          _isOcrScanning = true;
        });

        // Execute 100% real OCR scanning from image bytes and file path
        final ocrResult = await OcrPrescriptionService.scanFromBytes(bytes, filePath: img.path);

        if (mounted) {
          bool anyFound = false;
          setState(() {
            _isOcrScanning = false;
            if (ocrResult.doctorName != null && ocrResult.doctorName!.isNotEmpty) {
              _doctorController.text = ocrResult.doctorName!;
              anyFound = true;
            }
            if (ocrResult.hospitalName != null && ocrResult.hospitalName!.isNotEmpty) {
              _hospitalController.text = ocrResult.hospitalName!;
              anyFound = true;
            }
            if (ocrResult.visitDate != null && ocrResult.visitDate!.isNotEmpty) {
              _visitDateController.text = ocrResult.visitDate!;
              anyFound = true;
            }
            if (ocrResult.diagnosisNotes != null && ocrResult.diagnosisNotes!.isNotEmpty) {
              _diagnosisController.text = ocrResult.diagnosisNotes!;
              anyFound = true;
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                anyFound
                    ? '✨ প্রেসক্রিপশন স্ক্যান সম্পন্ন এবং তথ্যগুলো স্বয়ংক্রিয়ভাবে ফিলআপ করা হয়েছে!'
                    : '📸 ছবি যোগ করা হয়েছে! প্রেসক্রিপশনের তথ্য নিজে টাইপ করতে পারেন।',
              ),
              backgroundColor: anyFound ? AppColors.success : AppColors.primary,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isOcrScanning = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ছবি নির্বাচনে ব্যর্থ হয়েছে: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _openFullscreenImageViewer(BuildContext context, Uint8List bytes) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog.fullscreen(
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text('📋 প্রেসক্রিপশন ফুলস্ক্রিন জুম ভিউয়ার', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.memory(bytes, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() async {
    final visitDate = _visitDateController.text.trim();
    if (visitDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ভিজিটের তারিখ দিন')),
      );
      return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final ok = await ref.read(prescriptionProvider.notifier).addPrescription(
          doctorName: _doctorController.text.trim(),
          hospitalName: _hospitalController.text.trim(),
          diagnosis: _diagnosisController.text.trim(),
          visitDate: visitDate,
          imagePaths: _selectedImages.map((e) => e.path).toList(),
        );

    if (ok && mounted) {
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('প্রেসক্রিপশন সফলভাবে সংরক্ষণ করা হয়েছে')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(prescriptionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('নতুন প্রেসক্রিপশন আপলোড', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _doctorController,
                decoration: InputDecoration(
                  labelText: 'ডাক্তারের নাম',
                  hintText: 'যেমন: ডাঃ তৌহিদ হোসাইন',
                  prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _hospitalController,
                decoration: InputDecoration(
                  labelText: 'হাসপাতাল / চেম্বার',
                  hintText: 'যেমন: স্কয়ার হাসপাতাল ও ডায়াগনস্টিক',
                  prefixIcon: const Icon(Icons.local_hospital_outlined, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _visitDateController,
                decoration: InputDecoration(
                  labelText: 'ভিজিটের তারিখ (YYYY-MM-DD)',
                  prefixIcon: const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _diagnosisController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'রোগের নাম / ডাক্তার সাহেবের নোটস',
                  hintText: 'যেমন: গ্যাস্ট্রিক আলসার, উচ্চ রক্তচাপ',
                  prefixIcon: const Icon(Icons.notes, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_isOcrScanning) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    children: [
                      SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 12),
                      Text('🔍 ওসিআর (OCR) দিয়ে প্রেসক্রিপশন রিড করা হচ্ছে...', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
              const Text(
                '📸 প্রেসক্রিপশনের ছবি আপলোড করুন (ছবিতে চাপ দিলে ফুলস্ক্রিন দেখাবে)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt, color: AppColors.primary),
                      label: const Text('ক্যামেরা তুলুন', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library, color: AppColors.primary),
                      label: const Text('গ্যালারি', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_selectedImageBytes.isNotEmpty) ...[
                const Text('সংযুক্ত ছবিসমূহ (ছবিতে চাপ দিয়ে জুম করে দেখুন):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textLight)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImageBytes.length,
                    itemBuilder: (context, idx) {
                      return Stack(
                        children: [
                          InkWell(
                            onTap: () => _openFullscreenImageViewer(context, _selectedImageBytes[idx]),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primary, width: 2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  _selectedImageBytes[idx],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 16,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedImages.removeAt(idx);
                                  _selectedImageBytes.removeAt(idx);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                onPressed: state.isLoading ? null : _submit,
                child: state.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        'সেভ করুন',
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}