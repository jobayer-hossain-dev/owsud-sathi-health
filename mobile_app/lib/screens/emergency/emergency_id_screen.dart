import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/svg_assets.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medicine_provider.dart';
import '../../providers/emergency_contacts_provider.dart';
import '../../data/models/emergency_contact_model.dart';
import '../../core/services/contact_picker_service.dart';

class EmergencyIdScreen extends ConsumerStatefulWidget {
  const EmergencyIdScreen({super.key});

  @override
  ConsumerState<EmergencyIdScreen> createState() => _EmergencyIdScreenState();
}

class _EmergencyIdScreenState extends ConsumerState<EmergencyIdScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers for edit profile modal
  final _editNameController = TextEditingController();
  final _editBloodGroupController = TextEditingController();
  final _editEmergencyNameController = TextEditingController();
  final _editEmergencyPhoneController = TextEditingController();
  final _editAllergiesController = TextEditingController();
  final _editChronicController = TextEditingController();

  // Controllers for add/edit contact modal
  final _contactNameController = TextEditingController();
  final _contactRelationController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  final List<Map<String, dynamic>> _officialBdHelplines = [
    {
      'title': 'জাতীয় জরুরি সেবা',
      'subtitle': 'পুলিশ, ফায়ার ও অ্যাম্বুলেন্স',
      'number': '999',
      'svg': SvgAssets.sosSiren,
      'color': const Color(0xFFDC2626),
    },
    {
      'title': 'স্বাস্থ্য বাতায়ন',
      'subtitle': '২৪/৭ ফ্রি ডাক্তারি সেবা',
      'number': '16263',
      'svg': SvgAssets.hospital,
      'color': const Color(0xFF047857),
    },
    {
      'title': 'জাতীয় তথ্য সেবা',
      'subtitle': 'সরকারি জরুরি সেবা',
      'number': '333',
      'svg': SvgAssets.police,
      'color': const Color(0xFF0284C7),
    },
    {
      'title': 'ফায়ার সার্ভিস',
      'subtitle': 'অগ্নি ও উদ্ধার সেবা',
      'number': '16163',
      'svg': SvgAssets.fireService,
      'color': const Color(0xFFD97706),
    },
    {
      'title': 'অ্যাম্বুলেন্স হটলাইন',
      'subtitle': 'জরুরি অ্যাম্বুলেন্স কল',
      'number': '199',
      'svg': SvgAssets.ambulance,
      'color': const Color(0xFFE11D48),
    },
    {
      'title': 'পয়জন কন্ট্রোল центр',
      'subtitle': 'বিষক্রিয়া জরুরি সেবা',
      'number': '01713007700',
      'svg': SvgAssets.poisonControl,
      'color': const Color(0xFF059669),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _editNameController.dispose();
    _editBloodGroupController.dispose();
    _editEmergencyNameController.dispose();
    _editEmergencyPhoneController.dispose();
    _editAllergiesController.dispose();
    _editChronicController.dispose();
    _contactNameController.dispose();
    _contactRelationController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  Future<void> _makeEmergencyCall(BuildContext context, String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    HapticFeedback.heavyImpact();

    final Uri callUri = Uri(scheme: 'tel', path: cleanPhone);
    debugPrint('⚡ Initiating direct dialer call to: $cleanPhone');

    try {
      final bool launched = await launchUrl(
        callUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📞 ডায়ালার খুলতে পারা যায়নি: $cleanPhone'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error launching phone dialer: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📞 ডায়ালার সমস্যা: $cleanPhone'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  /// Open interactive user contact selection menu
  Future<void> _importUserSelectedContacts() async {
    final contacts = await ContactPickerService.showInteractiveContactPicker(context);
    if (contacts.isNotEmpty) {
      final existing = ref.read(emergencyContactsProvider);
      final combined = [...existing, ...contacts];
      await ref.read(emergencyContactsProvider.notifier).setContacts(combined);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${contacts.length}টি পছন্দের জরুরি কন্টাক্ট যুক্ত করা হয়েছে')),
        );
      }
    }
  }

  /// Pick single contact with phone number selection dialog
  Future<void> _pickSingleContact() async {
    final contact = await ContactPickerService.pickSingleContactWithDialog(context);
    if (contact != null) {
      await ref.read(emergencyContactsProvider.notifier).addContact(contact);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${contact.name} (${contact.phone}) জরুরি কন্টাক্ট হিসেবে যুক্ত করা হয়েছে')),
        );
      }
    }
  }

  /// Create or Edit Contact Modal
  void _showAddOrEditContactModal({EmergencyContactModel? existingContact}) {
    if (existingContact != null) {
      _contactNameController.text = existingContact.name;
      _contactRelationController.text = existingContact.relation;
      _contactPhoneController.text = existingContact.phone;
    } else {
      _contactNameController.clear();
      _contactRelationController.clear();
      _contactPhoneController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    existingContact == null ? '➕ জরুরি নম্বর যোগ করুন' : '✏️ কন্টাক্ট সংশোধন',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contactNameController,
                decoration: InputDecoration(
                  labelText: 'স্বজনের নাম',
                  prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contactRelationController,
                decoration: InputDecoration(
                  labelText: 'সম্পর্ক (যেমন: ভাই, অভিভাবক, সন্তান)',
                  prefixIcon: const Icon(Icons.family_restroom, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contactPhoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'ফোন নম্বর',
                  prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final name = _contactNameController.text.trim();
                  final phone = _contactPhoneController.text.trim();
                  if (name.isEmpty || phone.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('নাম ও ফোন নম্বর দিন')),
                    );
                    return;
                  }

                  final nav = Navigator.of(ctx);
                  final messenger = ScaffoldMessenger.of(context);

                  if (existingContact != null) {
                    final updated = existingContact.copyWith(
                      name: name,
                      relation: _contactRelationController.text.trim().isNotEmpty
                          ? _contactRelationController.text.trim()
                          : 'স্বজন',
                      phone: phone,
                    );
                    await ref.read(emergencyContactsProvider.notifier).updateContact(existingContact.id, updated);
                    messenger.showSnackBar(const SnackBar(content: Text('কন্টাক্ট সংশোধন করা হয়েছে')));
                  } else {
                    final newContact = EmergencyContactModel(
                      id: 'contact_${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      relation: _contactRelationController.text.trim().isNotEmpty
                          ? _contactRelationController.text.trim()
                          : 'স্বজন',
                      phone: phone,
                    );
                    await ref.read(emergencyContactsProvider.notifier).addContact(newContact);
                    messenger.showSnackBar(const SnackBar(content: Text('জরুরি যোগাযোগ নম্বর যুক্ত হয়েছে')));
                  }

                  nav.pop();
                },
                child: Text(
                  existingContact == null ? 'সংরক্ষণ করুন' : 'আপডেট করুন',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      );
      },
    );
  }

  void _showEditProfileModal() {
    final user = ref.read(authProvider).user;
    _editNameController.text = user?.name ?? '';
    _editBloodGroupController.text = user?.bloodGroup ?? 'B+';
    _editEmergencyNameController.text = user?.emergencyContactName ?? '';
    _editEmergencyPhoneController.text = user?.emergencyContactPhone ?? '';
    _editAllergiesController.text = user?.allergies ?? '';
    _editChronicController.text = user?.chronicConditions ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgAssets.icon(SvgAssets.medicalBadge, color: AppColors.primary, width: 22, height: 22),
                        const SizedBox(width: 8),
                        const Text(
                          'মেডিকেল ID সম্পাদনা',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _editNameController,
                  decoration: InputDecoration(
                    labelText: 'রোগীর নাম',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _editBloodGroupController,
                  decoration: InputDecoration(
                    labelText: 'রক্তের গ্রুপ (যেমন: B+, O+)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _editEmergencyNameController,
                  decoration: InputDecoration(
                    labelText: 'জরুরি কন্টাক্টের নাম',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _editEmergencyPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'জরুরি কন্টাক্ট ফোন',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _editAllergiesController,
                  decoration: InputDecoration(
                    labelText: 'এলার্জি (যেমন: পেনিসিলিন)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _editChronicController,
                  decoration: InputDecoration(
                    labelText: 'ক্রনিক রোগ (যেমন: ডায়াবেটিস)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final nav = Navigator.of(ctx);
                    final messenger = ScaffoldMessenger.of(context);
                    await ref.read(authProvider.notifier).updateEmergencyInfo(
                          name: _editNameController.text.trim(),
                          bloodGroup: _editBloodGroupController.text.trim(),
                          emergencyContactName: _editEmergencyNameController.text.trim(),
                          emergencyContactPhone: _editEmergencyPhoneController.text.trim(),
                          allergies: _editAllergiesController.text.trim(),
                          chronicConditions: _editChronicController.text.trim(),
                        );
                    nav.pop();
                    messenger.showSnackBar(
                      const SnackBar(content: Text('মেডিকেল ID আপডেট করা হয়েছে')),
                    );
                  },
                  child: const Text('সংরক্ষণ করুন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final userMedicines = ref.watch(medicineProvider).userMedicines;
    final customContacts = ref.watch(emergencyContactsProvider);

    final name = (user?.name != null && user!.name.isNotEmpty) ? user.name : 'তথ্য দেয়া হয়নি';
    final phone = (user?.phone != null && user!.phone.isNotEmpty) ? user.phone : 'ফোন নম্বর যুক্ত হয়নি';
    final bloodGroup = (user?.bloodGroup != null && user!.bloodGroup!.isNotEmpty) ? user.bloodGroup! : 'N/A';
    final emergencyName = (user?.emergencyContactName != null && user!.emergencyContactName!.isNotEmpty)
        ? user.emergencyContactName!
        : 'জরুরি কন্টাক্ট তথ্য নেই';
    final emergencyPhone = (user?.emergencyContactPhone != null && user!.emergencyContactPhone!.isNotEmpty)
        ? user.emergencyContactPhone!
        : '';
    final allergies = (user?.allergies != null && user!.allergies!.isNotEmpty)
        ? user.allergies!
        : 'কোন জানা এলার্জি নেই';
    final chronicConditions = (user?.chronicConditions != null && user!.chronicConditions!.isNotEmpty)
        ? user.chronicConditions!
        : 'কোন ক্রনিক কন্ডিশন নেই';

    final medicalIdNumber = 'MED-880${phone.substring(phone.length > 10 ? phone.length - 10 : 0)}';

    final qrData = 'OSHUDHSATHI EMERGENCY MEDICAL ID\n'
        'ID: $medicalIdNumber\n'
        'Name: $name\n'
        'Blood: $bloodGroup\n'
        'Phone: $phone\n'
        'Emergency Contact: $emergencyName ($emergencyPhone)\n'
        'Allergies: $allergies\n'
        'Chronic: $chronicConditions';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            SvgAssets.icon(SvgAssets.sosSiren, color: Colors.white, width: 22, height: 22),
            const SizedBox(width: 10),
            const Text('জরুরি SOS ও মেডিকেল ID', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
          ],
        ),
        backgroundColor: AppColors.danger,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: '⚡ জরুরি হটলাইন'),
            Tab(text: '📇 মেডিকেল ID কার্ড'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // TAB 1: EMERGENCY HELPLINES & DYNAMIC FAMILY CONTACTS
            LayoutBuilder(
              builder: (context, constraints) {
                final isWideScreen = constraints.maxWidth > 700;
                final horizontalPadding = isWideScreen ? 32.0 : 16.0;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // One-Tap Emergency Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.danger.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: Colors.white24,
                                    shape: BoxShape.circle,
                                  ),
                                  child: SvgAssets.icon(SvgAssets.sosSiren, color: Colors.white, width: 28, height: 28),
                                ),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'জরুরি অবস্থায় এক ক্লিকে কল',
                                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '২৪/৭ দ্রুত অ্যাম্বুলেন্স, পুলিশ ও স্বাস্থ্য সহায়তার সেবা',
                                        style: TextStyle(color: Colors.white70, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.danger,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: () => _makeEmergencyCall(context, '999'),
                                    icon: SvgAssets.icon(SvgAssets.sosSiren, color: AppColors.danger, width: 20, height: 20),
                                    label: const Text('৯৯৯ কল (জরুরি)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white.withOpacity(0.2),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      side: const BorderSide(color: Colors.white54),
                                    ),
                                    onPressed: () => _makeEmergencyCall(context, emergencyPhone),
                                    icon: SvgAssets.icon(SvgAssets.phoneCall, color: Colors.white, width: 18, height: 18),
                                    label: const Text('স্বজনকে কল', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Dynamic Family Contacts Header & Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '👨👩👧 পারিবারিক জরুরি কন্টাক্টস',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                          Wrap(
                            spacing: 4,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary.withOpacity(0.1),
                                  foregroundColor: AppColors.primary,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: _importUserSelectedContacts,
                                icon: const Icon(Icons.contacts, size: 16),
                                label: const Text('ফোনবুক সিলেকশন', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                              IconButton(
                                tooltip: 'ফোনবুক থেকে একটি কন্টাক্ট ও নম্বর বেছে নিন',
                                icon: const Icon(Icons.person_add_alt_1, color: AppColors.primary, size: 22),
                                onPressed: _pickSingleContact,
                              ),
                              IconButton(
                                tooltip: 'নতুন নম্বর ম্যানুয়ালি ইনপুট দিন',
                                icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 24),
                                onPressed: () => _showAddOrEditContactModal(),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Primary Profile Emergency Contact Card
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: SvgAssets.icon(SvgAssets.phoneCall, color: AppColors.primary, width: 22, height: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    emergencyName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
                                  ),
                                  Text(
                                    'প্রধান প্রোফাইল কন্টাক্ট  •  $emergencyPhone',
                                    style: const TextStyle(color: AppColors.textLight, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => _makeEmergencyCall(context, emergencyPhone),
                              icon: const Icon(Icons.call, color: Colors.white, size: 14),
                              label: const Text('কল', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ],
                        ),
                      ),

                      // Dynamic Contacts List with CRUD (Read, Update, Delete, Dial)
                      if (customContacts.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.contact_phone_outlined, size: 36, color: AppColors.textLight),
                              const SizedBox(height: 8),
                              const Text(
                                'কোন অতিরিক্ত পারিবারিক কন্টাক্ট সেভ করা নেই',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'আপনার ফোনবুক থেকে পছন্দমতো নম্বর সিলেক্ট করতে নিচের বাটনে চাপ দিন।',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, color: AppColors.textLight),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: _importUserSelectedContacts,
                                icon: const Icon(Icons.contacts, size: 18, color: Colors.white),
                                label: const Text('ফোনবুক থেকে কন্টাক্ট ও নম্বর বাছুন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        )
                      else
                        ...customContacts.map((contact) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: SvgAssets.icon(SvgAssets.phoneCall, color: Colors.orange.shade800, width: 20, height: 20),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        contact.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
                                      ),
                                      Text(
                                        '${contact.relation}  •  ${contact.phone}',
                                        style: const TextStyle(color: AppColors.textLight, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: AppColors.textLight, size: 20),
                                  onPressed: () => _showAddOrEditContactModal(existingContact: contact),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                                  onPressed: () async {
                                    await ref.read(emergencyContactsProvider.notifier).deleteContact(contact.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('${contact.name} মুছে ফেলা হয়েছে')),
                                      );
                                    }
                                  },
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange.shade800,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () => _makeEmergencyCall(context, contact.phone),
                                  icon: const Icon(Icons.call, color: Colors.white, size: 14),
                                  label: const Text('কল', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                ),
                              ],
                            ),
                          );
                        }),

                      const SizedBox(height: 20),

                      // Official Helplines Responsive Grid
                      const Text(
                        '🇧🇩 বাংলাদেশের অফিশিয়াল হেল্পলাইন',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 12),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: constraints.maxWidth > 700 ? 3 : constraints.maxWidth > 480 ? 2 : 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: constraints.maxWidth > 600 ? 1.4 : 1.15,
                        ),
                        itemCount: _officialBdHelplines.length,
                        itemBuilder: (context, idx) {
                          final item = _officialBdHelplines[idx];
                          final color = item['color'] as Color;
                          return InkWell(
                            onTap: () => _makeEmergencyCall(context, item['number']!),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.cardBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: color.withOpacity(0.3), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: SvgAssets.icon(item['svg']!, color: color, width: 22, height: 22),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          item['number']!,
                                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: color),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title']!,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        item['subtitle']!,
                                        style: const TextStyle(fontSize: 10, color: AppColors.textLight),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.call, color: Colors.white, size: 13),
                                        SizedBox(width: 4),
                                        Text(
                                          'কল দিন',
                                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),

            // TAB 2: DYNAMIC DIGITAL EMERGENCY MEDICAL ID CARD
            LayoutBuilder(
              builder: (context, constraints) {
                final isWideScreen = constraints.maxWidth > 700;
                final horizontalPadding = isWideScreen ? 32.0 : 16.0;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16.0),
                  child: Column(
                    children: [
                      // Action button to Edit Profile Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'ডিজিটাল লাইভ মেডিকেল কার্ড',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                          TextButton.icon(
                            onPressed: _showEditProfileModal,
                            icon: const Icon(Icons.edit, size: 16, color: AppColors.primary),
                            label: const Text('তথ্য সম্পাদনা', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Premium Emergency ID Card Container
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.danger, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.danger.withOpacity(0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card Header Badge
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.danger.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: SvgAssets.icon(SvgAssets.medicalBadge, color: AppColors.danger, width: 28, height: 28),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'EMERGENCY MEDICAL ID',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.danger,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      Text(
                                        'ID: $medicalIdNumber',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textLight),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.danger,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      SvgAssets.icon(SvgAssets.bloodDrop, color: Colors.white, width: 14, height: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        bloodGroup,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const Divider(thickness: 1, height: 28),

                            // Scannable Dynamic QR Code Centerpiece
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: AppColors.danger.withOpacity(0.3), width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: QrImageView(
                                      data: qrData,
                                      version: QrVersions.auto,
                                      size: 140.0,
                                      eyeStyle: const QrEyeStyle(
                                        eyeShape: QrEyeShape.square,
                                        color: AppColors.danger,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'জরুরি পরিস্থিতিতে দ্রুত স্ক্যান করে রোগীর মেডিকেল তথ্য দেখুন',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 11, color: AppColors.textLight, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),

                            const Divider(thickness: 1, height: 28),

                            // Dynamic Patient Data Fields
                            _buildDetailRow('রোগীর নাম:', name, isBold: true),
                            _buildDetailRow('ফোন নম্বর:', phone),
                            _buildDetailRow('রক্তের গ্রুপ:', bloodGroup, isBadge: true),
                            _buildDetailRow('জরুরি কন্টাক্ট:', '$emergencyName ($emergencyPhone)', isBold: true),
                            _buildDetailRow('অ্যালার্জি সতর্কতা:', allergies),
                            _buildDetailRow('দীর্ঘমেয়াদী রোগ:', chronicConditions),

                            const Divider(thickness: 1, height: 24),

                            // Dynamic Medicine Stack
                            const Row(
                              children: [
                                Icon(Icons.medication_liquid_outlined, color: AppColors.primary, size: 20),
                                SizedBox(width: 6),
                                Text(
                                  'বর্তমান সক্রিয় ওষুধসমূহ:',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            if (userMedicines.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('• Metformin 500mg (দিনে ২ বার - খাবারের পর)', style: TextStyle(color: AppColors.textDark, fontSize: 12, fontWeight: FontWeight.w500)),
                                    SizedBox(height: 4),
                                    Text('• Amlodipine 5mg (দিনে ১ বার - সকালে)', style: TextStyle(color: AppColors.textDark, fontSize: 12, fontWeight: FontWeight.w500)),
                                    SizedBox(height: 4),
                                    Text('• Seclo 20mg (দিনে ২ বার - খাবারের আগে)', style: TextStyle(color: AppColors.textDark, fontSize: 12, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              )
                            else
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: userMedicines.map((m) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text('• ${m.displayName} (${m.frequency})', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textDark)),
                                  )).toList(),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, bool isBadge = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textLight)),
          const SizedBox(width: 8),
          Flexible(
            child: isBadge
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      value,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger, fontSize: 13),
                    ),
                  )
                : Text(
                    value,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
