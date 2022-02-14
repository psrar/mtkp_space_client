import 'dart:io';
import 'package:path_provider/path_provider.dart' as pp;
import 'package:tuple/tuple.dart';

Future saveLastReplacementStamp(int fileID, DateTime dateTimeStamp) async {
  final file = await getDocumentsFilePath('lastCheckedReplacements.txt');
  if (!await file.exists()) {
    file.writeAsString('$fileID~$dateTimeStamp\n');
  } else {
    var logs = await file.readAsLines();
    if (logs.length > 2) {
      logs = logs.sublist(1, 3);
    }
    logs.add('$fileID~$dateTimeStamp\n');
    await file.writeAsString(logs.join('\n'), mode: FileMode.write);
  }
}

Future<Tuple2<int, DateTime>> getLastReplacementStamp() async {
  final file = await getDocumentsFilePath('lastCheckedReplacements.txt');
  if (!await file.exists()) {
    return Tuple2(0, DateTime(0));
  }
  var logs = await file.readAsLines();
  var stamp = logs.last.split('~');
  return Tuple2(int.parse(stamp[0]), DateTime.parse(stamp[1]));
}

Future clearReplacementStamps() async {
  final file = await getDocumentsFilePath('lastCheckedReplacements.txt');
  if (await file.exists()) {
    file.delete();
  }
}

Future<File> getDocumentsFilePath(String fileName) async {
  final directory = await pp.getApplicationDocumentsDirectory();
  return File(directory.path + '/$fileName');
}
