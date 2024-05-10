import 'package:cloud_firestore/cloud_firestore.dart';

class FoodCategory {
  final String FoodCategoryID;
  final String FoodCategoryName;

  FoodCategory(this.FoodCategoryID, this.FoodCategoryName);

  toJson() {
    return {
      "FoodCategoryID": FoodCategoryID,
      "FoodCategoryName": FoodCategoryName,
    };
  }

  factory FoodCategory.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    return FoodCategory(
      data?['FoodCategoryID'] ?? '', // Set value thành mặc định nếu 'FoodCategoryID' null
      data?['FoodCategoryName'] ?? '', // Set value thành mặc định nếu 'FoodCategoryName' null
    );
  }
}