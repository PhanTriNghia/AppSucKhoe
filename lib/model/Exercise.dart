import 'package:cloud_firestore/cloud_firestore.dart';

class Exercise {
  final String ExerciseID;
  final String ExerciseCategoryID;
  final String ExerciseName;
  final num ExerciseCalo;
  final String ExerciseImage;
  final String ExerciseLink;


  Exercise(this.ExerciseID, this.ExerciseCategoryID, this.ExerciseName,
      this.ExerciseCalo, this.ExerciseImage, this.ExerciseLink);

  toJson() {
    return {
      "ExerciseID": ExerciseID,
      "ExerciseCategoryID": ExerciseCategoryID,
      "ExerciseName": ExerciseName,
      "ExerciseCalo": ExerciseCalo,
      "ExerciseImage": ExerciseImage,
      "ExerciseLink": ExerciseLink,
    };
  }

  factory Exercise.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    return Exercise(
      data?['ExerciseID'] ?? '',
      data?['ExerciseCategoryID'] ?? '',
      data?['ExerciseName'] ?? '',
      data?['ExerciseCalo'] ?? 0,
      data?['ExerciseImage'] ?? '',
      data?['ExerciseLink'] ?? '',
    );
  }
}