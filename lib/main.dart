import 'package:diary/database/database_interface.dart';
import 'package:diary/overview_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

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
    final font = GoogleFonts.rubik();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const OverviewPage(),
      theme: ThemeData(
          appBarTheme: const AppBarTheme(
              color: Colors.white, foregroundColor: Colors.black, elevation: 1),
          primaryColorLight: const Color(0xFF00bbf9),
          textTheme: TextTheme(
              headline6: font,
              headline5: font,
              bodyText2: font,
              button: font.copyWith(color: Colors.black, fontSize: 16))),
    );
  }
}
