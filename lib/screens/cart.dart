import 'dart:ffi';
import 'package:app1/screens/menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
 // Убедитесь, что путь к вашему файлу cart.dart указан правильно.

class Cart extends StatefulWidget {
  final PageController pageController;
  final VoidCallback GoMenu;

  const Cart({Key? key, required this.pageController, required this.GoMenu}) : super(key: key);

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  @override
  Widget build(BuildContext context) {
    final cartState = Provider.of<CartState>(context);
    return PageView(
      controller: widget.pageController,
      children: [
        Stack(
          children: [
            Scaffold(
              body: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    color: Colors.white.withOpacity(0.7),
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Набрано в корзину ${cartState.cart.length} блюд на ${cartState.getTotalPrice().toStringAsFixed(2)}",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: cartState.cart.length,
                      itemBuilder: (context, index) {
                        final item = cartState.cart[index];
                        final dish = Dish(
                          id: item['id'],
                          name: item['name'],
                          description: item['description'],
                          price: item['price'].toDouble(),
                          image: item['image'],
                        );

                        return CartKFCwidget(
                          dish: dish,
                          onUpdateQuantity: (int change) {
                            cartState.updateQuantity(dish.toMap(), change);
                          },
                          quantity: cartState.cart
                              .where((item) => item['id'] == dish.id)
                              .map<int>((item) => item['quantity'] as int)
                              .fold(0, (prev, curr) => prev + curr),
                          onTapCallback: () {
                            cartState.showDishDetails(dish.toMap());
                          },
                          cartState: cartState,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (cartState.cart.isNotEmpty && cartState.selectedDish == null)
              Align(
                
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text('Оплатить ${cartState.getTotalPrice().toStringAsFixed(2)}₽'),
                  
                ),
                
              ),
            if (cartState.selectedDish != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedDishDetails(
                  dish: cartState.selectedDish!,
                  isFromCart: true,
                  onClose: () {
                    cartState.hideDishDetails();
                    widget.pageController.jumpToPage(1);
                  },
                  pageController: widget.pageController,
                ),
              ),
            if (cartState.cart.isEmpty)
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Корзина пуста\nВыберите блюда из меню",
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ],
                ),
              ),
            if (cartState.cart.isEmpty)
              Container(
                width: double.infinity,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: TextButton(
                    onPressed: widget.GoMenu,
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.red)),
                    child: const Text(
                      "Перейти в меню",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}


class CartState with ChangeNotifier {
  void showDishDetails(Map<String, dynamic> dish) {
    _selectedDish = dish;
    
    notifyListeners();
  }

  void hideDishDetails() {
    _selectedDish = null;
    notifyListeners();
  }
  

  List<Map<String, dynamic>> _cart = [];
  Map<String, dynamic>? _selectedDish;
  Map<String, dynamic>? get selectedDish => _selectedDish;
  
  List<Map<String, dynamic>> get cart => _cart;

  double getTotalPrice() {
    double totalPrice = 0.0;

    for (final item in _cart) {
      final quantity = item['quantity'] ?? 1;
      final price = item['price']?? 5;
      totalPrice += quantity * price;
    }

    return totalPrice;
  }

  void addToCart(Map<String, dynamic>? item) {
  if (item != null) {
    final id = item['id'];
    final name = item['name'];
    final description = item['description'];
    final price = item['price'].toDouble();
    final image = item['image'];

    final existingCartItem = _cart.firstWhere(
      (cartItem) =>
          cartItem['id'] == id && cartItem['name'] == name,
      orElse: () => <String, dynamic>{},
    );

    if (existingCartItem.isNotEmpty) {
      existingCartItem['quantity'] = (existingCartItem['quantity']) + 1;
      print('обновляю ТОВАР');
    } else {
      print('ДОБАВЛЯЮ ТОВАР С 1');
      _cart.add({
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'image': image,
        'quantity': 1
      });
    }
    notifyListeners();
  }
}







  void updateQuantity(Map<String, dynamic> item, int change) {
    final id = item['id'];

    for (int i = 0; i < _cart.length; i++) {
      if (_cart[i]['id'] == id) {
        final newQuantity = _cart[i]['quantity'] + change;
        if (newQuantity <= 0) {
          _cart.removeAt(i);
        } else {
          _cart[i]['quantity'] = newQuantity;
        }
        notifyListeners();
        break;
      }
      print('ЧЕТОСТРАШНОЕПРОИСХОДИТ');
    }
  }
}


