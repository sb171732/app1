import 'package:app1/firebase_options.dart';
import 'package:app1/home.dart';
import 'package:app1/screens/account.dart';
import 'package:app1/screens/cart.dart';

import 'package:app1/services/FireBaseStreem.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'verify/login_screen.dart';
import 'verify/reset_password_screen.dart';
import 'verify/signup_screen.dart';
import 'verify/verify_email_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final themeProvider = ThemeProvider(); // Создайте экземпляр ThemeProvider
  runApp(MyApp(themeProvider: themeProvider)); // Передайте его в MyApp
}

 class MyApp extends StatelessWidget {
  
  final ThemeProvider themeProvider; // Добавьте ThemeProvider как параметр конструктора

   MyApp({Key? key, required this.themeProvider}) : super(key: key);
  final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.black, // Ваши цвета для темной темы
);

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.white, // Ваши цвета для светлой темы
);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartState()),
      ],
      child: ChangeNotifierProvider.value( // Используйте ChangeNotifierProvider.value
        value: themeProvider, // Передайте экземпляр ThemeProvider
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeProvider.isDarkMode ? darkTheme : lightTheme,
          // Другие настройки MaterialApp
          routes: {
            '/home': (context) => NavigationBarApp(),
            '/': (context) => const FirebaseStream(),
            '/account': (context) => const Account(),
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/reset_password': (context) => const ResetPasswordScreen(),
            '/verify_email': (context) => const VerifyEmailScreen(),
          },
          initialRoute: '/',
        ),
      ),
    );
  }
}
