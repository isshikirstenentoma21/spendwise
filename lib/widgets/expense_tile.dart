import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/expense.dart';

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({
    super.key,
    required this.expense,
    required this.onTap,
    required this.onDelete,
  });

  final Expense expense;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'PHP ', decimalDigits: 2);

    return Dismissible(
      key: ValueKey(expense.key),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Card(
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(child: Icon(_categoryIcon(expense.category))),
          title: Text(expense.title),
          subtitle: Text(
            '${expense.categoryName} - ${DateFormat.yMMMd().format(expense.date)}',
          ),
          trailing: Text(
            currency.format(expense.amount),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(ExpenseCategory category) {
    return switch (category) {
      ExpenseCategory.food => Icons.restaurant_outlined,
      ExpenseCategory.transport => Icons.directions_bus_outlined,
      ExpenseCategory.shopping => Icons.shopping_bag_outlined,
      ExpenseCategory.utilities => Icons.receipt_long_outlined,
      ExpenseCategory.school => Icons.school_outlined,
      ExpenseCategory.entertainment => Icons.movie_outlined,
      ExpenseCategory.other => Icons.more_horiz,
    };
  }
}
