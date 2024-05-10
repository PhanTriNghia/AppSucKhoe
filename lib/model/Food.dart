import 'package:cloud_firestore/cloud_firestore.dart';

class Food {
  final String FoodID;
  final String FoodCategoryID;
  final String FoodName;
  final num FoodCalo;
  final String FoodImage;


  Food(this.FoodID, this.FoodCategoryID, this.FoodName, this.FoodCalo,
      this.FoodImage);

  toJson() {
    return {
      "FoodID": FoodID,
      "FoodCategoryID": FoodCategoryID,
      "FoodName": FoodName,
      "FoodCalo": FoodCalo,
      "FoodImage": FoodImage,
    };
  }

  factory Food.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    return Food(
      data?['FoodID'] ?? '', // Set value thành mặc định nếu 'FoodID' null
      data?['FoodCategoryID'] ?? '', // Set value thành mặc định nếu 'FoodCategoryID' null
      data?['FoodName'] ?? '', // Set value thành mặc định nếu 'FoodName' null
      data?['FoodCalo'] ?? 0, // Set value thành mặc định nếu 'FoodCalo' null
      data?['FoodImage'] ?? '', // Set value thành mặc định nếu 'FoodImage' null
    );
  }
}