import 'package:cloud_firestore/cloud_firestore.dart';

class Food_CRUD {
  final String FoodID;
  final String FoodCategoryID;
  final String FoodName;
  final num FoodCalo;
  final String FoodImage;


  Food_CRUD(this.FoodID, this.FoodCategoryID, this.FoodName, this.FoodCalo,
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

  factory Food_CRUD.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    return Food_CRUD(
      data?['FoodID'] ?? '', // Set value thành mặc định nếu 'FoodID' null
      data?['FoodCategoryID'] ?? '', // Set value thành mặc định nếu 'FoodCategoryID' null
      data?['FoodName'] ?? '', // Set value thành mặc định nếu 'FoodName' null
      data?['FoodCalo'] ?? 0, // Set value thành mặc định nếu 'FoodCalo' null
      data?['FoodImage'] ?? '', // Set value thành mặc định nếu 'FoodImage' null
    );
  }
}
