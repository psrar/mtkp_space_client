// import 'package:diary/background_worker.dart';
import 'package:diary/database/database_interface.dart';
import 'package:diary/overview_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

void main() {
  DatabaseWorker();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // startDispatcher();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _font = GoogleFonts.rubik();
    const Color _primaryColor = Color.fromARGB(255, 0, 124, 249);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const OverviewPage(),
      theme: ThemeData(
          appBarTheme: const AppBarTheme(
              color: Colors.white, foregroundColor: Colors.black, elevation: 1),
          primaryColorLight: _primaryColor,
          scaffoldBackgroundColor: const Color(0xFFfafafa),
          navigationBarTheme: const NavigationBarThemeData(
              indicatorColor: _primaryColor,
              height: 50,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide),
          textTheme: TextTheme(
              headline6: _font,
              headline5: _font,
              bodyText2: _font,
              button: _font.copyWith(color: Colors.black, fontSize: 16))),
    );
  }
}
