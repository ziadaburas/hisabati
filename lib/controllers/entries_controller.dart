import 'package:get/get.dart';
import '../models/entry_model.dart';
import '../services/database_service.dart';
import 'sync_controller.dart';

class EntriesController extends GetxController {
  final DatabaseService _db = DatabaseService();

  final RxList<EntryModel> entries = <EntryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Computed values
  double get totalCredit =>
      entries.where((e) => e.isCredit).fold(0.0, (sum, e) => sum + e.amount);

  double get totalDebit =>
      entries.where((e) => !e.isCredit).fold(0.0, (sum, e) => sum + e.amount);

  double get totalBalance => totalCredit - totalDebit;

  List<EntryModel> getCustomerEntries(String customerName) {
    return entries.where((e) => e.customerName == customerName).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<MapEntry<String, CustomerSummary>> get customerSummaries {
    final Map<String, CustomerSummary> customers = {};

    for (final entry in entries) {
      if (entry.customerName.isNotEmpty) {
        if (!customers.containsKey(entry.customerName)) {
          customers[entry.customerName] = CustomerSummary(
            name: entry.customerName,
            totalCredit: 0,
            totalDebit: 0,
            entryCount: 0,
          );
        }
        final summary = customers[entry.customerName]!;
        customers[entry.customerName] = CustomerSummary(
          name: entry.customerName,
          totalCredit: summary.totalCredit + (entry.isCredit ? entry.amount : 0),
          totalDebit: summary.totalDebit + (!entry.isCredit ? entry.amount : 0),
          entryCount: summary.entryCount + 1,
        );
      }
    }

    final sorted = customers.entries.toList()
      ..sort((a, b) => b.value.entryCount.compareTo(a.value.entryCount));

    return sorted;
  }

  List<String> get customerNames {
    final Map<String, int> frequency = {};
    for (final e in entries) {
      if (e.customerName.isNotEmpty) {
        frequency[e.customerName] = (frequency[e.customerName] ?? 0) + 1;
      }
    }
    final sorted = frequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => e.key).toList();
  }

  List<String> get notesSuggestions {
    final Map<String, int> frequency = {};
    for (final e in entries) {
      if (e.note.isNotEmpty) {
        frequency[e.note] = (frequency[e.note] ?? 0) + 1;
      }
    }
    final sorted = frequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => e.key).toList();
  }

  Future<void> loadEntries(String userId) async {
    isLoading.value = true;
    try {
      final result = await _db.getEntries(userId);
      entries.assignAll(result);
      error.value = '';
    } catch (e) {
      error.value = e.toString();
    }
    isLoading.value = false;
  }

  Future<bool> addEntry(String userId, EntryModel entry) async {
    try {
      final newEntry = entry.copyWith(
        id: entry.id.isEmpty
            ? DateTime.now().millisecondsSinceEpoch.toString()
            : entry.id,
        syncStatus: 1,
      );
      await _db.insertEntry(userId, newEntry);
      await loadEntries(userId);
      _notifySyncNeeded(userId);
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    }
  }

  Future<bool> updateEntry(String userId, EntryModel entry) async {
    try {
      await _db.updateEntry(userId, entry.copyWith(syncStatus: 1));
      await loadEntries(userId);
      _notifySyncNeeded(userId);
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    }
  }

  Future<bool> deleteEntry(String userId, String entryId) async {
    try {
      await _db.softDeleteEntry(userId, entryId);
      await loadEntries(userId);
      _notifySyncNeeded(userId);
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    }
  }

  void _notifySyncNeeded(String userId) {
    try {
      final syncController = Get.find<SyncController>();
      // تحديث عدد القيود المعلقة - وإذا كان متصلاً سيتم المزامنة تلقائياً
      syncController.checkPendingChanges(userId);
    } catch (_) {}
  }

  void clearEntries() {
    entries.clear();
  }
}
