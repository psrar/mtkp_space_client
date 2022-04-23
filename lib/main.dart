// import 'package:diary/background_worker.dart';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtkp/database/database_interface.dart';
import 'package:mtkp/settings_model.dart';
import 'package:mtkp/utils/notification_utils.dart';
import 'package:mtkp/views/overview_page.dart';
import 'package:mtkp/workers/background_worker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  DatabaseWorker();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  if (!kIsWeb && !Platform.isLinux) {
    NotificationHandler().initializePlugin();
    initAlarmManager();
  }

  if (!kIsWeb && !Platform.isLinux) {
    loadSettings().then((value) {
      settings = value;
      if (value['background_enabled']) startShedule();
    });
  }

  runApp(const MyApp());
}

const bool debugMode = false;

const Color errorColor = Colors.red;
const Color focusColor = Color.fromARGB(255, 255, 90, 131);
const Color primaryColor = Color.fromARGB(255, 0, 124, 249);
const Color accessColor = Color.fromARGB(255, 139, 255, 145);
final primeFont = GoogleFonts.rubik(color: Colors.white);
final headerFont = GoogleFonts.rubik(
    color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24);
final giantFont = GoogleFonts.rubik(
    color: Colors.white, fontWeight: FontWeight.w800, fontSize: 30);

Map<String, dynamic> settings = {};

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const OverviewPage(),
      theme: ThemeData(
          appBarTheme: const AppBarTheme(
              color: Color.fromARGB(255, 69, 69, 69),
              foregroundColor: Colors.white,
              elevation: 1),
          primaryColorLight: primaryColor,
          focusColor: focusColor,
          scaffoldBackgroundColor: const Color.fromARGB(255, 52, 52, 52),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color.fromARGB(255, 69, 69, 69),
              selectedItemColor: primaryColor,
              showUnselectedLabels: false,
              showSelectedLabels: false,
              selectedIconTheme: IconThemeData(color: primaryColor, size: 32),
              unselectedIconTheme: IconThemeData(color: Colors.grey),
              type: BottomNavigationBarType.fixed,
              elevation: 1),
          textTheme: TextTheme(
              headline6: GoogleFonts.rubik(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 24),
              headline5: primeFont,
              bodyText2: primeFont,
              button: primeFont.copyWith(color: Colors.white, fontSize: 16))),
    );
  }
}
