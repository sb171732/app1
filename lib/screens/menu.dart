import 'dart:convert';
import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import 'package:flutter/widgets.dart';
>>>>>>> e4bd454 (добавил меню и jsondecode)
import 'package:http/http.dart' as http;

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
<<<<<<< HEAD
  
}

class _MenuState extends State<Menu> {
  @override
void initState() {
  super.initState();
  loadMenu();
}

  List<Map<String, dynamic>> menu = [];
  List<Map<String,dynamic>> cart = [];

  Future <void> loadMenu() async {
    final response = await http.get(Uri.parse('http://192.168.96.55:5000/menu'),);
=======
}

class _MenuState extends State<Menu> {
  List<Map<String, dynamic>> menu = [];
  Future <void> loadMenu() async {
    final response = await http.get(Uri.parse('ZATOCHKA'),);
>>>>>>> e4bd454 (добавил меню и jsondecode)
    if (response.statusCode==200){
      final List<Map<String, dynamic>> jsonData = List<Map<String,dynamic>>.from(jsonDecode(response.body),);
      setState(() {
        menu = jsonData;
      });
    } else {
      throw Exception('Ошибка');
    }
  }
<<<<<<< HEAD
    void addToCart(Map<String,dynamic> item){
    setState(() {
    cart.add(item);
    });
    print("добавляю в корзину");
  }
=======
>>>>>>> e4bd454 (добавил меню и jsondecode)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: menu.length,
        itemBuilder: (context, index){
          final dish = menu[index];
          return ListTile(
            leading: InkWell(onTap: (){}, child: Image.network(dish['image'],),),
            title: InkWell(onTap: (){}, child: Text(dish['name'],),),
<<<<<<< HEAD
            subtitle: TextButton(onPressed: (){addToCart(dish);}, child: Text(dish['price'].toString(),),
=======
            subtitle: TextButton(onPressed: (){}, child: Text(dish['price'],),
>>>>>>> e4bd454 (добавил меню и jsondecode)
            ),
          );
        }
      ),
    );
  }
}
