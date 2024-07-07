import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:samling_app_web/views/side_bar_screens/items_screen.dart';
import 'package:samling_app_web/views/side_bar_screens/types_screen.dart';
import 'package:samling_app_web/views/side_bar_screens/users_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Widget _selectedScreen = UsersScreen();

  screenSelector(item) {
    switch (item.route) {
      case UsersScreen.id:
        setState(() {
          _selectedScreen = UsersScreen();
        });
        break;
      case TypesScreen.id:
        setState(() {
          _selectedScreen = TypesScreen();
        });
        break;
      case ItemsScreen.id:
        setState(() {
          _selectedScreen = ItemsScreen();
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Management"),
      ),
      body: _selectedScreen,
      sideBar: SideBar(
        items: const [
          AdminMenuItem(
            title: "Users",
            route: UsersScreen.id,
            icon: CupertinoIcons.person_3,
          ),
          AdminMenuItem(
            title: "Types",
            route: TypesScreen.id,
            icon: Icons.store,
          ),
          AdminMenuItem(
            title: "Items",
            route: ItemsScreen.id,
            icon: CupertinoIcons.cube_box,
          )
        ],
        selectedRoute: UsersScreen.id,
        onSelected: (item) {
          screenSelector(item);
        },
      ),
    );
  }
}
