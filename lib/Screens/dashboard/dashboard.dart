import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:reciperover/Components/consts.dart';
import 'package:reciperover/Screens/dashboard/SearchPage.dart';
import 'package:reciperover/Screens/dashboard/profile/profile.dart';
import 'package:reciperover/Screens/favoritesPage.dart';
import 'package:reciperover/Screens/homePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bottom Navigation Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller = PersistentTabController(initialIndex: 0);
  List<Widget> _buildScreen() {
    return [HomePage(), SearchPage(), FavoritesPage(), ProfileScreen()];
  }

  List<PersistentBottomNavBarItem> _navBarItems() {
    return [
      PersistentBottomNavBarItem(
          icon: Icon(Icons.home),
          activeColorPrimary: DarkPurple,
          inactiveColorPrimary: Colors.white,
          title: ("Home")),
      PersistentBottomNavBarItem(
          icon: Icon(Icons.search),
          activeColorPrimary: DarkPurple,
          inactiveColorPrimary: Colors.white,
          title: ("Search")),
      PersistentBottomNavBarItem(
          icon: Icon(Icons.favorite),
          activeColorPrimary: DarkPurple,
          inactiveColorPrimary: Colors.white,
          title: ("Favorites")),
      PersistentBottomNavBarItem(
          icon: Icon(Icons.person),
          activeColorPrimary: DarkPurple,
          inactiveColorPrimary: LightPurple,
          title: ("Profile")),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
        controller: _controller,
        context,
        screens: _buildScreen(),
        items: _navBarItems(),
        backgroundColor: Colors.grey);
  }
}
