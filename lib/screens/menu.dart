import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
  
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
    if (response.statusCode==200){
      final List<Map<String, dynamic>> jsonData = List<Map<String,dynamic>>.from(jsonDecode(response.body),);
      setState(() {
        menu = jsonData;
      });
    } else {
      throw Exception('Ошибка');
    }
  }
    void addToCart(Map<String,dynamic> item){
    setState(() {
    cart.add(item);
    });
    print("добавляю в корзину");
  }
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
            subtitle: TextButton(onPressed: (){addToCart(dish);}, child: Text(dish['price'].toString(),),
            ),
          );
        }
      ),
    );
  }
}
