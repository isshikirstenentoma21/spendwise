import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/expense.dart';

class ExpenseService {
  static const expensesBoxName = 'expenses';
  static const settingsBoxName = 'settings';
  static const monthlyBudgetKey = 'monthly_budget';

  static Box<Expense> get _box => Hive.box<Expense>(expensesBoxName);
  static Box get _settings => Hive.box(settingsBoxName);

  static ValueListenable<Box<Expense>> get listenable => _box.listenable();

  static List<Expense> getAllExpenses() {
    final expenses = _box.values.toList();
    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  static List<Expense> getExpensesByCategory(ExpenseCategory? category) {
    if (category == null) return getAllExpenses();
    return getAllExpenses()
        .where((expense) => expense.category == category)
        .toList();
  }

  static double getTotalExpenses({ExpenseCategory? category}) {
    return getExpensesByCategory(
      category,
    ).fold(0, (sum, expense) => sum + expense.amount);
  }

  static Future<void> addExpense(Expense expense) => _box.add(expense);

  static Future<void> updateExpense(Expense expense) => expense.save();

  static Future<void> deleteExpense(Expense expense) => expense.delete();

  static double getMonthlyBudget() {
    final value = _settings.get(monthlyBudgetKey, defaultValue: 0.0);
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return 0;
  }

  static Future<void> setMonthlyBudget(double budget) {
    return _settings.put(monthlyBudgetKey, budget);
  }
}
