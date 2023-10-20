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

    return Scaffold(
      body: ListView.builder(
        itemCount: cartState.cart.length,
        itemBuilder: (context, index) {
          final dish = cartState.cart[index];
          return ListTile(
            leading: InkWell(onTap: () {}, child: Image.network(dish['image'])),
            title: InkWell(onTap: () {}, child: Text(dish['name'])),
            subtitle: TextButton(
              onPressed: () {},
              child: Text(dish['price'].toString()),
            ),
          );
        },
      ),
    );
  }
}


class CartState with ChangeNotifier {
  List<Map<String, dynamic>> _cart = [];

  List<Map<String, dynamic>> get cart => _cart;

  void addToCart(Map<String, dynamic> item) {
    _cart.add(item);
    notifyListeners();
  }
}
