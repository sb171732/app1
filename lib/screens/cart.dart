import 'dart:ffi';

import 'package:app1/screens/menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class Cart extends StatefulWidget {
  const Cart({Key? key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  
  
  @override
  Widget build(BuildContext context) {
    final cartState = Provider.of<CartState>(context);
    return cartState.cart.isEmpty ? Scaffold(
      body: Center(
        child: Text("Корзина пуста"),
      ),
      
    ) 
    :
    Scaffold(
      body: Column(
        children: [
          Expanded(child:ListView.builder(
        itemCount: cartState.cart.length,
        itemBuilder: (context, index) {
          final dish = cartState.cart[index];
          return ListTile(
            leading: InkWell(onTap: () {Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AnimatedDishDetails(dish: dish, isFromCart: true),
                ));}, child: Image.network(dish['image'])),
            title: InkWell(onTap: () {Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AnimatedDishDetails(dish: dish, isFromCart: true),
                ));}, child: Text(dish['name'])),
            subtitle: TextButton(
              onPressed: () {},
              child: Text(dish['price'].toString()),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(onPressed: (){cartState.updateQuantity(dish, 1);}, icon: Icon(Icons.add)),
                Text(dish['quantity'].toString(), style: TextStyle(fontSize: 16)),

                IconButton(onPressed: (){cartState.updateQuantity(dish, -1);}, icon: Icon(Icons.remove)),
                
              ],
            
            ),
            
          );
          
        },

      ), 
      
      ),
        if (cartState.cart.isNotEmpty) 
          ElevatedButton(
            onPressed: () {
              
            },
            child: Text('Оплатить${cartState.getTotalPrice().toStringAsFixed(2)}'),
          ),
        ],
      )
      
      
    );
    
  }
}


class CartState with ChangeNotifier {
  List<Map<String, dynamic>> _cart = [];

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

  void addToCart(Map<String, dynamic> item) {
  final id = item['id'];
  final existingCartItem = _cart.firstWhere(
    (cartItem) => cartItem['id'] == id,
    orElse: () => Map<String, dynamic>.from({}), // Создайте пустой Map вместо null
  );

  if (existingCartItem != null) {
    print("обновляю товар ");
    existingCartItem['quantity'] = (existingCartItem['quantity'] ?? 0) + 1;
    
  } else {
    print(" добавляю товар");
    item['quantity'] = 1;
    _cart.add(item);
  }
  notifyListeners();
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


