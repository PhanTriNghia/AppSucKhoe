import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthylife/CRUD/model/food_crud.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'food_manager.dart';

class AddFood extends StatefulWidget {
  const AddFood({super.key});

  @override
  State<AddFood> createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {

  TextEditingController FoodIDController = TextEditingController();
  TextEditingController FoodCategoryIDController = TextEditingController();
  TextEditingController FoodNameController = TextEditingController();
  TextEditingController FoodCaloController = TextEditingController();

  String? selectedCategory;

  File? file;
  ImagePicker imagePicker = ImagePicker();
  var imageUrl;

  CollectionReference foodCol = FirebaseFirestore.instance.collection('Food');

  bool isTextFormFieldNotEmpty() {
    return FoodIDController.text.isNotEmpty &&
        FoodNameController.text.isNotEmpty &&
        FoodCaloController.text.isNotEmpty &&
        selectedCategory!.isNotEmpty;
  }

  getImage() async {
    var img = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      file = File(img!.path);
    });
  }

  Future<void> addFood() async {
    try {
      var imagefile = FirebaseStorage.instance
          .ref()
          .child("FoodImage")
          .child("/${FoodNameController.text}_${DateTime.now().day}${DateTime.now().month}${DateTime.now().year}${DateTime.now().second}${DateTime.now().microsecond}.jpg");
      UploadTask task = imagefile.putFile(file!);
      TaskSnapshot snapshot = await task;
      imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        imageUrl = imageUrl;
      });
      if(imageUrl != null) {
        // // Generate a unique ID for the new food
        // String uid = foodCol.doc().id;

        // Create food object with the entered values
        Food_CRUD food = Food_CRUD(
          FoodIDController.text,
          selectedCategory!,
          FoodNameController.text,
          num.tryParse(FoodCaloController.text) ?? 0,
          imageUrl,
        );

        // Add food to Cloud Firestore
        await foodCol.doc(FoodIDController.text).set(food.toJson())
            .then((value) {
          print("Food Added\nUID:${FoodIDController.text}");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FoodManager()),
          );
        })
            .catchError((error) => print("Failed to add food: $error"));

      }
    } on Exception catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          color: Colors.white,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Thêm thức ăn',
          style: GoogleFonts.getFont(
            'Montserrat',
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF073484),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.height * 0.03,
              vertical: MediaQuery.of(context).size.width * 0.05),
          child: Column(
            children: [
              Center(
                child: Container(
                    height: 200,
                    width: 200,
                    child: file == null
                        ? IconButton(
                      icon: const Icon(
                        Icons.add_a_photo,
                        size: 90,
                        color: Color(0xFF758467),
                      ),
                      onPressed: () {
                        getImage();
                      },
                    )
                        : MaterialButton(
                      height: 100,
                      child: Image.file(
                        file!,
                        fit: BoxFit.fill,
                      ),
                      onPressed: () {
                        getImage();
                      },
                    )),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              TextFormField(
                controller: FoodIDController,
                obscureText: false,
                decoration: InputDecoration(
                  labelText: 'Food ID',
                  labelStyle: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 13),
                  hintText: 'Nhập Food ID theo "Food1", "Food2", "Food3",...',
                  hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 13),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                  const EdgeInsetsDirectional.fromSTEB(16, 16, 0, 16),
                ),
              ),


              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              // TextFormField(
              //   controller: FoodCategoryIDController,
              //   obscureText: false,
              //   decoration: InputDecoration(
              //     labelText: 'Food Category ID',
              //     labelStyle: const TextStyle(
              //         color: Colors.grey,
              //         fontWeight: FontWeight.w500,
              //         fontSize: 13),
              //     hintText: '"FoodCategory1", "FoodCategory2",...',
              //     hintStyle: const TextStyle(
              //         color: Colors.grey,
              //         fontWeight: FontWeight.w500,
              //         fontSize: 13),
              //     enabledBorder: OutlineInputBorder(
              //       borderSide: const BorderSide(
              //         color: Colors.grey,
              //         width: 2,
              //       ),
              //       borderRadius: BorderRadius.circular(8),
              //     ),
              //     focusedBorder: OutlineInputBorder(
              //       borderSide: const BorderSide(
              //         color: Colors.grey,
              //         width: 2,
              //       ),
              //       borderRadius: BorderRadius.circular(8),
              //     ),
              //     filled: true,
              //     fillColor: Colors.white,
              //     contentPadding:
              //     const EdgeInsetsDirectional.fromSTEB(16, 16, 0, 16),
              //   ),
              // ),

              DropdownButtonFormField<String>(
                value: selectedCategory,
                onChanged: (String? value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Food Category',
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsetsDirectional.fromSTEB(16, 16, 0, 16),
                ),
                items: <String>[
                  'FoodCategory1',
                  'FoodCategory2',
                  'FoodCategory3',
                  'FoodCategory4',
                  'FoodCategory5',
                  'FoodCategory6',
                  'FoodCategory7',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),

              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              TextFormField(
                controller: FoodNameController,
                obscureText: false,
                decoration: InputDecoration(
                  labelText: 'Food Name',
                  labelStyle: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 13),
                  hintText: '"Thịt heo", "Cá hồi basa", "Trứng gà đất",...',
                  hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 13),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                  const EdgeInsetsDirectional.fromSTEB(16, 16, 0, 16),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              TextFormField(
                controller: FoodCaloController,
                keyboardType: TextInputType.number,
                obscureText: false,
                decoration: InputDecoration(
                  labelText: 'Food Calo',
                  labelStyle: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 13),
                  hintText: '70.5, 80, 95.5,...',
                  hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 13),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                  const EdgeInsetsDirectional.fromSTEB(16, 16, 0, 16),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.height * 0.075,
                ),
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.02,
                  bottom: MediaQuery.of(context).size.height * 0.05,
                ),
                decoration: BoxDecoration(
                    color: Color(0xFFEE6823),
                    borderRadius: BorderRadius.circular(30.0)),
                child: TextButton(
                  //Tắt hiệu ứng splash khi click button
                  style: TextButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                  ),
                  child: Text(
                    'THÊM',
                    style: GoogleFonts.getFont(
                      'Montserrat',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  onPressed: () {
                    if (isTextFormFieldNotEmpty()) {
                      print('hello');
                      addFood();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.info, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Vui lòng điền đầy đủ thông tin',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          backgroundColor: Color(0xFF073484),
                          duration: const Duration(seconds: 3),
                          action: SnackBarAction(
                            label: 'Đóng',
                            onPressed: () {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                            },
                            textColor: Colors.white,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
