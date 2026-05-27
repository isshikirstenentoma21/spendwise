import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 0)
enum ExpenseCategory {
  @HiveField(0)
  food,
  @HiveField(1)
  transport,
  @HiveField(2)
  shopping,
  @HiveField(3)
  utilities,
  @HiveField(4)
  school,
  @HiveField(5)
  other,
  @HiveField(6)
  entertainment
}

extension ExpenseCategoryLabel on ExpenseCategory {
  String get label {
    return switch (this) {
      ExpenseCategory.food => 'Food',
      ExpenseCategory.transport => 'Transport',
      ExpenseCategory.shopping => 'Shopping',
      ExpenseCategory.utilities => 'Utilities',
      ExpenseCategory.school => 'School',
      ExpenseCategory.entertainment => 'Entertainment',
      ExpenseCategory.other => 'Other',
    };
  }
}

@HiveType(typeId: 1)
class Expense extends HiveObject {
  Expense({
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note = '',
  });

  @HiveField(0)
  String title;

  @HiveField(1)
  double amount;

  @HiveField(2)
  ExpenseCategory category;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String note;

  String get categoryName => category.label;
}
