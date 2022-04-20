// import 'package:diary/background_worker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtkp/database/database_interface.dart';
import 'package:mtkp/models.dart';
import 'package:mtkp/settings_model.dart';
import 'package:mtkp/utils/notification_utils.dart';
import 'package:mtkp/views.dart/overview_page.dart';
import 'package:mtkp/workers/background_worker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  DatabaseWorker();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  if (!kIsWeb) {
    NotificationHandler().initializePlugin();
    initAlarmManager();
  }

  if (!kIsWeb) {
    loadSettings().then((value) {
      settings = value;
      if (value['background_enabled']) startShedule();
    });
  }

  runApp(const MyApp());
}

const Color errorColor = Colors.red;

const Color focusColor = Color.fromARGB(255, 255, 90, 131);

const Color primaryColor = Color.fromARGB(255, 0, 124, 249);

Map<String, dynamic> settings = {};

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _font = GoogleFonts.rubik(color: Colors.white);

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
              selectedIconTheme: IconThemeData(color: primaryColor, size: 30),
              unselectedIconTheme: IconThemeData(color: Colors.grey)),
          textTheme: TextTheme(
              headline6: GoogleFonts.rubik(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 20),
              headline5: _font,
              bodyText2: _font,
              button: _font.copyWith(color: Colors.white, fontSize: 16))),
    );
  }
}
