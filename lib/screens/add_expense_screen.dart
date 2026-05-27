import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../services/expense_service.dart';
import 'expense_form.dart';

class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key});

  Future<void> _save(BuildContext context, Expense expense) async {
    await ExpenseService.addExpense(expense);
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ExpenseForm(
      title: 'Add Expense',
      submitLabel: 'Save Expense',
      onSubmit: (expense) => _save(context, expense),
    );
  }
}
