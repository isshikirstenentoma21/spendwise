import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../services/expense_service.dart';
import 'expense_form.dart';

class EditExpenseScreen extends StatelessWidget {
  const EditExpenseScreen({super.key, required this.expense});

  final Expense expense;

  Future<void> _save(BuildContext context, Expense updated) async {
    expense
      ..title = updated.title
      ..amount = updated.amount
      ..category = updated.category
      ..date = updated.date
      ..note = updated.note;
    await ExpenseService.updateExpense(expense);
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ExpenseForm(
      title: 'Edit Expense',
      submitLabel: 'Update Expense',
      initialExpense: expense,
      onSubmit: (updated) => _save(context, updated),
    );
  }
}
