import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'export_report_builder.dart';

class ExportService {
  static Future<String> exportCurrentMonth() async {
    final report = buildCurrentMonthExpenseReport();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${report.fileName}');
    await file.writeAsString(report.content);
    return file.path;
  }
}
