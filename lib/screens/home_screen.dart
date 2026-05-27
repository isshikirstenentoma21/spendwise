import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../models/expense.dart';
import '../services/export_service.dart';
import '../services/expense_service.dart';
import '../widgets/expense_tile.dart';
import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ExpenseCategory? _selectedCategory;
  bool _budgetWarningShown = false;

  Future<void> _openAddScreen() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
  }

  Future<void> _openEditScreen(Expense expense) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditExpenseScreen(expense: expense)),
    );
  }

  Future<void> _confirmDelete(Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete expense?'),
        content: Text('Remove "${expense.title}" from SpendWise?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ExpenseService.deleteExpense(expense);
    }
  }

  Future<void> _setBudget() async {
    final controller = TextEditingController(
      text: ExpenseService.getMonthlyBudget() == 0
          ? ''
          : ExpenseService.getMonthlyBudget().toStringAsFixed(2),
    );

    final budget = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Monthly Budget'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Budget amount',
            prefixText: 'PHP ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(controller.text.trim());
              Navigator.pop(context, amount);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (budget == null || budget < 0) return;
    await ExpenseService.setMonthlyBudget(budget);
    if (mounted) setState(() => _budgetWarningShown = false);
  }

  Future<void> _export() async {
    try {
      final path = await ExportService.exportCurrentMonth();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Exported to: $path')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $error')));
    }
  }

  void _maybeShowBudgetWarning(double percent, double budget) {
    if (budget <= 0 || percent < 0.8 || _budgetWarningShown) return;
    _budgetWarningShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Budget Alert: You've used ${(percent * 100).toStringAsFixed(0)}% of your monthly budget.",
          ),
          backgroundColor: Colors.orange.shade800,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Expense>>(
      valueListenable: ExpenseService.listenable,
      builder: (context, box, _) {
        final expenses = ExpenseService.getExpensesByCategory(
          _selectedCategory,
        );
        final total = ExpenseService.getTotalExpenses();
        final filteredTotal = ExpenseService.getTotalExpenses(
          category: _selectedCategory,
        );
        final budget = ExpenseService.getMonthlyBudget();
        final percent = budget > 0 ? (total / budget).clamp(0.0, 1.0) : 0.0;

        _maybeShowBudgetWarning(percent, budget);

        return Scaffold(
          appBar: AppBar(
            title: const Text('SpendWise'),
            actions: [
              IconButton(
                tooltip: 'Export current month',
                onPressed: _export,
                icon: const Icon(Icons.file_download_outlined),
              ),
              IconButton(
                tooltip: 'Set budget',
                onPressed: _setBudget,
                icon: const Icon(Icons.savings_outlined),
              ),
            ],
          ),
          body: Column(
            children: [
              _SummaryCard(
                total: total,
                filteredTotal: filteredTotal,
                budget: budget,
                percent: percent,
                isFiltered: _selectedCategory != null,
              ),
              _CategoryFilters(
                selected: _selectedCategory,
                onSelected: (category) =>
                    setState(() => _selectedCategory = category),
              ),
              Expanded(
                child: expenses.isEmpty
                    ? const _EmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        itemBuilder: (context, index) {
                          final expense = expenses[index];
                          return ExpenseTile(
                            expense: expense,
                            onTap: () => _openEditScreen(expense),
                            onDelete: () => _confirmDelete(expense),
                          );
                        },
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemCount: expenses.length,
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openAddScreen,
            icon: const Icon(Icons.add),
            label: const Text('Add Expense'),
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.total,
    required this.filteredTotal,
    required this.budget,
    required this.percent,
    required this.isFiltered,
  });

  final double total;
  final double filteredTotal;
  final double budget;
  final double percent;
  final bool isFiltered;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'PHP ', decimalDigits: 2);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This Month', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(
              currency.format(total),
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (isFiltered) ...[
              const SizedBox(height: 4),
              Text('Filtered total: ${currency.format(filteredTotal)}'),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    budget > 0
                        ? 'Budget: ${currency.format(budget)}'
                        : 'No monthly budget set',
                  ),
                ),
                Text('${(percent * 100).toStringAsFixed(0)}%'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percent,
              minHeight: 12,
              borderRadius: BorderRadius.circular(8),
              color: percent >= 0.8 ? Colors.red : Colors.indigo,
              backgroundColor: Colors.grey.shade200,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({required this.selected, required this.onSelected});

  final ExpenseCategory? selected;
  final ValueChanged<ExpenseCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    final categories = [null, ...ExpenseCategory.values];
    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final category = categories[index];
          final label = category?.label ?? 'All';
          return ChoiceChip(
            label: Text(label),
            selected: selected == category,
            onSelected: (_) => onSelected(category),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemCount: categories.length,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No expenses yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first expense to start tracking your spending.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
