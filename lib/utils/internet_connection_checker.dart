import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart' show BuildContext;
import 'package:fluttertoast/fluttertoast.dart';

Future<bool> checkInternetConnection(
    BuildContext context, Function func) async {
  var result = await Connectivity().checkConnectivity();
  if (result != ConnectivityResult.none) {
    func.call();
  } else {
    Fluttertoast.showToast(msg: 'Вы не подключены к сети');
  }
  return result != ConnectivityResult.none;
}

Future<bool> checkInternetConnectionInBackground(
    Function func, Function elseFunc) async {
  var result = await Connectivity().checkConnectivity();
  if (result != ConnectivityResult.none) {
    func.call();
  } else {
    elseFunc.call();
  }
  return result != ConnectivityResult.none;
}
