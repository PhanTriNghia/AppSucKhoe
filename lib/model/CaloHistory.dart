import 'package:cloud_firestore/cloud_firestore.dart';

class CaloHistory {
  final String CaloHistoryID;
  final String UserID;
  final String DateHistory;
  final List<FoodDetailHistory> foodDetailHistory;
  final List<ExerciseDetailHistory> exerciseDetailHistory;

  CaloHistory(
      this.CaloHistoryID, this.UserID, this.DateHistory, this.foodDetailHistory, this.exerciseDetailHistory);

  toJson() {
    return {
      "CaloHistoryID": CaloHistoryID,
      "UserID": UserID,
      "DateHistory": DateHistory,
      "FoodDetailHistory": foodDetailHistory.map((detail) => detail.toJson()).toList(),
      "ExerciseDetailHistory": exerciseDetailHistory.map((detail) => detail.toJson()).toList(),
    };
  }

  factory CaloHistory.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
    List<FoodDetailHistory> foodDetailHistoryList = [];
    if (data?['FoodDetailHistory'] != null) {
      var list = data?['FoodDetailHistory'] as List;
      foodDetailHistoryList = list.map((item) => FoodDetailHistory.fromFirestore(item)).toList();
    }

    List<ExerciseDetailHistory> exerciseDetailHistoryList = [];
    if (data?['ExerciseDetailHistory'] != null) {
      var list = data?['ExerciseDetailHistory'] as List;
      exerciseDetailHistoryList = list.map((item) => ExerciseDetailHistory.fromFirestore(item)).toList();
    }

    return CaloHistory(
      data?['CaloHistoryID'] ?? '',
      data?['UserID'] ?? '',
      data?['DateHistory'] ?? '',
      foodDetailHistoryList,
      exerciseDetailHistoryList,
    );
  }
}

class FoodDetailHistory {
  final String FoodID;
  final num NetWeight;

  FoodDetailHistory(this.FoodID, this.NetWeight);

  toJson() {
    return {
      "FoodID": FoodID,
      "NetWeight": NetWeight,
    };
  }

  factory FoodDetailHistory.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    return FoodDetailHistory(
      data?['FoodID'] ?? '', // Set value thành mặc định nếu 'FoodID' null
      data?['NetWeight'] ?? 0, // Set value thành mặc định nếu 'NetWeight' null
    );
  }
}

class ExerciseDetailHistory {
  final String ExerciseID;
  final num Duration;

  ExerciseDetailHistory(this.ExerciseID, this.Duration);

  toJson() {
    return {
      "ExerciseID": ExerciseID,
      "Duration": Duration,
    };
  }

  factory ExerciseDetailHistory.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    return ExerciseDetailHistory(
      data?['ExerciseID'] ?? '', // Set value thành mặc định nếu 'ExerciseID' null
      data?['Duration'] ?? 0, // Set value thành mặc định nếu 'Duration' null
    );
  }
}