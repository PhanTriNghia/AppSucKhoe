import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/Exercise.dart';
import '../../util/color_theme.dart';

class HomeExerciseWidget extends StatefulWidget {
  const HomeExerciseWidget({super.key});

  @override
  State<HomeExerciseWidget> createState() => _HomeExerciseWidgetState();
}

class _HomeExerciseWidgetState extends State<HomeExerciseWidget> {

  late List<Exercise> exercises = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    await getExercise();

    await getRandomExercise();

    setState(() {
      isLoading = false;
    });
  }

  // hàm lấy dữ liệu Exercise từ firebase
  Future<void> getExercise() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Exercise')
        .get();
    setState(() {
      exercises =
          querySnapshot.docs.map((doc) => Exercise.fromFirestore(doc)).toList();
    });
  }

  Exercise? getRandomExercise() {
    if (exercises.isEmpty) {
      return null; // Return null if the list is empty
    }
    final randomIndex = Random().nextInt(exercises.length);
    return exercises[randomIndex];
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? Center(
      child: Text(
        "Đang tải dữ liệu, vui lòng chờ trong giây lát",
        style: GoogleFonts.getFont('Montserrat',
            fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    ) : InkWell(
      onTap: () {
        final Uri _url = Uri.parse(getRandomExercise()!.ExerciseLink);
        launchUrl(_url);
      },
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery
                          .of(context)
                          .size
                          .width * 0.01,
                      vertical: MediaQuery
                          .of(context)
                          .size
                          .height * 0.005,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                        getRandomExercise()!.ExerciseImage ?? "",
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.01,),
                  Text(
                    getRandomExercise()!.ExerciseName ?? "",
                    style: GoogleFonts.getFont('Montserrat',
                        fontSize: 14, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "Tiêu hao ${getRandomExercise()!.ExerciseCalo} calo",
                    style: GoogleFonts.getFont(
                      'Montserrat',
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                ],
              ),
            ),
          )),
    );
  }
}
