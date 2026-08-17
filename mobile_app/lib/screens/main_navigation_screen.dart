import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/constants/app_colors.dart';
import 'home/home_dashboard_screen.dart';
import 'medicine/medicine_list_screen.dart';
import 'health/health_tracker_screen.dart';
import 'prescription/prescription_vault_screen.dart';
import 'emergency/emergency_id_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestAllAppPermissions();
    });
  }

  Future<void> _requestAllAppPermissions() async {
    // Request notification, camera, photos/storage permissions upfront
    try {
      final statuses = await [
        Permission.notification,
        Permission.camera,
        Permission.storage,
        Permission.photos,
      ].request();

      // If notification permission is denied, show friendly dialog explaining why it's needed
      if (statuses[Permission.notification]?.isDenied == true ||
          statuses[Permission.notification]?.isPermanentlyDenied == true) {
        if (mounted) {
          _showPermissionDialog();
        }
      }
    } catch (_) {}
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.notifications_active, color: AppColors.primary),
            SizedBox(width: 8),
            Text('অনুমতি আবশ্যক', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'ওষুধের সঠিক সময়ে অ্যালার্ম ও ভয়েস নোটিফিকেশন পেতে অ্যাপের নোটিফিকেশন এবং প্রয়োজনীয় অনুমতি চালু রাখা জরুরি।',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('পরে করব', style: TextStyle(color: AppColors.textLight)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('সেটিংসে যান', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  final List<Widget> _screens = const [
    HomeDashboardScreen(),
    MedicineListScreen(),
    HealthTrackerScreen(),
    PrescriptionVaultScreen(),
    EmergencyIdScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'হোম'),
          BottomNavigationBarItem(icon: Icon(Icons.medication), label: 'ওষুধ'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'স্বাস্থ্য'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'প্রেসক্রিপশন'),
          BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: 'জরুরি ID'),
        ],
      ),
    );
  }
}
