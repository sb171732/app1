import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'cart.dart'; // Убедитесь, что путь к вашему файлу cart.dart указан правильно.

class Menu extends StatefulWidget {
  final PageController pageController;
   const Menu({Key? key, required this.pageController}) : super(key: key);

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  List<Dish> menu = [];
  late CartState cartState;
  Map<String, dynamic>? selectedDish;
  
  @override
  void initState() {
    super.initState();
    cartState = Provider.of<CartState>(context, listen: false);
    loadMenu();
  }

  Future<void> loadMenu() async {
    final response = await http.get(Uri.parse('http://192.168.40.55:5000/menu'));
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

  void showDishDetails(Map<String, dynamic> dish) {
    setState(() {
      selectedDish = dish;
    });
  }

  void hideDishDetails() {
    setState(() {
      selectedDish = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          ListView.builder(
            padding: EdgeInsets.all(10),
            itemExtent: 80,
            itemCount: menu.length,
            itemBuilder: (context, index) {
              final dish = menu[index];
              return KFCwidget(dish, () => showDishDetails(dish.toMap()));
            },
          ),
          if (selectedDish != null) 
            AnimatedDishDetails(
              dish: selectedDish!,
              isFromCart: false,
              onClose: () => hideDishDetails(),
            ),
        ],
      ),
    );
  }
}






class DishDetails extends StatelessWidget {
  final Map<String, dynamic> dish;
  final bool isFromCart;
  final PageController pageController; // Добавьте pageController как параметр

  DishDetails({required this.dish, required this.isFromCart, required this.pageController});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(dish['image']),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${dish['name']}',
                        style: const TextStyle(fontSize: 40),
                      ),
                      const Text(
                        "Описание",
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        '${dish['description']}',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: TextButton(
                onPressed: () {
                  if (isFromCart) {
                    pageController.animateToPage(1, duration: Duration(milliseconds: 500), curve: Curves.ease);
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
  final void Function() onClose; // Добавьте параметр для закрытия.

  AnimatedDishDetails({required this.dish, required this.isFromCart, required this.onClose});

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
      duration: const Duration(milliseconds: 500),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
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
                widget.onClose();
              });
            }
          },
          child: DishDetails(dish: widget.dish, isFromCart: widget.isFromCart, pageController: PageController(initialPage: 0)  ),
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
class KFCwidget extends StatelessWidget {
  final Dish dish;
  final void Function() onTapCallback;

  KFCwidget(this.dish, this.onTapCallback);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTapCallback(); 
      },
      child: Row(
        children: [
          Hero(
            tag: 'dish_image_${dish.id}',
            child: Image.network(
              dish.image,
              width: 150,
              height: 150,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'dish_name_${dish.id}',
                child: Text(
                  dish.name,
                  style: TextStyle(fontSize: 20),
                ),
              ),
              TextButton(
                onPressed: () {
                  final cartState = Provider.of<CartState>(context, listen: false);
                  cartState.addToCart(dish.toMap());
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
                child: Text('${dish.price.toStringAsFixed(0)}', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

