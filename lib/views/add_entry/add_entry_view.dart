import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../controllers/add_entry_controller.dart';
import '../../models/entry_model.dart';

class AddEntryView extends StatelessWidget {
  final EntryModel? editEntry;
  final String? presetCustomerName;

   AddEntryView({super.key, this.editEntry, this.presetCustomerName});
   var isDark = false;
  @override
  Widget build(BuildContext context) {
     isDark = Theme.of(context).brightness == Brightness.dark;

    final controller = Get.put(AddEntryController());
    if (editEntry != null) {
      controller.initForEdit(editEntry);
    } else if (presetCustomerName != null) {
      controller.initForCustomer(presetCustomerName!);
    }

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
                  backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primaryMedium,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            controller.isEditing ? 'تعديل القيد' : 'إضافة قيد جديد',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Credit/Debit Toggle
              Container(
                width: double.infinity,
                color: AppColors.primaryMedium,
                padding:
                    const EdgeInsets.only(bottom: 24, left: 16, right: 16),
                child: Obx(() => Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => controller.isCredit.value = true,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: controller.isCredit.value
                                      ? AppColors.success
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_upward_rounded,
                                      color: controller.isCredit.value
                                          ? Colors.white
                                          : Colors.white60,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'لي',
                                      style: TextStyle(
                                        color: controller.isCredit.value
                                            ? Colors.white
                                            : Colors.white60,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => controller.isCredit.value = false,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: !controller.isCredit.value
                                      ? AppColors.error
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_downward_rounded,
                                      color: !controller.isCredit.value
                                          ? Colors.white
                                          : Colors.white60,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'عليا',
                                      style: TextStyle(
                                        color: !controller.isCredit.value
                                            ? Colors.white
                                            : Colors.white60,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Amount
                      _buildLabel('المبلغ *'),
                      const SizedBox(height: 8),
                      Obx(() => TextFormField(
                            controller: controller.amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                                textDirection: ui.TextDirection.ltr,
                                textAlign: ui.TextAlign.left,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                            decoration: InputDecoration(
                              hintText: ' المبلغ',
                              hintStyle:
                                  TextStyle(color: Colors.grey.shade400),
                              suffixIcon: Container(
                                width: 48,
                                alignment: Alignment.center,
                                child: Text(
                                  '\$',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: controller.isCredit.value
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                ),
                              ),
                              filled: true,
                              fillColor: isDark ? AppColors.darkCard : null,
      
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color:isDark?AppColors.darkDivider: Colors.grey.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFF1565C0), width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال المبلغ';
                              }
                              final amount = double.tryParse(value);
                              if (amount == null || amount <= 0) {
                                return 'الرجاء إدخال مبلغ صحيح';
                              }
                              return null;
                            },
                          )),

                      const SizedBox(height: 20),

                      // Customer Name
                      _buildLabel('اسم العميل'),
                      const SizedBox(height: 8),
                      _buildCustomerField(controller),

                      const SizedBox(height: 20),

                      // Date
                      // Date
_buildLabel('التاريخ والوقت *'), // تم تغيير العنوان
const SizedBox(height: 8),
Obx(() => InkWell(
      onTap: () => controller.selectDate(context,isDark),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:isDark?AppColors.darkCard: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color:isDark?AppColors.darkDivider: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                color:  AppColors.primaryLight),
            const SizedBox(width: 12),
            // ✅ تم تعديل التنسيق هنا ليظهر الوقت (hh:mm a)
            Text(
              DateFormat('dd/MM/yyyy - hh:mm a', 'en_US')
                  .format(controller.selectedDate.value),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              controller.getRelativeDate(
                  controller.selectedDate.value),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    )),

                      const SizedBox(height: 20),

                      // Note
                      _buildLabel('الملاحظة'),
                      const SizedBox(height: 8),
                      _buildNoteField(controller),

                      const SizedBox(height: 32),
                      
                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: Obx(() => ElevatedButton(
                              onPressed: controller.isSaving.value
                                  ? null
                                  : () async {
                                      final success =
                                          await controller.saveEntry();
                                      if (success) {
                                        Get.back();
                                        Get.snackbar(
                                          'تم',
                                          controller.isEditing
                                              ? 'تم تحديث القيد'
                                              : 'تم إضافة القيد',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor:
                                              AppColors.success,
                                          colorText: Colors.white,
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: controller.isCredit.value
                                    ? AppColors.success
                                    : AppColors.error,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 2,
                              ),
                              child: controller.isSaving.value
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          controller.isEditing
                                              ? Icons.save_rounded
                                              : Icons.add_rounded,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          controller.isEditing
                                              ? 'حفظ التعديلات'
                                              : 'إضافة القيد',
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        //color: AppColors.primaryLight,
      ),
    );
  }
  Widget _buildCustomerAutocompleteField(AddEntryController controller) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: controller.customerController.text),
      optionsBuilder: (textEditingValue) {
        controller.updateFilteredCustomers(textEditingValue.text);
        return controller.filteredCustomers;
      },
      onSelected: (selection) {
        controller.customerController.text = selection;
      },
      fieldViewBuilder: (context, textController, focusNode, onSubmitted) {
        if (controller.customerController.text.isNotEmpty &&
            textController.text.isEmpty) {
          textController.text = controller.customerController.text;
        }
        textController.addListener(() {
          controller.customerController.text = textController.text;
        });
        return TextFormField(
          controller: textController,
          focusNode: focusNode,
          scrollPadding: const EdgeInsets.only(bottom: 250),
          decoration: InputDecoration(
            hintText: 'أدخل اسم العميل (اختياري)',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: const Icon(Icons.person_rounded,
                color: Color(0xFF1565C0)),
            
            // ✅ إضافة الزر (المثلث) هنا
            suffixIcon: IconButton(
              icon: const Icon(Icons.arrow_drop_down_rounded, 
                  color: Color(0xFF1565C0), size: 30),
              onPressed: () {
                // إذا كانت القائمة مفتوحة (الحقل محدد) قم بإغلاقها، والعكس صحيح
                if (focusNode.hasFocus) {
                  focusNode.unfocus();
                } else {
                  focusNode.requestFocus();
                  focusNode.unfocus();
                  controller.filteredCustomers.assignAll(controller.customerSuggestions);
                  
                  // 2. إعطاء التركيز لفتح قائمة الاقتراحات
                  focusNode.requestFocus();
                  
                  // 3. إخفاء الكيبورد فوراً (ستبقى القائمة مفتوحة)
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                }
              },
            ),
            
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF1565C0), width: 2),
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topRight,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints:
                  const BoxConstraints(maxHeight: 200, maxWidth: 350),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: options.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey.shade100),
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.person, size: 18, color: Colors.grey),
                    title: Text(option, style: const TextStyle(fontSize: 14)),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildCustomerField(AddEntryController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => TextFormField(
              controller: controller.customerController,
              scrollPadding: const EdgeInsets.only(bottom: 250),
              // textAlign: ui.TextAlign.center,
              // textDirection: ui.TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'أدخل اسم العميل (اختياري)',
                
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: const Icon(Icons.person_rounded, color: AppColors.primaryLight),
                suffixIcon: controller.customerSuggestions.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          controller.showCustomerSuggestions.value
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppColors.primaryMedium,
                        ),
                        onPressed: () {
                          // إغلاق الكيبورد عند الفتح اليدوي
                          FocusScope.of(Get.context!).unfocus();
                          controller.showCustomerSuggestions.toggle();
                          if (controller.showCustomerSuggestions.value) {
                            // عرض كل الخيارات عند الضغط على السهم
                            controller.filteredCustomers.assignAll(controller.customerSuggestions);
                          }
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? AppColors.darkCard : null,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:                                    BorderSide(color:isDark?AppColors.darkDivider: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
                ),
              ),
              onChanged: (value) {
                // فلترة القائمة عند الكتابة
                controller.filteredCustomers.assignAll(
                  controller.customerSuggestions.where((s) => s.toLowerCase().contains(value.toLowerCase()))
                );
                // إظهار القائمة فقط إذا كان هناك نص ونتائج
                controller.showCustomerSuggestions.value = controller.filteredCustomers.isNotEmpty;
              },
              onTap: () {
                controller.updateFilteredCustomers(controller.customerController.text);
                controller.showCustomerSuggestions.value = true;
                final textLength = controller.customerController.text.length;
    
    // التحقق مما إذا كان المؤشر يقف قبل الحرف الأخير بحرف واحد
                if (controller.customerController.selection.isCollapsed && 
                    controller.customerController.selection.baseOffset == textLength - 1) {
                      
                  // إجبار المؤشر على الانتقال إلى نهاية النص تماماً
                  controller.customerController.selection = TextSelection.collapsed(offset: textLength);
                }
              },
            )),
        // قائمة الاقتراحات (تظهر وتختفي بناءً على المتغير)
        Obx(() {
          if (controller.showCustomerSuggestions.value) {
            return _buildSuggestionsList(
              controller.filteredCustomers,
              controller.customerController,
              () => controller.showCustomerSuggestions.value = false, // دالة الإغلاق عند الاختيار
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
  Widget _buildNoteField(AddEntryController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => TextFormField(
              controller: controller.noteController,
              scrollPadding: const EdgeInsets.only(bottom: 250),
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'أدخل ملاحظة (اختياري)',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Icon(Icons.note_rounded, color:  AppColors.primaryLight),
                ),
                suffixIcon: controller.noteSuggestions.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: IconButton(
                          icon: Icon(
                            controller.showNoteSuggestions.value
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: AppColors.primaryMedium,
                          ),
                          onPressed: () {
                            FocusScope.of(Get.context!).unfocus();
                            controller.showNoteSuggestions.toggle();
                            if (controller.showNoteSuggestions.value) {
                              controller.filteredNotes.assignAll(controller.noteSuggestions);
                            }
                          },
                        ),
                      )
                    : null,
                filled: true,
                fillColor: isDark ? AppColors.darkCard : Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:                                     BorderSide(color:isDark?AppColors.darkDivider: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
                ),
              ),
              onChanged: (value) {
                controller.filteredNotes.assignAll(
                  controller.noteSuggestions.where((s) => s.toLowerCase().contains(value.toLowerCase()))
                );
                controller.showNoteSuggestions.value =  controller.filteredNotes.isNotEmpty;
              },
              onTap: () {
                controller.updateFilteredNotes(controller.noteController.text);
                controller.showNoteSuggestions.value = true;
              },
            )),
        Obx(() {
          if (controller.showNoteSuggestions.value) {
            return _buildSuggestionsList(
              controller.filteredNotes,
              controller.noteController,
              () => controller.showNoteSuggestions.value = false,
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
  Widget _buildSuggestionsList(
    List<String> filtered,
    TextEditingController textController,
    VoidCallback onClose,
  ) {
    if (filtered.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 180),
      decoration: BoxDecoration(
       color: isDark ? AppColors.darkCard : AppColors.cardBackground,
      
        borderRadius: BorderRadius.circular(12),
        //border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => Divider(height: 1, color:isDark?AppColors.darkDivider: Colors.grey.shade100),
        itemBuilder: (context, index) {
          final suggestion = filtered[index];
          return ListTile(
            dense: true,
            leading: const Icon(Icons.history, size: 18, color: Colors.grey),
            title: Text(
              suggestion,
              style: const TextStyle(fontSize: 14),
            ),
            onTap: () {
              textController.text = suggestion;
              onClose(); // إغلاق القائمة بعد الاختيار
            },
          );
        },
      ),
    );
  }

  Widget _buildCustomerAutocompleteField1(AddEntryController controller) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: controller.customerController.text),
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return controller.customerSuggestions;
        }
        return controller.getFilteredCustomers(textEditingValue.text);
      },
      onSelected: (selection) {
        controller.customerController.text = selection;
      },
      fieldViewBuilder: (context, textController, focusNode, onSubmitted) {
        if (controller.customerController.text.isNotEmpty &&
            textController.text.isEmpty) {
          textController.text = controller.customerController.text;
        }
        textController.addListener(() {
          controller.customerController.text = textController.text;
        });
        return TextFormField(
          controller: textController,
          focusNode: focusNode,
          // الحل هنا: إضافة هامش تمرير لإجبار الشاشة على الارتفاع وترك مساحة للاقتراحات
          scrollPadding: const EdgeInsets.only(bottom: 250), 
          decoration: InputDecoration(
            hintText: 'أدخل اسم العميل (اختياري)',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: const Icon(Icons.person_rounded,
                color: Color(0xFF1565C0)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF1565C0), width: 2),
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topRight,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints:
                  const BoxConstraints(maxHeight: 200, maxWidth: 350),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: options.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey.shade100),
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.person, size: 18, color: Colors.grey),
                    title: Text(option, style: const TextStyle(fontSize: 14)),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildNoteAutocompleteField(AddEntryController controller) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: controller.noteController.text),
      optionsBuilder: (textEditingValue) {
        // if (textEditingValue.text.isEmpty) {
        //   return controller.noteSuggestions;
        // }
        controller.updateFilteredNotes(textEditingValue.text);
        return controller.filteredNotes;
      },
      onSelected: (selection) {
        controller.noteController.text = selection;
      },
      fieldViewBuilder: (context, textController, focusNode, onSubmitted) {
        if (controller.noteController.text.isNotEmpty &&
            textController.text.isEmpty) {
          textController.text = controller.noteController.text;
        }
        textController.addListener(() {
          controller.noteController.text = textController.text;
        });
        return TextFormField(
          controller: textController,
          focusNode: focusNode,
          maxLines: 2,
          scrollPadding: const EdgeInsets.only(bottom: 250),
          decoration: InputDecoration(
            hintText: 'أدخل ملاحظة (اختياري)',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Icon(Icons.note_rounded, color: Color(0xFF1565C0)),
            ),
            
            // ✅ إضافة الزر (المثلث) مع تعديل موضعه للأعلى
            suffixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: IconButton(
                icon: const Icon(Icons.arrow_drop_down_rounded, 
                    color: Color(0xFF1565C0), size: 30),
                onPressed: () {
                  if (focusNode.hasFocus) {
                    focusNode.unfocus();
                  } else {
                    focusNode.requestFocus();
                    controller.updateFilteredNotes("");
                  }
                },
              ),
            ),

            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topRight,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200, maxWidth: 350),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: options.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey.shade100),
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.note_rounded, size: 18, color: Colors.grey),
                    title: Text(option, style: const TextStyle(fontSize: 14)),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoteAutocompleteField2(AddEntryController controller) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: controller.noteController.text),
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return controller.noteSuggestions;
        }
        return controller.getFilteredNotes(textEditingValue.text);
      },
      onSelected: (selection) {
        controller.noteController.text = selection;
      },
      fieldViewBuilder: (context, textController, focusNode, onSubmitted) {
        if (controller.noteController.text.isNotEmpty &&
            textController.text.isEmpty) {
          textController.text = controller.noteController.text;
        }
        textController.addListener(() {
          controller.noteController.text = textController.text;
        });
        return TextFormField(
          controller: textController,
          focusNode: focusNode,
          maxLines: 2,
          // الحل هنا أيضاً: مساحة أمان أسفل الحقل لتجنب تغطية الكيبورد للقائمة
          scrollPadding: const EdgeInsets.only(bottom: 250), 
          decoration: InputDecoration(
            hintText: 'أدخل ملاحظة (اختياري)',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Icon(Icons.note_rounded, color: Color(0xFF1565C0)),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topRight,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200, maxWidth: 350),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: options.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey.shade100),
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.note_rounded, size: 18, color: Colors.grey),
                    title: Text(option, style: const TextStyle(fontSize: 14)),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}