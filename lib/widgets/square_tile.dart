import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  final String imagePath;
  final double size;

  const SquareTile({super.key, required this.imagePath, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.asset(imagePath, height: size, width: size),
    );
  }
}
