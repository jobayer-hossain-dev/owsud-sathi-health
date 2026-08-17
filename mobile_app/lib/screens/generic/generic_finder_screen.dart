import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/medicine_model.dart';
import '../../data/seeds/offline_medicine_dataset.dart';
import '../../core/constants/api_constants.dart';

class GenericFinderScreen extends ConsumerStatefulWidget {
  const GenericFinderScreen({super.key});

  @override
  ConsumerState<GenericFinderScreen> createState() => _GenericFinderScreenState();
}

class _GenericFinderScreenState extends ConsumerState<GenericFinderScreen> {
  final _searchController = TextEditingController(text: 'Napa');
  bool _isLoading = false;
  MedicineModel? _currentMedicine;
  List<MedicineModel> _alternatives = [];

  final List<String> _quickSearches = ['Napa', 'Seclo', 'Sergel', 'Metformin', 'Bipress'];

  @override
  void initState() {
    super.initState();
    _performSearch('Napa');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isLoading = true);

    // 1. Immediate offline search from bundled dataset
    final offlineMatches = OfflineMedicineDataset.search(query);
    if (offlineMatches.isNotEmpty) {
      final med = offlineMatches.first;
      _currentMedicine = med;
      _alternatives = OfflineMedicineDataset.getAlternatives(med.id);
      _alternatives.sort((a, b) => (a.unitPrice ?? 0).compareTo(b.unitPrice ?? 0));
    } else {
      _currentMedicine = null;
      _alternatives = [];
    }

    // 2. Try background online API fetch if connected
    try {
      final api = ref.read(apiServiceProvider);
      final res = await api.client.get('${ApiConstants.medicines}?q=$query&limit=1');

      if (res.data['success'] == true && (res.data['data'] as List).isNotEmpty) {
        final med = MedicineModel.fromJson(res.data['data'][0]);
        _currentMedicine = med;

        final altRes = await api.client.get('${ApiConstants.medicines}/${med.id}/alternatives');
        if (altRes.data['success'] == true) {
          final list = (altRes.data['data'] as List)
              .map((m) => MedicineModel.fromJson(m))
              .toList();
          list.sort((a, b) => (a.unitPrice ?? 0).compareTo(b.unitPrice ?? 0));
          _alternatives = list;
        }
      }
    } catch (_) {
      // Silently keep offline matches when server is offline
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('💰 সস্তায় একই ওষুধ (Generic Finder)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              const Text(
                'ব্র্যান্ডের ওষুধের নাম দিয়ে সার্চ করুন এবং একই কার্যকারিতার সাশ্রয়ী বিকল্প খুঁজে নিন',
                style: TextStyle(color: AppColors.textLight, fontSize: 13),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _searchController,
                onSubmitted: (val) => _performSearch(val.trim()),
                decoration: InputDecoration(
                  hintText: 'যেমন: Napa, Seclo, Comet, Sergel...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
                    onPressed: () => _performSearch(_searchController.text.trim()),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 32,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _quickSearches.length,
                  itemBuilder: (context, idx) {
                    final item = _quickSearches[idx];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        label: Text(item, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        backgroundColor: AppColors.primary.withOpacity(0.08),
                        onPressed: () {
                          _searchController.text = item;
                          _performSearch(item);
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
              else if (_currentMedicine != null) ...[
                // Main Selected Brand Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary, width: 1.5),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.medication, color: AppColors.primary, size: 32),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_currentMedicine!.brandName} (${_currentMedicine!.strength ?? ''})',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'জেনেরিক: ${_currentMedicine!.genericName}',
                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'MRP ৳${_currentMedicine!.unitPrice ?? 0.0}/পিস  •  ${_currentMedicine!.manufacturer ?? ''}',
                                  style: const TextStyle(color: AppColors.textLight, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (_currentMedicine!.indicationsBn != null || _currentMedicine!.indications != null) ...[
                        const Divider(height: 20),
                        Text(
                          'মূল প্রয়োগ / নির্দেশনা: ${_currentMedicine!.indicationsBn ?? _currentMedicine!.indications}',
                          style: const TextStyle(fontSize: 13, color: AppColors.textDark, fontWeight: FontWeight.w500),
                        ),
                      ],
                      if (_currentMedicine!.compositionBn != null || _currentMedicine!.composition != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'রাসায়নিক সংমিশ্রণ: ${_currentMedicine!.compositionBn ?? _currentMedicine!.composition}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '💡 সাশ্রয়ী জেনেরিক বিকল্প (${_alternatives.length}টি)',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    const Text('সর্বনিম্ন মূল্য প্রথম', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                  ],
                ),
                const SizedBox(height: 12),
                if (_alternatives.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    child: const Text('ডাটাবেজে অন্য ব্র্যান্ড পাওয়া যায়নি', style: TextStyle(color: AppColors.textLight)),
                  )
                else
                  ..._alternatives.map((alt) {
                    final basePrice = _currentMedicine!.unitPrice ?? 1.0;
                    final altPrice = alt.unitPrice ?? basePrice;
                    final diff = basePrice - altPrice;
                    final savingsPercent = basePrice > altPrice
                        ? (((basePrice - altPrice) / basePrice) * 100).toInt()
                        : 0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                        boxShadow: AppColors.softShadow,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${alt.brandName} (${alt.strength ?? ''})',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(alt.manufacturer ?? '', style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
                                  if (alt.indicationsBn != null)
                                    Text(alt.indicationsBn!, style: const TextStyle(fontSize: 11, color: AppColors.textLight), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('৳${alt.unitPrice ?? 0.0}/পিস', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                                const SizedBox(height: 4),
                                if (savingsPercent > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '৳${diff.toStringAsFixed(1)}/পিস সাশ্রয় ($savingsPercent% কম)',
                                      style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'সতর্কতা: যেকোনো ওষুধ পরিবর্তনের পূর্বে নিবন্ধিত চিকিৎসকের সাথে পরামর্শ করুন।',
                          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('\'${_searchController.text}\' নামে কোনো ওষুধ পাওয়া যায়নি', style: const TextStyle(color: AppColors.textLight)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
