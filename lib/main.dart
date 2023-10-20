import 'package:app1/home.dart';
import 'package:app1/screens/cart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartState()),
       
      ],
      child: MyApp(), 
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => const NavigationBarApp(),
      },
      initialRoute: '/home',
    );
  }
}