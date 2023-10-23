import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'cart.dart'; // Убедитесь, что путь к вашему файлу cart.dart указан правильно.

class Menu extends StatefulWidget {
  const Menu({Key? key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  List<Dish> menu = []; // Теперь список содержит объекты Dish
  late CartState cartState;

  @override
  void initState() {
    super.initState();
    cartState = Provider.of<CartState>(context, listen: false);
    loadMenu();
  }

  Future<void> loadMenu() async {
    final response = await http.get(Uri.parse('http://192.168.40.55:5000/menu'),);
    if (response.statusCode == 200) {
      final jsonData = List<Map<String, dynamic>>.from(jsonDecode(response.body));

      setState(() {
        menu = jsonData.map((data) => Dish(
          id: data['id'],
          name: data['name'],
          description: data['description'],
          price: data['price'].toDouble(),
          image: data['image'],
        )).toList();
      });
    } else {
      print(Exception);
      throw Exception('Ошибка');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: menu.length,
        itemBuilder: (context, index) {
          final dish = menu[index];
          return ListTile(
            leading: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                 builder: (context) => AnimatedDishDetails(dish: dish.toMap(), isFromCart: false),

                ));
              },
              child: Image.network(dish.image),
            ),
            title: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                 builder: (context) => AnimatedDishDetails(dish: dish.toMap(), isFromCart: false),

                ));
              },
              child: Text(dish.name),
            ),
            subtitle: TextButton(
              onPressed: () {
                final cartState = Provider.of<CartState>(context, listen: false);
                cartState.addToCart(dish.toMap());
              },
              child: Text(dish.price.toString()),
            ),
          );
        },
      ),
    );
  }
}




class DishDetails extends StatelessWidget {
  final Map<String, dynamic> dish;
  final bool isFromCart;
  DishDetails({required this.dish, required this.isFromCart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(dish['image']),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '${dish['name']}',
        style: TextStyle(fontSize: 40),
      ),
      Text(
        "Описание",
        style: TextStyle(fontSize: 20), // Измените на желаемый размер шрифта
      ),
      Text(
        '${dish['description']}',
        style: TextStyle(fontSize: 15),
      ),
    ],
  ),
)

              ],
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: TextButton(
                onPressed: () {
                  
                  if (isFromCart) {
                    Navigator.pop(context);
                  } else {
                    final cartState = Provider.of<CartState>(context, listen: false);
                  cartState.addToCart(dish);
                  }
                  
                },
                child: Text(isFromCart ? "Готово" : "Добавить в корзину ${dish["price"]}"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedDishDetails extends StatefulWidget {
  final Map<String, dynamic> dish;
  final bool isFromCart;
  AnimatedDishDetails({required this.dish, required this.isFromCart});

  @override
  _AnimatedDishDetailsState createState() => _AnimatedDishDetailsState();
}


class _AnimatedDishDetailsState extends State<AnimatedDishDetails> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset(0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Scaffold(
        body: GestureDetector(
          onVerticalDragUpdate: (details) {
            if (details.primaryDelta! < -20) {
              _animationController.reverse().then((_) {
                Navigator.pop(context);
              });
            }
          },
          child: DishDetails(dish: widget.dish, isFromCart: widget.isFromCart),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
class Dish {
  final int id;
  final String name;
  final String description;
  final double price;
  final String image;
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
    };
  }
  Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
  });
}
