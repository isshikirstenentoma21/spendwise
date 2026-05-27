// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

import 'export_report_builder.dart';

class ExportService {
  static Future<String> exportCurrentMonth() async {
    final report = buildCurrentMonthExpenseReport();
    final bytes = utf8.encode(report.content);
    final blob = html.Blob([bytes], 'text/plain');
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..download = report.fileName
      ..style.display = 'none'
      ..click();

    html.Url.revokeObjectUrl(url);
    return report.fileName;
  }
}
