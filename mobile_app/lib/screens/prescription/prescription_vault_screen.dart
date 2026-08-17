import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/prescription_provider.dart';
import 'add_prescription_screen.dart';

class PrescriptionVaultScreen extends ConsumerStatefulWidget {
  const PrescriptionVaultScreen({super.key});

  @override
  ConsumerState<PrescriptionVaultScreen> createState() => _PrescriptionVaultScreenState();
}

class _PrescriptionVaultScreenState extends ConsumerState<PrescriptionVaultScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(prescriptionProvider.notifier).fetchPrescriptions();
    });
  }

  Widget _buildPrescriptionImage(String imgPath, {BoxFit fit = BoxFit.cover}) {
    if (imgPath.isEmpty) {
      return Container(
        color: AppColors.primary.withOpacity(0.1),
        child: const Icon(Icons.description, color: AppColors.primary, size: 40),
      );
    }
    if (kIsWeb || imgPath.startsWith('http') || imgPath.startsWith('blob:')) {
      return Image.network(
        imgPath,
        fit: fit,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.primary.withOpacity(0.1),
          child: const Icon(Icons.description, color: AppColors.primary, size: 40),
        ),
      );
    }
    try {
      return Image.file(
        File(imgPath),
        fit: fit,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.primary.withOpacity(0.1),
          child: const Icon(Icons.description, color: AppColors.primary, size: 40),
        ),
      );
    } catch (_) {
      return Container(
        color: AppColors.primary.withOpacity(0.1),
        child: const Icon(Icons.description, color: AppColors.primary, size: 40),
      );
    }
  }

  void _viewPrescriptionDetail(dynamic item) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('প্রেসক্রিপশন বিবরণ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              Text('ডাক্তার: ${item.doctorName ?? 'অনুরোধকৃত ডাক্তার'}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              if (item.hospitalName != null) Text('হাসপাতাল: ${item.hospitalName}', style: const TextStyle(color: AppColors.textLight)),
              Text('তারিখ: ${item.visitDate}', style: const TextStyle(color: AppColors.textLight)),
              if (item.diagnosis != null && item.diagnosis!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('রোগের বিবরণ / নোটস:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(item.diagnosis!, style: const TextStyle(color: AppColors.textDark)),
              ],
              const SizedBox(height: 16),
              if (item.images.isNotEmpty) ...[
                const Text('সংযুক্ত ছবিসমূহ:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: item.images.length,
                    itemBuilder: (context, idx) {
                      final imgPath = item.images[idx].imagePath;
                      return InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (dialogCtx) => Dialog.fullscreen(
                              child: Scaffold(
                                backgroundColor: Colors.black,
                                appBar: AppBar(
                                  backgroundColor: Colors.black,
                                  title: const Text('📋 প্রেসক্রিপশন জুম ভিউয়ার', style: TextStyle(color: Colors.white)),
                                  iconTheme: const IconThemeData(color: Colors.white),
                                ),
                                body: Center(
                                  child: InteractiveViewer(
                                    panEnabled: true,
                                    minScale: 0.5,
                                    maxScale: 4.0,
                                    child: _buildPrescriptionImage(imgPath, fit: BoxFit.contain),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          width: 130,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.primary, width: 1.5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildPrescriptionImage(imgPath, fit: BoxFit.cover),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(prescriptionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('📋 ডিজিটাল প্রেসক্রিপশন ভল্ট', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPrescriptionScreen()),
          );
        },
        icon: const Icon(Icons.add_a_photo, color: Colors.white),
        label: const Text('নতুন প্রেসক্রিপশন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.prescriptions.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.primary.withOpacity(0.4)),
                          const SizedBox(height: 16),
                          const Text(
                            'এখনও কোনো প্রেসক্রিপশন আপলোড করা হয়নি',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'আপনার প্রেসক্রিপশনের ছবি তুলে নিরাপদে সংরক্ষণ করুন',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: AppColors.textLight),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.prescriptions.length,
                    itemBuilder: (context, idx) {
                      final item = state.prescriptions[idx];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                          boxShadow: AppColors.softShadow,
                        ),
                        child: InkWell(
                          onTap: () => _viewPrescriptionDetail(item),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.description_outlined, color: AppColors.primary, size: 32),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.doctorName ?? 'ডাক্তার নির্দেশিত প্রেসক্রিপশন',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${item.hospitalName ?? 'চেম্বার'}  •  ${item.visitDate}',
                                        style: const TextStyle(color: AppColors.textLight, fontSize: 13),
                                      ),
                                      if (item.diagnosis != null && item.diagnosis!.isNotEmpty)
                                        Text(
                                          'রোগ: ${item.diagnosis}',
                                          style: const TextStyle(color: AppColors.primaryDark, fontSize: 12, fontWeight: FontWeight.w500),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${item.images.length} টি ছবি',
                                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
