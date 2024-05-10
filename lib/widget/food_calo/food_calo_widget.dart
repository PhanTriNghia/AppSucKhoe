import 'package:flutter/material.dart';

import '../../model/Food.dart';

class FoodCaloWidget extends StatelessWidget {
  final List<Food> foods;

  FoodCaloWidget({required this.foods});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Foods'),
      ),
      body: ListView.builder(
        itemCount: foods.length,
        itemBuilder: (context, index) {
          Food food = foods[index];
          return ListTile(
            title: Text(food.FoodName),
            subtitle: Text('Calories: ${food.FoodCalo}'),
            // You can add more details here like the food image
          );
        },
      ),
    );
  }
}
