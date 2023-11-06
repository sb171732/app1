import 'package:app1/screens/cart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'screens/menu.dart';

class NavigationBarApp extends StatefulWidget {
  // По умолчанию светлая тема
  NavigationBarApp({Key? key}) : super(key: key);

  @override
  State<NavigationBarApp> createState() => _NavigationBarAppState();
}

class _NavigationBarAppState extends State<NavigationBarApp> {
  final user = FirebaseAuth.instance.currentUser;
  late PageController pageController; // Создайте экземпляр PageController
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController =
        PageController(initialPage: 0); // Инициализируйте контроллер страниц
  }

  void GoMenu() {
    setState(() {
      currentPageIndex = 0;
      // Установите текущий индекс страницы на 0
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final List<Widget> pages = [
      Menu(
          pageController:
              pageController), // Передайте контроллер страниц для Menu.
      Cart(
        pageController: pageController,
        GoMenu: GoMenu, // Передайте функцию GoMenu для Cart.
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("CorpFood", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Colors.white),
                accountName: Text(user?.displayName ?? 'Гость',
                    style: TextStyle(color: Colors.black)),
                accountEmail: Text(user?.email ?? 'Анонимус залогинься',
                    style: TextStyle(color: Colors.black)),
              ),
            ),
            ListTile(
              title: Text("О себе"),
              leading: Icon(Icons.account_box),
              onTap: () {
                Navigator.pushNamed(context, '/account');
              },
            ),
            ListTile(
              title: Text("Настройки"),
              leading: Icon(Icons.settings),
              onTap: () {},
            ),
            ListTile(
              title: Text("Темная тема"),
              leading: Icon(Icons.brightness_4),
              trailing: Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.isDarkMode;
                      setState(() {
                        themeProvider.isDarkMode;
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu),
            selectedIcon: Icon(Icons.restaurant_menu_outlined),
            label: 'Меню',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_basket),
            selectedIcon: Icon(Icons.shopping_basket_outlined),
            label: 'Корзина',
          ),
        ],
      ),
      body: pages[currentPageIndex],
    );
  }
}

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
