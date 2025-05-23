import 'package:flutter/material.dart';

class MyCartButton extends StatelessWidget {
  const MyCartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 36, 
      onPressed: () => Navigator.pushNamed(context, '/cart_page'),
      icon: const Icon(Icons.shopping_basket), 
    );
  }
}
