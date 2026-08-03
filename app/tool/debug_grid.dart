import 'dart:io';
import 'package:arth/ingestion/statement/pdf/pdf_loader.dart';

Future<void> main(List<String> args) async {
  final name = args.isEmpty ? 'hdfc_account' : args.first;
  final dir = Directory('../test/golden/statement');
  final pdf = await PdfStatementLoader().loadBytes(
    bytes: File('${dir.path}/$name.pdf').readAsBytesSync(),
  );
  for (final row in pdf.okOrNull!.rows) {
    print(row);
  }
}
