import 'package:cloud_firestore/cloud_firestore.dart';

class CustomExercise {
  final String CustomExerciseID;
  final String UserID;
  final String CustomExerciseName;
  final num CustomExerciseCalo;
  final num CustomExerciseDuration;
  final String DateHistory;


  CustomExercise(this.CustomExerciseID, this.UserID, this.CustomExerciseName,
      this.CustomExerciseCalo, this.CustomExerciseDuration, this.DateHistory);

  toJson() {
    return {
      "CustomExerciseID": CustomExerciseID,
      "UserID": UserID,
      "CustomExerciseName": CustomExerciseName,
      "CustomExerciseCalo": CustomExerciseCalo,
      "CustomExerciseDuration": CustomExerciseDuration,
      "DateHistory": DateHistory,
    };
  }

  factory CustomExercise.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    return CustomExercise(
      data?['CustomExerciseID'] ?? '',
      data?['UserID'] ?? '',
      data?['CustomExerciseName'] ?? '',
      data?['CustomExerciseCalo'] ?? 0,
      data?['CustomExerciseDuration'] ?? '',
      data?['DateHistory'] ?? '',
    );
  }
}