import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/entry_model.dart';
import 'auth_controller.dart';
import 'entries_controller.dart';

class AddEntryController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  final customerController = TextEditingController();

  final RxBool isCredit = true.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxBool isSaving = false.obs;
  final RxBool showCustomerSuggestions = false.obs;
  final RxBool showNoteSuggestions = false.obs;

  EntryModel? editEntry;
  bool get isEditing => editEntry != null;
  // 1. إضافة مصفوفات RxList للمقترحات
  final RxList<String> filteredCustomers = <String>[].obs;
  final RxList<String> filteredNotes = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    
    // إعطاء القيم الأولية للمصفوفات عند فتح الصفحة
    filteredCustomers.assignAll(customerSuggestions);
    filteredNotes.assignAll(noteSuggestions);

    // 2. مراقبة الحقول وتحديث المصفوفات تلقائياً عند الكتابة
    // customerController.addListener(() {
    //   _updateFilteredCustomers(customerController.text);
    // });

    // noteController.addListener(() {
    //   _updateFilteredNotes(noteController.text);
    // });
  }

  // 3. دوال التحديث (يمكنك حذف دوال getFilteredCustomers و getFilteredNotes القديمة)
  void updateFilteredCustomers(String text) {
    if (text.isEmpty) {
      filteredCustomers.assignAll(customerSuggestions);
    } else {
      filteredCustomers.assignAll(
        customerSuggestions.where((s) => s.toLowerCase().contains(text.toLowerCase()))
      );
    }
  }

  void updateFilteredNotes(String text) {
    if (text.isEmpty) {
      filteredNotes.assignAll(noteSuggestions);
    } else {
      filteredNotes.assignAll(
        noteSuggestions.where((s) => s.toLowerCase().contains(text.toLowerCase()))
      );
    }
  }
  void initForEdit(EntryModel? entry) {
    editEntry = entry;
    if (entry != null) {
      amountController.text = entry.amount.toString();
      isCredit.value = entry.isCredit;
      selectedDate.value = entry.date;
      noteController.text = entry.note;
      customerController.text = entry.customerName;
    }
  }

  void initForCustomer(String customerName) {
    customerController.text = customerName;
  }

  List<String> get customerSuggestions =>
      Get.find<EntriesController>().customerNames;

  List<String> get noteSuggestions =>
      Get.find<EntriesController>().notesSuggestions;

  List<String> getFilteredCustomers(String text) {
    if (text.isEmpty) return customerSuggestions;
    return customerSuggestions
        .where((s) => s.toLowerCase().contains(text.toLowerCase()))
        .toList();
  }

  List<String> getFilteredNotes(String text) {
    if (text.isEmpty) return noteSuggestions;
    return noteSuggestions
        .where((s) => s.toLowerCase().contains(text.toLowerCase()))
        .toList();
  }

  Future<void> selectDate(BuildContext context) async {
    // 1. اختيار التاريخ أولاً
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1565C0),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      // 2. إذا تم اختيار التاريخ بنجاح، افتح نافذة اختيار الوقت
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDate.value),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF1565C0),
                onPrimary: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      // 3. دمج التاريخ والوقت معاً
      if (pickedTime != null) {
        selectedDate.value = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }
  }

  Future<bool> saveEntry() async {
    if (!formKey.currentState!.validate()) return false;

    isSaving.value = true;

    final authController = Get.find<AuthController>();
    final entriesController = Get.find<EntriesController>();
    final userId = authController.user.value!.uid;

    final entry = EntryModel(
      id: isEditing ? editEntry!.id : '',
      amount: int.parse(amountController.text),
      isCredit: isCredit.value,
      date: selectedDate.value,
      note: noteController.text.trim(),
      customerName: customerController.text.trim(),
    );

    bool success;
    if (isEditing) {
      success = await entriesController.updateEntry(userId, entry);
    } else {
      success = await entriesController.addEntry(userId, entry);
    }

    isSaving.value = false;
    return success;
  }

  String getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'اليوم';
    if (diff == 1) return 'أمس';
    if (diff == -1) return 'غداً';
    return '';
  }

  @override
  void onClose() {
    amountController.dispose();
    noteController.dispose();
    customerController.dispose();
    super.onClose();
  }
}
