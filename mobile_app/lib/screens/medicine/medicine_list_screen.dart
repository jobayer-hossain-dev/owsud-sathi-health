import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/medicine_provider.dart';
import 'add_medicine_screen.dart';

class MedicineListScreen extends ConsumerStatefulWidget {
  const MedicineListScreen({super.key});

  @override
  ConsumerState<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends ConsumerState<MedicineListScreen> {
  String _selectedCategory = 'সব';
  String _searchQuery = '';

  final List<String> _categories = [
    'সব',
    'গ্যাস্ট্রিক',
    'ডায়াবেটিস',
    'প্রেসার',
    'ভিটামিন',
    'অন্যান্য'
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(medicineProvider.notifier).fetchUserMedicines();
    });
  }

  String _getMealInstructionText(String? instruction) {
    if (instruction == 'before_meal') return 'খাওয়ার আগে';
    if (instruction == 'after_meal') return 'খাওয়ার পরে';
    if (instruction == 'with_meal') return 'খাবারের সাথে';
    return 'প্রয়োজনে';
  }

  @override
  Widget build(BuildContext context) {
    final medState = ref.watch(medicineProvider);

    final filteredMedicines = medState.userMedicines.where((med) {
      final nameMatches = med.displayName.toLowerCase().contains(_searchQuery.toLowerCase());
      if (_selectedCategory == 'সব') return nameMatches;
      // Soft matching category keywords
      final lowerName = med.displayName.toLowerCase();
      if (_selectedCategory == 'গ্যাস্ট্রিক') {
        return nameMatches && (lowerName.contains('seclo') || lowerName.contains('pantonic') || lowerName.contains('sergel') || lowerName.contains('omeprazole') || lowerName.contains('esomeprazole') || lowerName.contains('গ্যাস্ট্রিক'));
      }
      if (_selectedCategory == 'ডায়াবেটিস') {
        return nameMatches && (lowerName.contains('metformin') || lowerName.contains('comet') || lowerName.contains('gdm') || lowerName.contains('ডায়াবেটিস'));
      }
      if (_selectedCategory == 'প্রেসার') {
        return nameMatches && (lowerName.contains('bipress') || lowerName.contains('amlodipine') || lowerName.contains('losartan') || lowerName.contains('প্রেসার'));
      }
      if (_selectedCategory == 'ভিটামিন') {
        return nameMatches && (lowerName.contains('d-rise') || lowerName.contains('vitamin') || lowerName.contains('b-50') || lowerName.contains('ভিটামিন'));
      }
      return nameMatches;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('আমার ওষুধের তালিকা', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        backgroundColor: AppColors.primary,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
          );
          if (mounted) {
            ref.read(medicineProvider.notifier).fetchUserMedicines();
          }
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('ওষুধ যোগ করুন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search & Category Filter Section
            Container(
              padding: const EdgeInsets.all(16.0),
              color: AppColors.primary,
              child: Column(
                children: [
                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'আপনার ওষুধের তালিকা খুঁজুন...',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(
                              cat,
                              style: TextStyle(
                                color: isSelected ? AppColors.primary : Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: Colors.white,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            onSelected: (selected) {
                              if (selected) setState(() => _selectedCategory = cat);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Main List Content
            Expanded(
              child: medState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredMedicines.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.medication_liquid_outlined, size: 64, color: AppColors.primary.withOpacity(0.4)),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty || _selectedCategory != 'সব'
                                      ? 'কোনো ওষুধ পাওয়া যায়নি'
                                      : 'এখনও কোনো ওষুধ যোগ করা হয়নি',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'নিচের "+ ওষুধ যোগ করুন" বোতাম চেপে নতুন ওষুধ যুক্ত করুন',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14, color: AppColors.textLight),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredMedicines.length,
                          itemBuilder: (context, idx) {
                            final med = filteredMedicines[idx];
                            final isLowStock = med.remainingQuantity != null &&
                                med.remainingQuantity! <= (med.refillAlertDays * 2);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: AppColors.cardBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isLowStock ? AppColors.accent : AppColors.border,
                                  width: isLowStock ? 1.5 : 1,
                                ),
                                boxShadow: AppColors.softShadow,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(Icons.medication_outlined, color: AppColors.primary, size: 28),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                med.displayName,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textDark,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${med.dosage ?? '১টি'}  •  ${_getMealInstructionText(med.mealInstruction)}',
                                                style: const TextStyle(color: AppColors.textLight, fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            med.frequency == 'once_daily'
                                                ? 'দিনে ১ বার'
                                                : (med.frequency == 'twice_daily'
                                                    ? 'দিনে ২ বার'
                                                    : 'দিনে ৩ বার'),
                                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 24),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.schedule, size: 16, color: AppColors.textLight),
                                            const SizedBox(width: 6),
                                            Text(
                                              'সময়: ${med.times.join(', ')}',
                                              style: const TextStyle(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                        if (med.remainingQuantity != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isLowStock ? AppColors.accent.withOpacity(0.15) : AppColors.success.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'বাকি: ${med.remainingQuantity} টি',
                                              style: TextStyle(
                                                color: isLowStock ? AppColors.accent : AppColors.success,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
