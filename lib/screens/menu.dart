import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  List<Map<String, dynamic>> menu = [];
  Future <void> loadMenu() async {
    final response = await http.get(Uri.parse('ZATOCHKA'),);
    if (response.statusCode==200){
      final List<Map<String, dynamic>> jsonData = List<Map<String,dynamic>>.from(jsonDecode(response.body),);
      setState(() {
        menu = jsonData;
      });
    } else {
      throw Exception('Ошибка');
    }
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
            subtitle: TextButton(onPressed: (){}, child: Text(dish['price'],),
            ),
          );
        }
      ),
    );
  }
}
