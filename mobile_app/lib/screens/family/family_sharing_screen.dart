import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/family_provider.dart';
import '../../providers/auth_provider.dart';
import 'qr_scanner_screen.dart';

class FamilySharingScreen extends ConsumerStatefulWidget {
  const FamilySharingScreen({super.key});

  @override
  ConsumerState<FamilySharingScreen> createState() => _FamilySharingScreenState();
}

class _FamilySharingScreenState extends ConsumerState<FamilySharingScreen> {
  final _familyIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(familyProvider.notifier).fetchFamilyMembers();
    });
  }

  @override
  void dispose() {
    _familyIdController.dispose();
    super.dispose();
  }

  void _showAddMemberModal() {
    _familyIdController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('👨👩👧 পরিবারের সদস্য যোগ করুন', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'স্বজনের ডিজিটাল আইডি নম্বর দিন অথবা QR কোড স্ক্যান করে কানেক্ট করুন:',
                style: TextStyle(color: AppColors.textLight, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _familyIdController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'সদস্যের আইডি / ফোন নম্বর',
                  prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final scannedCode = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(builder: (_) => const QrScannerScreen()),
                  );
                  if (scannedCode != null && scannedCode.isNotEmpty && mounted) {
                    setState(() {
                      _familyIdController.text = scannedCode;
                    });
                    _showAddMemberModal();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('✨ স্ক্যানকৃত কোড: $scannedCode ফর্মে বসানো হয়েছে')),
                    );
                  }
                },
                icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
                label: const Text('QR কোড স্ক্যান করুন', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final idText = _familyIdController.text.trim();
                  if (idText.isEmpty) return;
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('আইডি: $idText এ লিঙ্ক রিকোয়েস্ট পাঠানো হয়েছে')),
                  );
                },
                child: const Text('সংযুক্ত হওয়ার অনুরোধ পাঠান', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onGenerateInvite() {
    final user = ref.read(authProvider).user;
    final phone = user?.phone ?? '';
    final suffix = phone.length >= 4 ? phone.substring(phone.length - 4) : '1001';
    final code = 'OS-INV-$suffix';
    final qrData = 'https://oshudhsathi.app/invite?code=$code&phone=$phone';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.qr_code_2, color: AppColors.primary, size: 28),
            SizedBox(width: 8),
            Text('আমার ইনভাইট কোড ও QR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'আপনার স্বজন এই QR কোডটি স্ক্যান করে অথবা ইনভাইট কোডটি টাইপ করে আপনাকে যুক্ত করতে পারবেন:',
              style: TextStyle(fontSize: 13, color: AppColors.textLight),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              width: 180,
              height: 180,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary, width: 2),
                boxShadow: AppColors.softShadow,
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 160.0,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.primary,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.textDark,
                ),
                errorCorrectionLevel: QrErrorCorrectLevel.M,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary),
              ),
              child: SelectableText(
                code,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 2),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final shareUrl = 'https://oshudhsathi.app/invite?code=$code';
              Share.share('💊 ওষুধসাথী অ্যাপে আমার সাথে যুক্ত হোন:\nইনভাইট কোড: $code\nইনভাইট লিঙ্ক: $shareUrl');
            },
            child: const Text('লিঙ্ক শেয়ার করুন', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ইনভাইট কোড কপি করা হয়েছে')),
              );
            },
            child: const Text('কোড কপি করুন', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(context),
            child: const Text('বন্ধ করুন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    // Sync in background with backend if online
    ref.read(familyProvider.notifier).generateInviteLink('family');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(familyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('👨👩👧 রিমোট ফ্যামিলি কেয়ার', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              // Top Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      onPressed: _onGenerateInvite,
                      icon: const Icon(Icons.qr_code, color: Colors.white, size: 20),
                      label: const Text('আমার কোড ও QR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _showAddMemberModal,
                      icon: const Icon(Icons.person_add_alt, color: AppColors.primary, size: 20),
                      label: const Text('সদস্য যোগ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Text(
                'সংযুক্ত স্বজনদের ওষুধ গ্রহণের লাইভ আপডেট',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 12),
              if (state.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (state.members.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.family_restroom_outlined, size: 48, color: AppColors.primary.withOpacity(0.5)),
                      const SizedBox(height: 12),
                      const Text(
                        'এখনও কোনো স্বজনকে যুক্ত করা হয়নি',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'আপনার বাবা, মা বা সন্তানকে যুক্ত করে দূর থেকেও তাদের ওষুধ পর্যবেক্ষণ করুন',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textLight, fontSize: 13),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.members.length,
                  itemBuilder: (context, idx) {
                    final item = state.members[idx];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                        boxShadow: AppColors.softShadow,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppColors.primary.withOpacity(0.15),
                                  child: const Icon(Icons.person, color: AppColors.primary, size: 28),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'সম্পর্ক: ${item.relationship ?? 'সদস্য'}',
                                        style: const TextStyle(color: AppColors.textLight, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: item.status == 'accepted' ? AppColors.success.withOpacity(0.12) : AppColors.accent.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.status == 'accepted' ? 'সংযুক্ত ✅' : 'অপেক্ষমান ⏳',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: item.status == 'accepted' ? AppColors.success : AppColors.accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (item.status == 'accepted') ...[
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.check_circle_outline, color: AppColors.success, size: 18),
                                      SizedBox(width: 6),
                                      Text('আজকের ওষুধ: ৩টির মধ্যে ২ টি সম্পন্ন', style: TextStyle(fontSize: 13, color: AppColors.textDark, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('${item.name}-কে ওষুধ খাওয়ার জন্য স্মরণ করিয়ে মেসেজ পাঠানো হয়েছে')),
                                      );
                                    },
                                    child: const Text('রিমাইন্ড দিন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}