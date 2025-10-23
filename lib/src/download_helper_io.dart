import 'dart:io';

Future<String> saveCsvFile(String filename, String csv) async {
  final tmpDir = Directory.systemTemp.createTempSync('my_web_app_');
  final file = File('${tmpDir.path}${Platform.pathSeparator}$filename');
  await file.writeAsString(csv);
  return file.path;
}
