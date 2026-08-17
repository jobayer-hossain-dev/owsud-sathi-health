import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medicine_provider.dart';
import '../../core/services/notification_service.dart';
import '../medicine/add_medicine_screen.dart';
import '../generic/generic_finder_screen.dart';
import '../family/family_sharing_screen.dart';
import '../appointment/appointment_screen.dart';
import '../health/health_tracker_screen.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(medicineProvider.notifier).fetchUserMedicines();
      ref.read(medicineProvider.notifier).fetchTodayDoseLogs();
    });
  }

  String _getMealInstructionText(String? instruction) {
    if (instruction == 'before_meal') return 'খাওয়ার আগে';
    if (instruction == 'after_meal') return 'খাওয়ার পরে';
    if (instruction == 'with_meal') return 'খাবারের সাথে';
    return 'প্রয়োজনে';
  }

  String _getTimeGroup(String scheduledTime) {
    final timeLower = scheduledTime.toLowerCase();
    if (timeLower.contains('am') || timeLower.contains('সকাল')) {
      final hour = int.tryParse(scheduledTime.split(':')[0]) ?? 8;
      if (hour < 12) return 'সকাল (Morning)';
    }
    if (timeLower.contains('pm') || timeLower.contains('দুপুর') || timeLower.contains('বিকাল')) {
      final hour = int.tryParse(scheduledTime.split(':')[0]) ?? 1;
      if (hour < 5 || hour == 12) return 'দুপুর ও বিকাল (Afternoon)';
      return 'রাত (Night)';
    }
    return 'অন্যান্য সময় (Other)';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final medState = ref.watch(medicineProvider);

    final totalDoses = medState.todayDoseLogs.length;
    final takenDoses = medState.todayDoseLogs.where((d) => d.status == 'taken').length;
    final progress = totalDoses > 0 ? (takenDoses / totalDoses) : 0.0;

    // Group doses by time section
    final Map<String, List<dynamic>> groupedDoses = {};
    for (final log in medState.todayDoseLogs) {
      final group = _getTimeGroup(log.scheduledTime);
      groupedDoses.putIfAbsent(group, () => []).add(log);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'আসসালামু আলাইকুম 👋',
              style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9)),
            ),
            Text(
              user?.name ?? 'ব্যবহারকারী',
              style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_alt_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FamilySharingScreen()),
              );
            },
            tooltip: 'পরিবারের সদস্য',
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GenericFinderScreen()),
              );
            },
            tooltip: 'সস্তায় একই ওষুধ',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(medicineProvider.notifier).fetchUserMedicines();
          await ref.read(medicineProvider.notifier).fetchTodayDoseLogs();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: const [
                              Icon(Icons.pie_chart, color: Colors.white, size: 22),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'আজকের ওষুধ গ্রহণের অগ্রগতি',
                                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$takenDoses/$totalDoses টি সম্পন্ন',
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 12,
                        backgroundColor: Colors.white.withOpacity(0.25),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(progress * 100).toInt()}% সম্পন্ন',
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Flexible(
                          child: Text(
                            progress == 1.0
                                ? '🎉 সব ওষুধ খাওয়া সম্পন্ন!'
                                : 'নিয়মিত সময়মতো ওষুধ খান',
                            textAlign: TextAlign.end,
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Refill Alert Banner
              ...medState.userMedicines.where((m) =>
                  m.remainingQuantity != null && m.remainingQuantity! <= (m.refillAlertDays * 2)).map((m) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.accent.withOpacity(0.6)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'রিফিল অ্যালার্ট: ${m.displayName}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'আর মাত্র ${m.remainingQuantity} টি ট্যাবলেট বাকি আছে! শীঘ্রই সংগ্রহ করুন।',
                              style: const TextStyle(color: AppColors.textLight, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${m.displayName} রিফিল রিকোয়েস্ট তৈরি করা হয়েছে')),
                          );
                        },
                        child: const Text('রিফিল', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              }),

              // Quick Action Grid (4 Cards)
              const Text(
                'দ্রুত সেবা',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  _buildQuickActionCard(
                    title: 'ডাক্তার ভিজিট',
                    subtitle: 'শিডিউল ট্র্যাকার',
                    icon: Icons.calendar_month,
                    color: const Color(0xFF0284C7),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AppointmentScreen()),
                    ),
                  ),
                  _buildQuickActionCard(
                    title: 'সস্তা বিকল্প',
                    subtitle: 'খরচ কমান',
                    icon: Icons.savings_outlined,
                    color: const Color(0xFF059669),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GenericFinderScreen()),
                    ),
                  ),
                  _buildQuickActionCard(
                    title: 'ফ্যামিলি কেয়ার',
                    subtitle: 'স্বজনদের মনিটর',
                    icon: Icons.family_restroom,
                    color: const Color(0xFF7C3AED),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FamilySharingScreen()),
                    ),
                  ),
                  _buildQuickActionCard(
                    title: 'বিপি ও সুগার',
                    subtitle: 'লগ করুন',
                    icon: Icons.monitor_heart_outlined,
                    color: const Color(0xFFDC2626),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HealthTrackerScreen()),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Today's Schedule Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'আজকের ওষুধ সময়সূচী',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
                      );
                    },
                    icon: const Icon(Icons.add, color: Colors.white, size: 16),
                    label: const Text('ওষুধ যোগ', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (medState.todayDoseLogs.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.medication_outlined, size: 48, color: AppColors.primary.withOpacity(0.5)),
                      const SizedBox(height: 12),
                      const Text(
                        'আজকের জন্য কোনো ওষুধ তালিকাভুক্ত নেই',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'নতুন ওষুধ যুক্ত করতে উপরে "+ ওষুধ যোগ" এ চাপুন',
                        style: TextStyle(color: AppColors.textLight, fontSize: 13),
                      ),
                    ],
                  ),
                )
              else
                ...groupedDoses.entries.map((entry) {
                  final groupTitle = entry.key;
                  final logs = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          groupTitle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                      ...logs.map((log) {
                        final isTaken = log.status == 'taken';
                        final isMissed = log.status == 'missed';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isTaken
                                  ? AppColors.success
                                  : (isMissed ? AppColors.danger : AppColors.border),
                              width: isTaken || isMissed ? 1.5 : 1,
                            ),
                            boxShadow: AppColors.softShadow,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isTaken
                                      ? AppColors.success.withOpacity(0.1)
                                      : (isMissed ? AppColors.danger.withOpacity(0.1) : AppColors.primary.withOpacity(0.08)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  log.scheduledTime,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isTaken
                                        ? AppColors.success
                                        : (isMissed ? AppColors.danger : AppColors.primary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      log.displayName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${log.dosage ?? '১টি'}  •  ${_getMealInstructionText(log.mealInstruction)}',
                                      style: const TextStyle(color: AppColors.textLight, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              if (isTaken)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.check, size: 14, color: AppColors.success),
                                      SizedBox(width: 4),
                                      Text('খেয়েছি', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
                                    ],
                                  ),
                                )
                              else if (isMissed)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.danger.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.close, size: 14, color: AppColors.danger),
                                      SizedBox(width: 4),
                                      Text('মিসড', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold, fontSize: 12)),
                                    ],
                                  ),
                                )
                              else
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 32),
                                      onPressed: () {
                                        ref
                                            .read(medicineProvider.notifier)
                                            .markDoseStatus(log.id, 'taken');
                                        NotificationService()
                                            .speakMedicineReminder('${log.displayName} খাওয়া সম্পন্ন হয়েছে');
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.cancel_rounded, color: AppColors.danger, size: 32),
                                      onPressed: () {
                                        ref
                                            .read(medicineProvider.notifier)
                                            .markDoseStatus(log.id, 'missed');
                                      },
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
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
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
