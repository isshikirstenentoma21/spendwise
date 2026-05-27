import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'expense_service.dart';

class ExportService {
  static Future<String> exportCurrentMonth() async {
    final now = DateTime.now();
    final monthLabel = DateFormat('MMMM yyyy').format(now);
    final rowDate = DateFormat('MMM dd, yyyy');
    final fileMonth = DateFormat('yyyy_MM').format(now);

    final monthly =
        ExpenseService.getAllExpenses()
            .where(
              (expense) =>
                  expense.date.year == now.year &&
                  expense.date.month == now.month,
            )
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    final buffer = StringBuffer()
      ..writeln('========================================')
      ..writeln('        SPENDWISE EXPENSE REPORT')
      ..writeln('        $monthLabel')
      ..writeln('========================================')
      ..writeln();

    var total = 0.0;
    for (final expense in monthly) {
      total += expense.amount;
      buffer.writeln(
        '${rowDate.format(expense.date).padRight(14)} '
        '${expense.categoryName.padRight(12)} '
        'PHP ${expense.amount.toStringAsFixed(2).padLeft(9)}   '
        '${expense.title}',
      );
    }

    buffer
      ..writeln()
      ..writeln('----------------------------------------')
      ..writeln('${'TOTAL'.padRight(29)}PHP ${total.toStringAsFixed(2)}')
      ..writeln('========================================')
      ..writeln('Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(now)}');

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/spendwise_$fileMonth.txt');
    await file.writeAsString(buffer.toString());
    return file.path;
  }
}
