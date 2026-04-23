class EntryModel {
  final String id;
  final int amount;
  final bool isCredit;
  final DateTime date;
  final String note;
  final String customerName;
  final DateTime createdAt;
  final int syncStatus; // 0 = synced, 1 = pending, 2 = deleted

  EntryModel({
    required this.id,
    required this.amount,
    required this.isCredit,
    required this.date,
    this.note = '',
    this.customerName = '',
    DateTime? createdAt,
    this.syncStatus = 1,
  }) : createdAt = createdAt ?? DateTime.now();

  factory EntryModel.fromMap(Map<String, dynamic> data) {
    return EntryModel(
      id: data['id'] as String? ?? '',
      amount: (data['amount'] as num?)?.toInt() ?? 0,
      isCredit: data['isCredit'] == 1 || data['isCredit'] == true,
      date: data['date'] != null
          ? DateTime.tryParse(data['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      note: data['note'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      syncStatus: data['syncStatus'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'isCredit': isCredit ? 1 : 0,
      'date': date.toIso8601String(),
      'note': note,
      'customerName': customerName,
      'createdAt': createdAt.toIso8601String(),
      'syncStatus': syncStatus,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'isCredit': isCredit,
      'date': date.toIso8601String(),
      'note': note,
      'customerName': customerName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory EntryModel.fromJson(Map<String, dynamic> data) {
    return EntryModel(
      id: data['id'] as String? ?? '',
      amount: (data['amount'] as num?)?.toInt() ?? 0,
      isCredit: data['isCredit'] == true,
      date: data['date'] != null
          ? DateTime.tryParse(data['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      note: data['note'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      syncStatus: 0,
    );
  }

  EntryModel copyWith({
    String? id,
    int? amount,
    bool? isCredit,
    DateTime? date,
    String? note,
    String? customerName,
    int? syncStatus,
  }) {
    return EntryModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      isCredit: isCredit ?? this.isCredit,
      date: date ?? this.date,
      note: note ?? this.note,
      customerName: customerName ?? this.customerName,
      createdAt: createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}

class CustomerSummary {
  final String name;
  final double totalCredit;
  final double totalDebit;
  final int entryCount;

  CustomerSummary({
    required this.name,
    required this.totalCredit,
    required this.totalDebit,
    required this.entryCount,
  });

  double get balance => totalCredit - totalDebit;
}
