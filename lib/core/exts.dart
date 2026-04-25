import 'package:intl/intl.dart';


extension NumberFormatting on num {
  String get formatAmount {
    final formatter = NumberFormat('#,##0', 'en_US');
    return formatter.format(this);
  }
}