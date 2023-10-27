import 'dart:convert';
import 'newsObjects.dart';
import 'package:app1/screens/newsObjects.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'cart.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Убедитесь, что путь к вашему файлу cart.dart указан правильно.

class Menu extends StatefulWidget {
  final PageController pageController;
  const Menu({Key? key, required this.pageController}) : super(key: key);

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<Dish> menu = [];
  late CartState cartState;
  Map<String, dynamic>? selectedDish;
  List<News> newsList = []; // Добавьте это в ваш класс Menu

  @override
  void initState() {
    super.initState();
    cartState = Provider.of<CartState>(context, listen: false);
    loadMenu();
    loadNews();
  }

//   Future<void> loadMenu() async {
//   final menuData = await firestore.collection('menu').get();
//   final menuList = menuData.docs.map((doc) => doc.data()).toList();

//   if (mounted) {
//     setState(() {
//       menu = menuList.map((data) => Dish(
//         id: data['id'],
//         name: data['name'],
//         description: data['description'],
//         price: data['price'].toDouble(),
//         image: data['image'],
//       )).toList();
//     });
//   }
// }
  Future<void> loadMenu() async {
    final response =
        await http.get(Uri.parse('http://192.168.76.55:5000/menu'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as List<dynamic>;

      setState(() {
        menu = jsonData
            .map((data) => Dish(
                  id: data['id'],
                  name: data['name'],
                  description: data['description'],
                  price: data['price'].toDouble(),
                  image: data['image'],
                ))
            .toList();
      });
    }
  }

  void showDishDetails(Map<String, dynamic> dish) {
    final cartState = Provider.of<CartState>(context, listen: false);
    cartState.showDishDetails(dish);
  }

  void hideDishDetails() {
    final cartState = Provider.of<CartState>(context, listen: false);
    cartState.hideDishDetails();
  }

  void closeDishDetails() {
    hideDishDetails();
    print("closeDishDetails called");
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: widget.pageController,
      children: [
        Stack(
          children: [
            Scaffold(
              body: CustomScrollView(
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildListDelegate(
                      <Widget>[
                        Column(
                          children: newsList.map((newsItem) {
                            return ListTile(
                              leading: Image.network(newsItem.image),
                              title: Text(newsItem.title),
                            );
                          }).toList(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  "Выберите понравившиеся блюда",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        if (index == 0) {
                          return Container(); // Здесь ничего не отображаем, так как новости уже выше
                        } else {
                          final dish = menu[index - 1];
                          return MenuKFCwidget(
                              dish: dish,
                              onTapCallback: (CartState cartState) {
                                cartState.showDishDetails(dish.toMap());
                                // Другие операции, связанные с корзиной
                              });
                        }
                      },
                      childCount: menu.length,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DishDetails extends StatelessWidget {
  final Map<String, dynamic> dish;
  final bool isFromCart;
  final PageController pageController;
  final VoidCallback onClose;

  DishDetails(
      {required this.dish,
      required this.isFromCart,
      required this.pageController,
      required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IconButton добавлен сюда
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                print("IconButton pressed");
                onClose();
              },
            ),
          ),

          // Ваш остальной контент
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
                    print("Close from cart");
                    onClose();
                  } else {
                    final cartState =
                        Provider.of<CartState>(context, listen: false);
                    cartState.addToCart(dish);
                    print("Add to cart");
                    onClose();
                  }
                },
                child: Text(isFromCart
                    ? "Готово"
                    : "Добавить в корзину ${dish["price"]}"),
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
  final void Function() onClose;
  final PageController pageController;

  AnimatedDishDetails({
    required this.dish,
    required this.isFromCart,
    required this.onClose,
    required this.pageController,
  });

  @override
  _AnimatedDishDetailsState createState() => _AnimatedDishDetailsState();
}

class _AnimatedDishDetailsState extends State<AnimatedDishDetails>
    with SingleTickerProviderStateMixin {
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
      child: SafeArea(
        // Обернул в SafeArea
        child: Scaffold(
          backgroundColor: Colors.white, // Настроил цвет фона по вашему выбору
          body: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.primaryDelta! < -20) {
                  _animationController.reverse().then((_) {
                    widget.onClose();
                  });
                }
              },
              child: SingleChildScrollView(
                child: DishDetails(
                  dish: widget.dish,
                  isFromCart: widget.isFromCart,
                  pageController: widget.pageController,
                  onClose: widget.onClose,
                ),
              )),
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

class MenuKFCwidget extends StatelessWidget {
  final Dish dish;
  final void Function(CartState) onTapCallback;

  MenuKFCwidget({required this.dish, required this.onTapCallback});

  @override
  Widget build(BuildContext context) {
    final imageWidth = 150.0;
    final imageHeight = 150.0;
    final fontSize = 20.0;

    return InkWell(
      onTap: () {
        final cartState = Provider.of<CartState>(context, listen: false);
        onTapCallback(cartState); // Передаем cartState в колбэк
        print("Показываю");
        // Передаем информацию о блюде в showDishDetails
      },
      child: Row(
        children: [
          Hero(
            tag: 'dish_image_${dish.id}',
            child: CachedNetworkImage(
              imageUrl: dish.image,
              width: imageWidth,
              height: imageHeight,
              placeholder: (context, url) =>
                  CircularProgressIndicator(), // Опционально: отображение индикатора загрузки
              errorWidget: (context, url, error) =>
                  Icon(Icons.error), // Опционально: отображение иконки ошибки
            ),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'dish_name_${dish.id}',
                child: Text(
                  dish.name,
                  style: TextStyle(fontSize: fontSize),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      final cartState =
                          Provider.of<CartState>(context, listen: false);
                      cartState.addToCart(dish.toMap());
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: Text('${dish.price.toStringAsFixed(0)}₽',
                        style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CartKFCwidget extends StatelessWidget {
  final Dish dish;
  final void Function(int) onUpdateQuantity;
  final int quantity;
  final void Function() onTapCallback;
  final CartState cartState;

  CartKFCwidget({
    required this.dish,
    required this.onUpdateQuantity,
    required this.quantity,
    required this.onTapCallback,
    required this.cartState,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidth = 100.0;
    final imageHeight = 100.0;
    final fontSize = 16.0;

    return InkWell(
      onTap: () {
        cartState.showDishDetails(dish.toMap());
      },
      child: SingleChildScrollView(
        // Обернул ваш виджет в SingleChildScrollView
        child: Row(
          children: [
            // Container(
            //   alignment: Alignment.center,
            //   color: Colors.black.withOpacity(0.7),
            //   padding: EdgeInsets.all(8.0),
            //   // child: Column(
            //   //   // children: [
            //   //   //   Text("Набрано в корзину ${quantity.toString()} блюд на ${cartState.getTotalPrice().toStringAsFixed(2)}"),
            //   //   // ],
            //   // ),
            // ),
            Hero(
              tag: 'dish_image_${dish.id}',
              child: CachedNetworkImage(
                imageUrl: dish.image,
                width: imageWidth,
                height: imageHeight,
                placeholder: (context, url) =>
                    CircularProgressIndicator(), // Опционально: отображение индикатора загрузки
                errorWidget: (context, url, error) =>
                    Icon(Icons.error), // Опционально: отображение иконки ошибки
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'dish_name_${dish.id}',
                  child: Text(
                    dish.name,
                    style: TextStyle(fontSize: fontSize),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () => onUpdateQuantity(1),
                        icon: Icon(Icons.add)),
                    Text(quantity.toString()), // Отображение количества товара
                    IconButton(
                        onPressed: () => onUpdateQuantity(-1),
                        icon: Icon(Icons.remove)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
