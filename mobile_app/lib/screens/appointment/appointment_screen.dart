import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/appointment_provider.dart';

class AppointmentScreen extends ConsumerStatefulWidget {
  const AppointmentScreen({super.key});

  @override
  ConsumerState<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends ConsumerState<AppointmentScreen> {
  final _doctorController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _dateController = TextEditingController(text: DateTime.now().toIso8601String().split('T')[0]);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(appointmentProvider.notifier).fetchAppointments();
    });
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🩺 নতুন ডাক্তার অ্যাপয়েন্টমেন্ট', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _doctorController,
              decoration: const InputDecoration(labelText: 'ডাক্তারের নাম', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _hospitalController,
              decoration: const InputDecoration(labelText: 'হাসপাতাল/চেম্বার', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'তারিখ (YYYY-MM-DD)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () async {
                final doctor = _doctorController.text.trim();
                if (doctor.isEmpty) return;
                final navigator = Navigator.of(ctx);
                final messenger = ScaffoldMessenger.of(context);
                final ok = await ref.read(appointmentProvider.notifier).addAppointment(
                      doctorName: doctor,
                      hospitalName: _hospitalController.text.trim(),
                      appointmentDate: _dateController.text.trim(),
                    );
                if (ok) {
                  navigator.pop();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('অ্যাপয়েন্টমেন্ট যোগ হয়েছে')),
                  );
                }
              },
              child: const Text('সেভ করুন', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('🩺 ডাক্তার অ্যাপয়েন্টমেন্ট'),
        backgroundColor: AppColors.primary,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        backgroundColor: AppColors.primary,
        onPressed: _showAddDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.appointments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('🩺', style: TextStyle(fontSize: 60)),
                      SizedBox(height: 16),
                      Text('কোনো অ্যাপয়েন্টমেন্ট শিডিউল করা নেই', style: TextStyle(color: AppColors.textLight)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.appointments.length,
                  itemBuilder: (context, idx) {
                    final item = state.appointments[idx];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.secondary,
                          child: Icon(Icons.calendar_month, color: Colors.white),
                        ),
                        title: Text(item.doctorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${item.hospitalName ?? ''}\nতারিখ: ${item.appointmentDate}'),
                      ),
                    );
                  },
                ),
    );
  }
}
