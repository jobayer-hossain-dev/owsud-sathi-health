import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/emergency_contact_model.dart';
import '../constants/app_colors.dart';

class ContactPickerService {
  /// Request contact permissions cleanly
  static Future<bool> requestPermission() async {
    try {
      final status = await Permission.contacts.request();
      if (status.isGranted) return true;
      return await FlutterContacts.requestPermission();
    } catch (e) {
      debugPrint('Error requesting contact permission: $e');
      return false;
    }
  }

  /// Open an interactive modal selection dialog giving user 100% control over contact & number selection
  static Future<List<EmergencyContactModel>> showInteractiveContactPicker(
      BuildContext context) async {
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('কন্টাক্ট অ্যাক্সেস অনুমোদন দেওয়া হয়নি')),
        );
      }
      return [];
    }

    try {
      final allContacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      final validContacts =
          allContacts.where((c) => c.phones.isNotEmpty).toList();

      if (validContacts.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ফোনবুকে কোনো নম্বর পাওয়া যায়নি')),
          );
        }
        return [];
      }

      if (!context.mounted) return [];

      final List<EmergencyContactModel>? selected =
          await showModalBottomSheet<List<EmergencyContactModel>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (ctx) => _InteractiveContactPickerSheet(contacts: validContacts),
      );

      return selected ?? [];
    } catch (e) {
      debugPrint('Error in showInteractiveContactPicker: $e');
      return [];
    }
  }

  /// Single contact picker with explicit number selection dialog if multiple numbers exist
  static Future<EmergencyContactModel?> pickSingleContactWithDialog(
      BuildContext context) async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return null;

    try {
      final contact = await FlutterContacts.openExternalPick();
      if (contact == null || contact.phones.isEmpty) return null;

      final fullContact = await FlutterContacts.getContact(contact.id);
      final phones = (fullContact != null && fullContact.phones.isNotEmpty)
          ? fullContact.phones
          : contact.phones;

      String chosenPhone = phones.first.number;

      if (phones.length > 1 && context.mounted) {
        final selectedPhone = await showDialog<String>(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            title: Text('${contact.displayName}-এর নম্বর নির্বাচন করুন'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: phones.map((p) {
                final clean = p.number.replaceAll(RegExp(r'[^0-9+]'), '');
                final label = p.label.name.isNotEmpty ? p.label.name : 'ফোন';
                return ListTile(
                  title: Text(clean, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(label),
                  leading: const Icon(Icons.phone, color: AppColors.primary),
                  onTap: () => Navigator.pop(dialogCtx, clean),
                );
              }).toList(),
            ),
          ),
        );
        if (selectedPhone != null && selectedPhone.isNotEmpty) {
          chosenPhone = selectedPhone;
        }
      }

      final cleanPhone = chosenPhone.replaceAll(RegExp(r'[^0-9+]'), '');
      return EmergencyContactModel(
        id: 'contact_${DateTime.now().millisecondsSinceEpoch}_${contact.id}',
        name: contact.displayName.isNotEmpty ? contact.displayName : 'স্বজন',
        phone: cleanPhone,
        relation: 'পারিবারিক স্বজন',
        isAutoImported: false,
      );
    } catch (e) {
      debugPrint('Error picking single contact: $e');
      return null;
    }
  }
}

class _InteractiveContactPickerSheet extends StatefulWidget {
  final List<Contact> contacts;
  const _InteractiveContactPickerSheet({required this.contacts});

  @override
  State<_InteractiveContactPickerSheet> createState() =>
      __InteractiveContactPickerSheetState();
}

class __InteractiveContactPickerSheetState
    extends State<_InteractiveContactPickerSheet> {
  final Map<String, String> _selectedPhoneNumbers = {}; // contactId -> selectedPhone
  final Set<String> _selectedContactIds = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Default pre-select top 4 for user convenience while giving full choice
    for (int i = 0; i < widget.contacts.length && i < 4; i++) {
      final c = widget.contacts[i];
      _selectedContactIds.add(c.id);
      _selectedPhoneNumbers[c.id] =
          c.phones.first.number.replaceAll(RegExp(r'[^0-9+]'), '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.contacts.where((c) {
      final query = _searchQuery.toLowerCase();
      final nameMatches = c.displayName.toLowerCase().contains(query);
      final phoneMatches = c.phones.any((p) => p.number.contains(query));
      return nameMatches || phoneMatches;
    }).toList();

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final availableHeight = MediaQuery.of(context).size.height * 0.85 - bottomInset;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: availableHeight > 300 ? availableHeight : 300,
        child: Padding(
          padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 16),
          child: Column(
            children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'জরুরি কন্টাক্ট নির্বাচন করুন',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    'পারিবারিক কন্টাক্ট হিসেবে যুক্ত করতে টিক দিন (${_selectedContactIds.length} টি সিলেক্টেড)',
                    style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context, <EmergencyContactModel>[]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'নাম বা নম্বর দিয়ে খুঁজুন...',
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, idx) {
                final c = filtered[idx];
                final isSelected = _selectedContactIds.contains(c.id);
                final phones = c.phones;
                final currentPhone = _selectedPhoneNumbers[c.id] ??
                    (phones.isNotEmpty
                        ? phones.first.number.replaceAll(RegExp(r'[^0-9+]'), '')
                        : '');

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.06)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: CheckboxListTile(
                    activeColor: AppColors.primary,
                    value: isSelected,
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _selectedContactIds.add(c.id);
                          _selectedPhoneNumbers[c.id] = currentPhone;
                        } else {
                          _selectedContactIds.remove(c.id);
                          _selectedPhoneNumbers.remove(c.id);
                        }
                      });
                    },
                    title: Text(
                      c.displayName.isNotEmpty ? c.displayName : 'স্বজন',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textDark,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(currentPhone,
                            style: const TextStyle(fontSize: 13, color: AppColors.textLight)),
                        if (isSelected && phones.length > 1) ...[
                          const SizedBox(height: 4),
                          PopupMenuButton<String>(
                            onSelected: (selectedNumber) {
                              setState(() {
                                _selectedPhoneNumbers[c.id] = selectedNumber;
                              });
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'অন্য নম্বর সিলেক্ট করুন ',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down,
                                    size: 16, color: AppColors.primary),
                              ],
                            ),
                            itemBuilder: (context) => phones.map((p) {
                              final clean =
                                  p.number.replaceAll(RegExp(r'[^0-9+]'), '');
                              return PopupMenuItem(
                                value: clean,
                                child: Text(clean),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final result = <EmergencyContactModel>[];
              for (final c in widget.contacts) {
                if (_selectedContactIds.contains(c.id)) {
                  final phone = _selectedPhoneNumbers[c.id] ??
                      c.phones.first.number
                          .replaceAll(RegExp(r'[^0-9+]'), '');
                  result.add(
                    EmergencyContactModel(
                      id: 'contact_${DateTime.now().millisecondsSinceEpoch}_${c.id}',
                      name: c.displayName.isNotEmpty
                          ? c.displayName
                          : 'স্বজন',
                      phone: phone,
                      relation: 'পারিবারিক স্বজন',
                      isAutoImported: false,
                    ),
                  );
                }
              }
              Navigator.pop(context, result);
            },
            child: Text(
              'নির্বাচন সম্পন্ন করুন (${_selectedContactIds.length} টি)',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);
  }
}
