import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetail {
  late String UserDetailID;
  final String UserID;
  final num UserHeight;
  final num UserWeight;
  final num UserR;
  final num UserCalo;
  final num UserBMI;
  final num UserFat;
  late String DateHistory;


  UserDetail(this.UserDetailID, this.UserID, this.UserHeight, this.UserWeight,
      this.UserR, this.UserCalo, this.UserBMI, this.UserFat, this.DateHistory);

  toJson() {
    return {
      "UserDetailID": UserDetailID,
      "UserID": UserID,
      "UserHeight": UserHeight,
      "UserWeight": UserWeight,
      "UserR": UserR,
      "UserCalo": UserCalo,
      "UserBMI": UserBMI,
      "UserFat": UserFat,
      "DateHistory": DateHistory,
    };
  }

  factory UserDetail.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    return UserDetail(
      data?['UserDetailID'] ?? '', // Set value thành mặc định nếu 'UserDetailID' null
      data?['UserID'] ?? '', // Set value thành mặc định nếu 'UserID' null
      data?['UserHeight'] ?? '', // Set value thành mặc định nếu 'UserHeight' null
      data?['UserWeight'] ?? '', // Set value thành mặc định nếu 'UserWeight' null
      data?['UserR'] ?? '', // Set value thành mặc định nếu 'UserR' null
      data?['UserCalo'] ?? '', // Set value thành mặc định nếu 'UserCalo' null
      data?['UserBMI'] ?? '', // Set value thành mặc định nếu 'UserBMI' null
      data?['UserFat'] ?? '', // Set value thành mặc định nếu 'UserFat' null
      data?['DateHistory'] ?? '', // Set value thành mặc định nếu 'DateHistory' null
    );
  }
}