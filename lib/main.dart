// import 'package:diary/background_worker.dart';
import 'package:mtkp/database/database_interface.dart';
import 'package:mtkp/overview_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

const Color primaryColor = Color.fromARGB(255, 0, 124, 249);
const Color focusColor = Color.fromARGB(255, 255, 90, 131);
const Color errorColor = Colors.red;

void main() {
  DatabaseWorker();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

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
          navigationBarTheme: const NavigationBarThemeData(
              backgroundColor: Color.fromARGB(255, 69, 69, 69),
              indicatorColor: primaryColor,
              height: 50,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide),
          textTheme: TextTheme(
              headline6: _font,
              headline5: _font,
              bodyText2: _font,
              button: _font.copyWith(color: Colors.white, fontSize: 16))),
    );
  }
}
