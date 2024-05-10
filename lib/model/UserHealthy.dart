import 'package:cloud_firestore/cloud_firestore.dart';

class UserHealthy {
  final String UserID;
  final String UserCredential;
  final String UserGender;
  final String UserName;
  final String UserBirthday;

  UserHealthy(this.UserID, this.UserCredential, this.UserGender, this.UserName,
      this.UserBirthday);

  toJson() {
    return {
      "UserID": UserID,
      "UserCredential": UserCredential,
      "UserGender": UserGender,
      "UserName": UserName,
      "UserBirthday": UserBirthday,
    };
  }

  factory UserHealthy.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    return UserHealthy(
      data?['UserID'] ?? '', // Set value thành mặc định nếu 'UserID' null
      data?['UserCredential'] ?? '', // Set value thành mặc định nếu 'UserCredential' null
      data?['UserGender'] ?? '', // Set value thành mặc định nếu 'UserGender' null
      data?['UserName'] ?? '', // Set value thành mặc định nếu 'UserName' null
      data?['UserBirthday'] ?? '', // Set value thành mặc định nếu 'UserBirthday' null
    );
  }
}