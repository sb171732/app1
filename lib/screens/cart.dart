import 'package:flutter/material.dart';

class Cart extends StatefulWidget {
  List<Map<String,dynamic>> cart = [];
  Cart({Key? key, required this.cart}) : super(key: key);
  

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  
  @override
  Widget build(BuildContext context) {
    print(widget.cart);
    return Scaffold(
      body: ListView.builder(
        itemCount: widget.cart.length,
        itemBuilder: (context,index){
          final dish = widget.cart[index];
          return ListTile(
            leading: InkWell(onTap: (){}, child: Image.network(dish['image'],),),
            title: InkWell(onTap: (){}, child: Text(dish['name'],),),
            subtitle: TextButton(onPressed: (){}, child: Text(dish['price'],),
            ),
          );
      }
      )
    );
  }
}