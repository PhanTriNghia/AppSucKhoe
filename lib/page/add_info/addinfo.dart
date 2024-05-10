
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:healthylife/model/UserHealthy.dart';
import 'package:healthylife/page/account/login.dart';
import 'package:healthylife/util/snack_bar_error_mess.dart';
import 'package:healthylife/widget/home/home_bottom_navigation.dart';
import 'package:intl/intl.dart';
import '../../util/color_theme.dart';
import '../auth.dart';
import '../intensity/exercise_intensity.dart';


class AddInfo extends StatefulWidget{
  const AddInfo({Key? key}) : super(key: key);

  @override
  State<AddInfo> createState() => _AddInforState();
}

class _AddInforState extends State<AddInfo>{
  final User? user = Auth().currentUser;
  final TextEditingController nameController = TextEditingController();
  String _name = '';
  bool isSelected = true;
  String selectedGender = '';
  bool _state_1 = false;   // trạng thái của date
  bool _state_2 = false;   // trạng thái của weight
  bool _state_3 = false;   // trạng thái của height
  DateTime? _selectedDate = DateTime.now();
  int? _selectedWeight = 50;
  int? _selectedHeight = 170;
  String? userID;
  String? userDetailID;

  // Dialog Name
  Future<void> _showNameDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade50,
          //insetPadding: EdgeInsets.symmetric(horizontal: 50),
          title: const Text('Tên',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextFormField(
            controller: nameController,
            autofocus: true,
            onChanged: (value) {
              setState(() {
                _name = value;
              });
            },
            decoration: InputDecoration(
                filled: true,
                hintText: 'Nhập tên',
                hintStyle: TextStyle(
                  fontSize: 14,
                ),
                fillColor: Colors.grey.shade50,
                border: const OutlineInputBorder(
                    borderSide: BorderSide.none
                ),
                contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child:  ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.grey.shade50),
                        foregroundColor: MaterialStateProperty.all(Colors.black)
                      ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Hủy',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                    ),
                ),
                const SizedBox(width: 8,),
                Expanded(
                  child:  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.blueAccent.shade100),
                        foregroundColor: MaterialStateProperty.all(Colors.white)
                    ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Xác nhận',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ),
                ),
              ],
            ),
          ],
          // elevation: 24.0,
        );
      },
    );
  }
  Future<void> _showDatePickerDialog(BuildContext context) async {
     DateTime? picked;
     picked = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height * 0.4,
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Expanded(
                      child: Center(
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(26, 0, 0, 0),
                          child: Text('Sinh nhật',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.close),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: const Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  backgroundColor: Colors.white,
                  minimumYear: 1950,
                  maximumYear: DateTime.now().year,
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _selectedDate,
                  onDateTimeChanged: (DateTime? newDate) {
                    // setState(() {
                      picked = newDate;
                      _state_1 = true;
                    //});
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: const Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    foregroundColor: MaterialStateProperty.all(Colors.black),
                  ),
                  child: Text('Xác nhận'),
                  onPressed: () {
                    Navigator.of(context).pop(picked);  // Truyền giá trị ngày đã chọn
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
     // Kiểm tra nếu người dùng chọn ngày và xác nhận thì mới cập nhật lại ngày
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  Future<void> _showWeightPickerDialog(BuildContext context) async {
    int? picked;
    picked = await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height * 0.4,
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(32, 0, 0, 0),
                          child: Text('Cân nặng',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 32,
                    scrollController: FixedExtentScrollController(initialItem: _selectedWeight! - 1),  // Gía trị mặc định là 50
                    onSelectedItemChanged: (int index){
                      setState(() {
                        picked = index + 1;
                        _state_2 = true;
                      });
                    },
                    children: List.generate(300, (index){
                      return Center(
                        child: Text(
                          (index + 1).toString() + ' ' + 'kg',
                          style: TextStyle(fontSize: 25),
                        ),
                      );
                    },
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      foregroundColor: MaterialStateProperty.all(Colors.black),
                    ),
                    child: Text('Xác nhận'),
                    onPressed: () {
                      Navigator.of(context).pop(picked);  // Truyền giá trị ngày đã chọn
                    },
                  ),
                ),
              ],
            ),
          );
        },
    );
    if (picked != null && picked != _selectedWeight) {
      setState(() {
        _selectedWeight = picked;
      });
    }
  }
  Future<void> _showHeightPickerDialog(BuildContext context) async {
    int? picked;
    picked = await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height * 0.4,
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(32, 0, 0, 0),
                        child: Text('Chiều cao',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: const Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32,
                  scrollController: FixedExtentScrollController(initialItem: _selectedHeight! - 80),  // Gía trị mặc định là 170
                  onSelectedItemChanged: (int index){
                    setState(() {
                      picked = index + 80;
                      _state_3 = true;
                    });
                  },
                  children: List.generate(171, (index){
                    return Center(
                      child: Text(
                        (index + 80).toString() + ' ' + 'cm',
                        style: TextStyle(fontSize: 25),
                      ),
                    );
                  },
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: const Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    foregroundColor: MaterialStateProperty.all(Colors.black),
                  ),
                  child: Text('Xác nhận'),
                  onPressed: () {
                    Navigator.of(context).pop(picked);  // Truyền giá trị ngày đã chọn
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
    if (picked != null && picked != _selectedHeight) {
      setState(() {
        _selectedHeight = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        // padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
        children: [
          Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Image.asset('assets/images/bubble_abstract.jpg',
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Positioned(
              //   top: MediaQuery.of(context).size.height * 0.03,
              //   child: IconButton(
              //     icon: Icon(Icons.arrow_back_ios),
              //     onPressed: () {
              //       Navigator.pop(context);
              //       //Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginPage()));
              //     },
              //   ),
              // ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.08,
                left: MediaQuery.of(context).size.width * 0.05,
                child:
                Text('Nhập thông tin',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.13,
                left: MediaQuery.of(context).size.width * 0.05,
                right: MediaQuery.of(context).size.width * 0,
                child:
                Text('Vui lòng nhập thông tin chính xác để có báo cáo dữ liệu chính xác',
                  style: TextStyle(
                      fontSize: 16
                  ),
                ),
              ),
              Positioned(
                  top: MediaQuery.of(context).size.height * 0.2,
                  child:ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                        padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Giới tính',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.018
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isSelected = !isSelected;
                                      //selectedGender = "Nam";
                                    });
                                  },
                                  child: Column(
                                    children: [
                                    ColorFiltered(
                                      colorFilter: isSelected
                                          ? const ColorFilter.mode(
                                              Colors.transparent, BlendMode.color)
                                          :const ColorFilter.mode(
                                          Colors.white54, BlendMode.modulate),
                                      child: Image.asset(
                                        'assets/images/man.png',
                                        height: MediaQuery.of(context).size.height * 0.14,
                                        width: MediaQuery.of(context).size.width * 0.23,
                                      ),
                                    ),
                                      SizedBox(
                                          height: MediaQuery.of(context).size.height * 0.01
                                      ),
                                      Text('Nam',
                                        style: TextStyle(
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isSelected = !isSelected;
                                      //selectedGender = "Nữ";
                                    });
                                  },
                                  child: Column(
                                    children: [
                                      ColorFiltered(
                                        colorFilter: !isSelected
                                            ? const ColorFilter.mode(
                                            Colors.transparent, BlendMode.color)
                                            :const ColorFilter.mode(
                                            Colors.white54, BlendMode.modulate),
                                        child: Image.asset(
                                          'assets/images/woman.png',
                                          height: MediaQuery.of(context).size.height * 0.14,
                                          width: MediaQuery.of(context).size.width * 0.23,
                                        ),
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context).size.height * 0.01
                                      ),
                                      Text('Nữ',
                                        style: TextStyle(
                                          fontWeight: !isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height * 0.018
                            ),
                            const Text('Tên',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height * 0.018
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Colors.grey.shade50),
                                  side: MaterialStateProperty.all(BorderSide(
                                      width: 1,
                                      color: _name.isEmpty ? Colors.grey : Colors.black)),
                                  padding: MaterialStateProperty.all(EdgeInsets.all(12)),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showNameDialog(context);
                                  });
                                },
                                child: Text(_name.isEmpty
                                    ? 'Nhập tên'
                                    : '$_name',
                                  style: TextStyle(
                                    color: _name.isEmpty ? Colors.grey : Colors.black
                                  ),
                                ),
                              ), 
                            ),

                            SizedBox(
                                height: MediaQuery.of(context).size.height * 0.018
                            ),
                            const Text('Sinh nhật',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height * 0.018
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Colors.grey.shade50),
                                  foregroundColor: MaterialStateProperty.all(_state_1 ? Colors.black : Colors.grey),
                                  side: MaterialStateProperty.all(BorderSide(
                                      width: 1,
                                      color: _state_1 ? Colors.black : Colors.grey)),
                                  padding: MaterialStateProperty.all(EdgeInsets.all(12)),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showDatePickerDialog(context);
                                  });
                                },
                                child: Text('${DateFormat('dd-MM-yyyy').format(_selectedDate!)}'),
                                ),
                              ),

                            SizedBox(
                                height: MediaQuery.of(context).size.height * 0.018
                            ),
                            const Text('Cân nặng',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height * 0.018
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Colors.grey.shade50),
                                  foregroundColor: MaterialStateProperty.all(_state_2 ? Colors.black : Colors.grey),
                                  side: MaterialStateProperty.all(BorderSide(
                                      width: 1,
                                      color: _state_2 ? Colors.black : Colors.grey)),
                                  padding: MaterialStateProperty.all(EdgeInsets.all(12)),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showWeightPickerDialog(context);
                                    //_showDatePickerDialog(context);
                                  });
                                },
                                child: Text('${_selectedWeight}' + ' ' + 'kg',
                                ),
                              ),
                            ),

                            SizedBox(
                                height: MediaQuery.of(context).size.height * 0.018
                            ),
                            const Text('Chiều cao',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height * 0.018
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Colors.grey.shade50),
                                  foregroundColor: MaterialStateProperty.all(_state_3 ? Colors.black : Colors.grey),
                                  side: MaterialStateProperty.all(BorderSide(
                                      width: 1,
                                      color: _state_3 ? Colors.black : Colors.grey)),
                                  padding: MaterialStateProperty.all(EdgeInsets.all(12)),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showHeightPickerDialog(context);
                                  });
                                },
                                child: Text('${_selectedHeight}' + ' ' + 'cm',
                                ),
                              ),
                            ),
                          ],
                        )
                    ),
                  )
              ),
            ],
          ),
        ],
      ),
    bottomNavigationBar: BottomAppBar(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.fromLTRB(18, 4, 18, 4),
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(ColorTheme.backgroundColor),
            foregroundColor: MaterialStateProperty.all(Colors.white)
          ),
          onPressed: () async {
            // Auth().signOut();
            // Navigator.pop(context);
            String name = nameController.text.trim();
            String email = user!.email ?? "";
            String? credential;
            String birthday = DateFormat('dd/MM/yyyy').format(_selectedDate!);
            String dateHistory = DateFormat('dd/MM/yyyy').format(DateTime.now());
            int age = DateTime.now().year - _selectedDate!.year;
            print('Age: $age');
            int? weight = _selectedWeight;
            int? height = _selectedHeight;
            double? bmi = weight!/((height!/100*height/100));
            double fat;
            double bmr;
            if(isSelected == true){
              selectedGender = "Nam";
               fat = 1.2 * bmi + 0.23 * age - 5.4 - 10.8;
               bmr = 66 + (13.7 * _selectedWeight!) + (5 * _selectedHeight!) - (6.8 * age);
            } else{
              selectedGender = "Nữ";
              fat = 1.2 * bmi + 0.23 * age - 5.4;
              bmr = 655 + (9.6 * _selectedWeight!) + (1.8 * _selectedHeight!) - (4.7 * age);
            }
            if(email.isNotEmpty){
              credential = email;
              await saveUser(name, credential, birthday, selectedGender);
            } else{
              credential = user?.phoneNumber;
              await saveUser(name, credential!, birthday, selectedGender);
            }
            //saveUser(name, email!, birthday, selectedGender);
            await saveUserDetail(weight, height, bmi, fat, dateHistory);

            Navigator.push(context, MaterialPageRoute(builder: (context) => ExcerciseIntensity(
                userHealthy: UserHealthy(userID!, credential!, selectedGender, name, birthday),
                userDetailID: userDetailID,
                bmr: bmr,
            )));
            },
          child: Text('Xác nhận',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    )
    );
  }

  Future<void> saveUser(String name, String credential, String birthday, String gender) async {
    await FirebaseFirestore.instance
        .collection('User')
        .add({'UserName': name, 'UserCredential': credential, 'UserBirthday': birthday, 'UserGender': gender})
        .then((DocumentReference docRef) {
          // lấy id vừa tạo
      setState(() {
        userID = docRef.id;
      });
          //Lưu vào UserID
          docRef.update({'UserID' : userID});
          //return userID;
    });


  }

  Future<void> saveUserDetail(int weight, int height, double bmi, double fat, String dateHistory) async {
    await FirebaseFirestore.instance
        .collection('UserDetail')
        .add({'UserWeight': weight, 'UserHeight': height, 'UserBMI': bmi, 'UserFat': fat, 'DateHistory': dateHistory})
        .then((DocumentReference docRef){
           setState(() {
             userDetailID = docRef.id;
           });
          docRef.update({'UserDetailID': userDetailID, 'UserID': userID});
    });
  }
}