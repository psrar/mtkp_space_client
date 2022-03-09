import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart' as pp;
import 'package:tuple/tuple.dart';

Future saveLastMessageStamp(int id, DateTime dateTimeStamp) async {
  final file = await getDocumentsFilePath('lastCheckedMessage.txt');
  await file.writeAsString('$id~$dateTimeStamp');
}

Future<Tuple2<int, DateTime>> getLastMessageStamp() async {
  final file = await getDocumentsFilePath('lastCheckedMessage.txt');
  if (!await file.exists()) return Tuple2(0, DateTime(0));

  var logs = await file.readAsLines();
  var stamp = logs.last.split('~');
  return Tuple2(int.parse(stamp[0]), DateTime.parse(stamp[1]));
}

Future clearMessageStamp() async {
  final file = await getDocumentsFilePath('lastCheckedMessage.txt');
  if (await file.exists()) {
    file.delete();
  }
}

Future<File> getDocumentsFilePath(String fileName) async {
  final directory = await pp.getApplicationDocumentsDirectory();
  return File(directory.path + '/$fileName');
}

Future saveJsonToFile(String fileName, Map<String, dynamic> json) async {
  final file = await getDocumentsFilePath(fileName);
  await file.writeAsString(jsonEncode(json));
}

Future<Map<String, dynamic>?> getJsonFromFile(String fileName) async {
  final file = await getDocumentsFilePath(fileName);
  if (!await file.exists()) return null;

  return jsonDecode(await file.readAsString()) as Map<String, dynamic>;
}

Future writeSimpleFile(String fileName, String content) async {
  final file = await getDocumentsFilePath(fileName);
  await file.writeAsString(content);
}

Future<String> readSimpleFile(String fileName) async {
  final file = await getDocumentsFilePath(fileName);
  if (!await file.exists()) return '';

  return await file.readAsString();
}
