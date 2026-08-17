import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/medicine_provider.dart';
import '../../data/models/medicine_model.dart';

class AddMedicineScreen extends ConsumerStatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  ConsumerState<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends ConsumerState<AddMedicineScreen> {
  final _searchController = TextEditingController();
  final _customNameController = TextEditingController();
  final _dosageController = TextEditingController(text: '১টা');
  final _totalQuantityController = TextEditingController(text: '৩০');
  final _refillDaysController = TextEditingController(text: '৩');

  MedicineModel? _selectedMedicine;
  bool _isCustom = false;
  bool _enableVoiceReminder = true;
  String _selectedForm = 'ট্যাবলেট';

  final List<String> _dosageForms = [
    'ট্যাবলেট',
    'ক্যাপসুল',
    'সিরাপ',
    'ইনজেকশন',
    'ড্রপস',
    'মলম'
  ];

  String _frequency = 'twice_daily'; // once_daily, twice_daily, thrice_daily
  String _mealInstruction = 'after_meal'; // before_meal, after_meal, any
  List<TimeOfDay> _selectedTimes = [
    const TimeOfDay(hour: 8, minute: 0),
    const TimeOfDay(hour: 22, minute: 0),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _customNameController.dispose();
    _dosageController.dispose();
    _totalQuantityController.dispose();
    _refillDaysController.dispose();
    super.dispose();
  }

  void _onFrequencyChanged(String freq) {
    setState(() {
      _frequency = freq;
      if (freq == 'once_daily') {
        _selectedTimes = [const TimeOfDay(hour: 8, minute: 0)];
      } else if (freq == 'twice_daily') {
        _selectedTimes = [
          const TimeOfDay(hour: 8, minute: 0),
          const TimeOfDay(hour: 22, minute: 0),
        ];
      } else if (freq == 'thrice_daily') {
        _selectedTimes = [
          const TimeOfDay(hour: 8, minute: 0),
          const TimeOfDay(hour: 14, minute: 0),
          const TimeOfDay(hour: 22, minute: 0),
        ];
      }
    });
  }

  Future<void> _pickTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTimes[index],
    );
    if (picked != null) {
      setState(() {
        _selectedTimes[index] = picked;
      });
    }
  }

  void _submit() async {
    final name = _isCustom ? _customNameController.text.trim() : null;
    if (!_isCustom && _selectedMedicine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ওষুধের নাম নির্বাচন করুন')),
      );
      return;
    }
    if (_isCustom && (name == null || name.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ওষুধের নাম লিখুন')),
      );
      return;
    }

    final formattedTimes = _selectedTimes.map((t) {
      final hourStr = t.hour.toString().padLeft(2, '0');
      final minStr = t.minute.toString().padLeft(2, '0');
      return '$hourStr:$minStr';
    }).toList();

    final dosageText = '${_dosageController.text.trim()} $_selectedForm';

    final data = {
      if (!_isCustom && _selectedMedicine != null) ...{
        'medicine_id': _selectedMedicine!.id,
        'brand_name': '${_selectedMedicine!.brandName} ${_selectedMedicine!.strength ?? ''}'.trim(),
        'generic_name': _selectedMedicine!.genericName,
      },
      if (_isCustom) 'custom_name': name,
      'dosage': dosageText,
      'frequency': _frequency,
      'times': formattedTimes,
      'meal_instruction': _mealInstruction,
      'start_date': DateTime.now().toIso8601String().split('T')[0],
      'total_quantity': int.tryParse(_totalQuantityController.text.trim()) ?? 30,
      'refill_alert_days': int.tryParse(_refillDaysController.text.trim()) ?? 3,
      'voice_reminder': _enableVoiceReminder,
    };

    final ok = await ref.read(medicineProvider.notifier).addUserMedicine(data);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ওষুধ সফলভাবে যোগ করা হয়েছে')),
      );
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final medState = ref.watch(medicineProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('নতুন ওষুধ যোগ করুন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search / Custom Selector Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isCustom ? 'নিজে ওষুধের নাম লিখুন' : '🔍 DGDA ওষুধ খুঁজুন',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  TextButton.icon(
                    onPressed: () => setState(() => _isCustom = !_isCustom),
                    icon: Icon(_isCustom ? Icons.search : Icons.edit, size: 16),
                    label: Text(_isCustom ? 'খুঁজুন' : 'নিজে লিখুন', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (!_isCustom) ...[
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    ref.read(medicineProvider.notifier).searchMedicines(val);
                  },
                  decoration: InputDecoration(
                    hintText: 'যেমন: Napa, Metformin, Seclo, Sergel...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),
                if (medState.searchResults.isNotEmpty)
                  Container(
                    height: 200,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppColors.softShadow,
                    ),
                    child: ListView.builder(
                      itemCount: medState.searchResults.length,
                      itemBuilder: (context, idx) {
                        final item = medState.searchResults[idx];
                        return ListTile(
                          leading: const Icon(Icons.medication, color: AppColors.primary),
                          title: Text('${item.brandName} (${item.strength ?? ''})', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${item.genericName} • ${item.manufacturer}'),
                          onTap: () {
                            setState(() {
                              _selectedMedicine = item;
                              _searchController.text = '${item.brandName} (${item.strength ?? ''})';
                            });
                            ref.read(medicineProvider.notifier).searchMedicines('');
                          },
                        );
                      },
                    ),
                  ),
              ] else ...[
                TextField(
                  controller: _customNameController,
                  decoration: InputDecoration(
                    labelText: 'ওষুধের নাম লিখুন',
                    hintText: 'যেমন: গ্যাস্ট্রিকের ওষুধ',
                    prefixIcon: const Icon(Icons.medication, color: AppColors.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),
              const Text('ওষুধের ধরন (Form)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _dosageForms.map((form) {
                  final isSelected = _selectedForm == form;
                  return ChoiceChip(
                    label: Text(form),
                    selected: isSelected,
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textDark,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedForm = form);
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              TextField(
                controller: _dosageController,
                decoration: InputDecoration(
                  labelText: 'পরিমাণ / মাত্রা',
                  hintText: 'যেমন: ১',
                  prefixIcon: const Icon(Icons.numbers, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text('কতবার খাবেন?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('দিনে ১ বার'),
                      selected: _frequency == 'once_daily',
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: _frequency == 'once_daily' ? AppColors.primary : AppColors.textDark,
                        fontWeight: _frequency == 'once_daily' ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) => _onFrequencyChanged('once_daily'),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('দিনে ২ বার'),
                      selected: _frequency == 'twice_daily',
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: _frequency == 'twice_daily' ? AppColors.primary : AppColors.textDark,
                        fontWeight: _frequency == 'twice_daily' ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) => _onFrequencyChanged('twice_daily'),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('দিনে ৩ বার'),
                      selected: _frequency == 'thrice_daily',
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: _frequency == 'thrice_daily' ? AppColors.primary : AppColors.textDark,
                        fontWeight: _frequency == 'thrice_daily' ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) => _onFrequencyChanged('thrice_daily'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Text('গ্রহণের সময় নির্ধারণ করুন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(_selectedTimes.length, (idx) {
                  final t = _selectedTimes[idx];
                  final timeStr = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                  return ActionChip(
                    avatar: const Icon(Icons.access_time, size: 18, color: AppColors.primary),
                    label: Text('সময় ${idx + 1}: $timeStr', style: const TextStyle(fontWeight: FontWeight.bold)),
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    onPressed: () => _pickTime(idx),
                  );
                }),
              ),

              const SizedBox(height: 20),
              const Text('খাবারের নিয়ম', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
              const SizedBox(height: 8),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('খাওয়ার আগে'),
                    selected: _mealInstruction == 'before_meal',
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    onSelected: (_) => setState(() => _mealInstruction = 'before_meal'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('খাওয়ার পরে'),
                    selected: _mealInstruction == 'after_meal',
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    onSelected: (_) => setState(() => _mealInstruction = 'after_meal'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('যেকোনো সময়'),
                    selected: _mealInstruction == 'any',
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    onSelected: (_) => setState(() => _mealInstruction = 'any'),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _totalQuantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'মোট কেনা পরিমাণ',
                        hintText: '৩০',
                        prefixIcon: const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _refillDaysController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'রিফিল নোটিফিকেশন দিন',
                        hintText: '৩',
                        prefixIcon: const Icon(Icons.notification_important_outlined, color: AppColors.primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.record_voice_over, color: AppColors.primary),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'বাংলা ভয়েস অনুস্মারক',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _enableVoiceReminder,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) => setState(() => _enableVoiceReminder = val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                onPressed: medState.isLoading ? null : _submit,
                child: medState.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        '💊 ওষুধ যোগ করুন',
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
