import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseCategory {
  final String ExerciseCategoryID;
  final String ExerciseCategoryName;

  ExerciseCategory(this.ExerciseCategoryID, this.ExerciseCategoryName);

  toJson() {
    return {
      "ExerciseCategoryID": ExerciseCategoryID,
      "ExerciseCategoryName": ExerciseCategoryName,
    };
  }

  factory ExerciseCategory.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    return ExerciseCategory(
      data?['ExerciseCategoryID'] ?? '',
      data?['ExerciseCategoryName'] ?? '',
    );
  }
}