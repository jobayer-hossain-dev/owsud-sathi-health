import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/health_log_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medicine_provider.dart';
import '../../core/services/pdf_service.dart';

class HealthTrackerScreen extends ConsumerStatefulWidget {
  const HealthTrackerScreen({super.key});

  @override
  ConsumerState<HealthTrackerScreen> createState() => _HealthTrackerScreenState();
}

class _HealthTrackerScreenState extends ConsumerState<HealthTrackerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _val1Controller = TextEditingController();
  final _val2Controller = TextEditingController();
  final _notesController = TextEditingController();
  String _mealContext = 'fasting';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadCurrentTab();
      }
    });
    Future.microtask(() => _loadCurrentTab());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _val1Controller.dispose();
    _val2Controller.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadCurrentTab() {
    final types = ['blood_pressure', 'blood_sugar', 'weight', 'pulse'];
    ref.read(healthLogProvider.notifier).fetchLogs(types[_tabController.index]);
  }

  void _exportPdfReport() async {
    final user = ref.read(authProvider).user;
    final healthState = ref.read(healthLogProvider);
    final medState = ref.read(medicineProvider);

    final filePath = await PdfReportService.generateHealthReport(
      userName: user?.name ?? 'রোগী',
      userPhone: user?.phone ?? '',
      bpLogs: healthState.bpLogs,
      sugarLogs: healthState.sugarLogs,
      weightLogs: healthState.weightLogs,
      pulseLogs: healthState.pulseLogs,
      medicines: medState.userMedicines,
    );

    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success),
              SizedBox(width: 8),
              Text('রিপোর্ট ডাউনলোড সম্পন্ন!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('আপনার গত ৩০ দিনের স্বাস্থ্য ও ওষুধ রিপোর্ট ফাইল ড্রাইভে সফলভাবে ডাউনলোড হয়েছে:'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: SelectableText(
                  filePath,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                ),
              ),
              const SizedBox(height: 12),
              const Text('ফাইলটি সরাসরি ডাক্তারকে দেখাতে বা প্রিন্ট করতে পারবেন।', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: filePath));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ফাইল পাথ কপি করা হয়েছে')),
                );
              },
              child: const Text('পাথ কপি করুন'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('বন্ধ করুন', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  void _showSavedReportsModal() async {
    final files = await PdfReportService.getSavedReports();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'সংসংরক্ষিত হেলথ রিপোর্টসমূহ',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(),
                  files.isEmpty
                      ? const Expanded(
                          child: Center(
                            child: Text(
                              'কোনো সংরক্ষিত রিপোর্ট পাওয়া যায়নি',
                              style: TextStyle(color: AppColors.textLight),
                            ),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            controller: controller,
                            itemCount: files.length,
                            itemBuilder: (context, index) {
                              final file = files[index];
                              final name = file.path.split('/').last.split('\\').last;
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  leading: const Icon(Icons.picture_as_pdf, color: AppColors.danger),
                                  title: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                  subtitle: Text(
                                    'তারিখ: ${file.lastModifiedSync().toString().split('.')[0]}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.visibility, color: AppColors.primary),
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          _viewReportContent(file);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.share, color: AppColors.secondary),
                                        onPressed: () {
                                          PdfReportService.shareReportFile(file.path);
                                        },
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
            );
          },
        );
      },
    );
  }

  void _viewReportContent(dynamic file) async {
    final content = await file.readAsString();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('রিপোর্ট ভিউয়ার', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.share, color: AppColors.primary),
              onPressed: () => PdfReportService.shareReportFile(file.path),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                content,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বন্ধ করুন', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    final types = ['blood_pressure', 'blood_sugar', 'weight', 'pulse'];
    final currentType = types[_tabController.index];

    _val1Controller.clear();
    _val2Controller.clear();
    _notesController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                      Text(
                        currentType == 'blood_pressure'
                            ? '🩸 রক্তচাপ রিডিং যোগ করুন'
                            : (currentType == 'blood_sugar'
                                ? '🍬 সুগার লেভেল যোগ করুন'
                                : (currentType == 'weight'
                                    ? '⚖️ নতুন ওজন লিখুন'
                                    : '❤️ পালস রেট (HBR) লিখুন')),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (currentType == 'blood_pressure') ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _val1Controller,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'সিস্টোলিক (Sys)',
                              hintText: '120',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _val2Controller,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'ডায়াস্টোলিক (Dia)',
                              hintText: '80',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    TextField(
                      controller: _val1Controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: currentType == 'blood_sugar'
                            ? 'সুগার লেভেল (mmol/L)'
                            : (currentType == 'weight' ? 'ওজন (kg)' : 'পালস (bpm)'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                  if (currentType == 'blood_sugar') ...[
                    const SizedBox(height: 14),
                    const Text('খাবারের টাইমিং:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('খালি পেটে'),
                          selected: _mealContext == 'fasting',
                          onSelected: (_) => setModalState(() => _mealContext = 'fasting'),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('খাওয়ার পরে'),
                          selected: _mealContext == 'after_meal',
                          onSelected: (_) => setModalState(() => _mealContext = 'after_meal'),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('র্যান্ডম'),
                          selected: _mealContext == 'random',
                          onSelected: (_) => setModalState(() => _mealContext = 'random'),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      final v1 = double.tryParse(_val1Controller.text.trim());
                      final v2 = double.tryParse(_val2Controller.text.trim());

                      if (v1 == null) return;

                      final unit = currentType == 'blood_pressure'
                          ? 'mmHg'
                          : (currentType == 'blood_sugar'
                              ? 'mmol/L'
                              : (currentType == 'weight' ? 'kg' : 'bpm'));

                      final navigator = Navigator.of(ctx);
                      final messenger = ScaffoldMessenger.of(context);

                      final ok = await ref.read(healthLogProvider.notifier).addLog(
                            type: currentType,
                            value1: v1,
                            value2: v2,
                            unit: unit,
                            mealContext: currentType == 'blood_sugar' ? _mealContext : null,
                          );

                      if (ok) {
                        navigator.pop();
                        messenger.showSnackBar(
                          const SnackBar(content: Text('রিডিং সফলভাবে সংরক্ষণ করা হয়েছে')),
                        );
                      }
                    },
                    child: const Text('সেভ করুন', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChart(List logs) {
    if (logs.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Text('এখনও কোনো রিডিং নেওয়া হয়নি', style: TextStyle(color: AppColors.textLight)),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < logs.length; i++) {
      spots.add(FlSpot(i.toDouble(), logs[i].value1));
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.only(right: 20, top: 10, left: 10, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            getDrawingHorizontalLine: (val) => FlLine(color: AppColors.border, strokeWidth: 1),
          ),
          titlesData: const FlTitlesData(
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3.5,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getHealthStatusBadge(String type, double v1, double? v2) {
    String text = 'নরমাল';
    Color color = AppColors.success;

    if (type == 'blood_pressure') {
      if (v1 >= 140 || (v2 != null && v2 >= 90)) {
        text = 'উচ্চ রক্তচাপ (High)';
        color = AppColors.danger;
      } else if (v1 < 90 || (v2 != null && v2 < 60)) {
        text = 'নিম্ন রক্তচাপ (Low)';
        color = AppColors.accent;
      }
    } else if (type == 'blood_sugar') {
      if (v1 >= 7.8) {
        text = 'বেশি (High)';
        color = AppColors.danger;
      } else if (v1 < 4.0) {
        text = 'কম (Low)';
        color = AppColors.accent;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(healthLogProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('📊 স্বাস্থ্য ট্র্যাকার', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_special, color: Colors.white),
            onPressed: _showSavedReportsModal,
            tooltip: 'সংরক্ষিত রিপোর্টসমূহ',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: _exportPdfReport,
            tooltip: 'নতুন PDF রিপোর্ট তৈরি',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'রক্তচাপ'),
            Tab(text: 'সুগার'),
            Tab(text: 'ওজন'),
            Tab(text: 'পালস'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        backgroundColor: AppColors.primary,
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('নতুন রিডিং', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildLogTab('blood_pressure', state.bpLogs, 'mmHg'),
            _buildLogTab('blood_sugar', state.sugarLogs, 'mmol/L'),
            _buildLogTab('weight', state.weightLogs, 'kg'),
            _buildLogTab('pulse', state.pulseLogs, 'bpm'),
          ],
        ),
      ),
    );
  }

  Widget _buildLogTab(String type, List logs, String defaultUnit) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'গত ৩০ দিনের ট্রেন্ড গ্রাফ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              OutlinedButton.icon(
                onPressed: _exportPdfReport,
                icon: const Icon(Icons.download, size: 16),
                label: const Text('PDF রিপোর্ট', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildChart(logs),
          const SizedBox(height: 24),
          const Text(
            'সাম্প্রতিক রিডিং সমূহ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 12),
          if (logs.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              child: const Text('কোনো রিডিং তথ্য নেই', style: TextStyle(color: AppColors.textLight)),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: logs.length,
              itemBuilder: (context, idx) {
                final item = logs[idx];
                final valStr = item.value2 != null
                    ? '${item.value1.toInt()}/${item.value2.toInt()}'
                    : '${item.value1}';
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.monitor_heart, color: AppColors.primary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$valStr ${item.unit ?? defaultUnit}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.recordedAt.split('T')[0],
                              style: const TextStyle(color: AppColors.textLight, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      _getHealthStatusBadge(type, item.value1, item.value2),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
