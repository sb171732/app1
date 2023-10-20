import 'dart:convert';
import 'package:app1/screens/cart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
// Замените на путь к вашему классу состояния корзины

class Menu extends StatefulWidget {
  const Menu({Key? key});
  

  @override
  State<Menu> createState() => _MenuState();
  
}

class _MenuState extends State<Menu> {
  List<Map<String, dynamic>> menu = [];

  @override
  void initState() {
    super.initState();
    loadMenu();
  }

  Future<void> loadMenu() async {
    final response = await http.get(Uri.parse('http://192.168.96.55:5000/menu'),);
    if (response.statusCode == 200) {
      final List<Map<String, dynamic>> jsonData = List<Map<String, dynamic>>.from(jsonDecode(response.body));

      final cartState = Provider.of<CartState>(context, listen: false);

      setState(() {
        menu = jsonData;
      });
    } else {
      print(Exception);
      throw Exception('Ошибка');
    }
  }

  void addToCart(Map<String, dynamic> item) {
    final cartState = Provider.of<CartState>(context, listen: false);
    cartState.addToCart(item);
    print("добавляю в корзину");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: menu.length,
        itemBuilder: (context, index) {
          final dish = menu[index];
          return ListTile(
            leading: InkWell(onTap: () {}, child: Image.network(dish['image'])),
            title: InkWell(onTap: () {}, child: Text(dish['name'])),
            subtitle: TextButton(
              onPressed: () {
                addToCart(dish);
              },
              child: Text(dish['price'].toString()),
            ),
          );
        },
      ),
    );
  }
}