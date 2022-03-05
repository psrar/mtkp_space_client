import 'dart:io';
import 'package:path_provider/path_provider.dart' as pp;
import 'package:tuple/tuple.dart';

Future saveLastMessagetStamp(int id, DateTime dateTimeStamp) async {
  final file = await getDocumentsFilePath('lastCheckedMessage.txt');
  await file.writeAsString('$id~$dateTimeStamp');
}

Future<Tuple2<int, DateTime>> getLastMessageStamp() async {
  final file = await getDocumentsFilePath('lastCheckedMessage.txt');
  if (!await file.exists()) {
    return Tuple2(0, DateTime(0));
  }
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
