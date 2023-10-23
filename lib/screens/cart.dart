import 'dart:ffi';
import 'package:app1/screens/menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
 // Убедитесь, что путь к вашему файлу cart.dart указан правильно.

class Cart extends StatefulWidget {
  final PageController pageController;

  const Cart({Key? key, required this.pageController}) : super(key: key);
  
  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
   
  @override
  Widget build(BuildContext context) {
    final cartState = Provider.of<CartState>(context);
    return Material(
      child: Stack(
        children: [
          Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartState.cart.length,
                    itemBuilder: (context, index) {
                      final dish = cartState.cart[index];
                      return ListTile(
                        leading: InkWell(
                          onTap: () {
                            cartState.showDishDetails(dish);
                          },
                          child: Image.network(dish['image'] ?? 'https://example.com/placeholder_image.png'),
                        ),
                        title: InkWell(
                          onTap: () {
                            cartState.showDishDetails(dish);
                          },
                          child: Text(dish['name']),
                        ),
                        subtitle: TextButton(
                          onPressed: () {},
                          child: Text(dish['price'].toString()),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                cartState.updateQuantity(dish, 1);
                              },
                              icon: Icon(Icons.add),
                            ),
                            Text(dish['quantity'].toString(), style: TextStyle(fontSize: 16)),
                            IconButton(
                              onPressed: () {
                                cartState.updateQuantity(dish, -1);
                              },
                              icon: Icon(Icons.remove),
                            ),
                          ],
                        ),
                     );
                    },
                  ),
                ),
              ],
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
              ),
            ),
          if (cartState.cart.isNotEmpty) 
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: () {},
                child: Text('Оплатить ${cartState.getTotalPrice().toStringAsFixed(2)}'),
              ),
            ),
            if (cartState.cart.isEmpty)
            Text("Корзина пуста"),
        ],
        
      ),
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
      final quantity = item['quantity'];
      final price = item['price'];
      totalPrice += quantity * price;
    }

    return totalPrice;
  }

  void addToCart(Map<String, dynamic>? item) {
  if (item != null) {
    final id = item['id'];
    final name = item['name'];

    final existingCartItem = _cart.firstWhere(
      (cartItem) =>
          cartItem['id'] == id && cartItem['name'] == name,
      orElse: () => <String, dynamic>{},
    );

    if (existingCartItem.isNotEmpty) {
      existingCartItem['quantity'] = (existingCartItem['quantity'] ?? 0) + 1;
    } else {
      item['quantity'] = 1;
      _cart.add(item);
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
    }
  }
}


