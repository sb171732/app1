import 'package:app1/screens/cart.dart';
import 'package:flutter/material.dart';

import 'screens/menu.dart';

class NavigationBarApp extends StatefulWidget {
  const NavigationBarApp({super.key});

  @override
  State<NavigationBarApp> createState() => _NavigationBarAppState();
}

class _NavigationBarAppState extends State<NavigationBarApp> {
  int currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const Menu(),
      Cart(),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text("CorpFood",
      style: TextStyle(color: Colors.black)
      ), backgroundColor: Colors.white,
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index){
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget> [
          NavigationDestination(icon: Icon(Icons.restaurant_menu), 
          selectedIcon: Icon(Icons.restaurant_menu_outlined), 
          label: 'Меню'),
          NavigationDestination(icon: Icon(Icons.shopping_basket), 
          selectedIcon: Icon(Icons.shopping_basket_outlined), 
          label: 'Корзина'),
        ],

      ),
    body: pages[currentPageIndex],
    );
  }
}