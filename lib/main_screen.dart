import 'package:diary/overview_page.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedScreen = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const OverviewPage(),
      bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedScreen,
          onDestinationSelected: (value) =>
              setState(() => _selectedScreen = value),
          destinations: [
            NavigationDestination(
                icon: const Icon(Icons.calendar_view_day_rounded),
                selectedIcon: Icon(
                  Icons.calendar_view_day_rounded,
                  color: Colors.grey.shade200,
                ),
                label: 'Расписание'),
            NavigationDestination(
                icon: const Icon(Icons.school_rounded),
                selectedIcon: Icon(
                  Icons.school_rounded,
                  color: Colors.grey.shade200,
                ),
                label: 'Преподаватели')
          ]),
    );
  }
}
