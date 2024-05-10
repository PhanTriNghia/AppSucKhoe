import 'package:cloud_firestore/cloud_firestore.dart';

class WaterHistory {
  final String WaterHistoryID;
  final String UserID;
  final String DateHistory;
  final num Capacity;

  WaterHistory(
      this.WaterHistoryID, this.UserID, this.DateHistory, this.Capacity);

  toJson() {
    return {
      "WaterHistoryID": WaterHistoryID,
      "UserID": UserID,
      "DateHistory": DateHistory,
      "Capacity": Capacity,
    };
  }

  factory WaterHistory.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    return WaterHistory(
      data?['WaterHistoryID'] ?? '',
      data?['UserID'] ?? '',
      data?['DateHistory'] ?? '',
      data?['Capacity'] ?? '',
    );
  }
}