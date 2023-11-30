import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'home/home_tab.dart';
import 'home/clear_tab.dart';
import 'home/reports_tab.dart';
import 'home/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    HomeTab(),
    ClearTab(),
    ReportsTab(),
    ProfileTab(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Credit Management',
          style: TextStyle(color: Colors.blue), // Set the app bar text color to blue
        ),
        backgroundColor: Colors.transparent, // Make the app bar transparent
        elevation: 0, // Remove the shadow from the app bar
        actions: [
          IconButton(icon: Icon(LineIcons.bell, color: Colors.black,), onPressed: () => {}), // Add notification icon functionality
          IconButton(icon: Icon(LineIcons.cog, color: Colors.black,), onPressed: () => {}), // Add settings icon functionality
        ],
      ),
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(LineIcons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(LineIcons.receipt), label: 'Clear'),
          BottomNavigationBarItem(icon: Icon(LineIcons.areaChart), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(LineIcons.user), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue, // Active icon color
        unselectedItemColor: Colors.black, // Inactive icon color
        onTap: _onTabSelected,
      ),
    );
  }
}
