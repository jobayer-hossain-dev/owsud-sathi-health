import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/emergency_contact_model.dart';
import '../core/services/storage_service.dart';

final emergencyContactsProvider = StateNotifierProvider<
    EmergencyContactsNotifier, List<EmergencyContactModel>>((ref) {
  return EmergencyContactsNotifier();
});

class EmergencyContactsNotifier
    extends StateNotifier<List<EmergencyContactModel>> {
  EmergencyContactsNotifier() : super([]) {
    loadContacts();
  }

  Future<void> loadContacts() async {
    final rawList = await StorageService.getEmergencyContacts();
    final contacts =
        rawList.map((map) => EmergencyContactModel.fromJson(map)).toList();
    state = contacts;
  }

  Future<void> addContact(EmergencyContactModel contact) async {
    final updated = [...state, contact];
    await _persist(updated);
  }

  Future<void> updateContact(String id, EmergencyContactModel updated) async {
    final list = state.map((c) => c.id == id ? updated : c).toList();
    await _persist(list);
  }

  Future<void> deleteContact(String id) async {
    final list = state.where((c) => c.id != id).toList();
    await _persist(list);
  }

  Future<void> setContacts(List<EmergencyContactModel> contacts) async {
    await _persist(contacts);
  }

  Future<void> _persist(List<EmergencyContactModel> list) async {
    state = list;
    final serialized = list.map((e) => e.toJson()).toList();
    await StorageService.saveEmergencyContacts(serialized);
  }
}
