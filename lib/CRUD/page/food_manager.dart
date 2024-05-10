import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthylife/CRUD/model/food_crud.dart';
import 'package:healthylife/CRUD/page/add_food.dart';

class FoodManager extends StatefulWidget {
  const FoodManager({super.key});

  @override
  State<FoodManager> createState() => _FoodManagerState();
}

class _FoodManagerState extends State<FoodManager> {

  CollectionReference busCol = FirebaseFirestore.instance.collection('Food');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchFoodData();
  }

  Future<List<Food_CRUD>> fetchFoodData() async {
    QuerySnapshot busSnapshot = await busCol.get();
    return busSnapshot.docs.map((DocumentSnapshot doc) => Food_CRUD.fromFirestore(doc)).toList();
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
          'Quản lý thức ăn',
          style: GoogleFonts.getFont(
            'Montserrat',
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          // Add button in the AppBar
          IconButton(
            icon: Icon(Icons.add),color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddFood()),
              );
            },
          ),
        ],
        backgroundColor: const Color(0xFF073484),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Implement your refresh logic here
          await Future.delayed(Duration(seconds: 1)); // Simulating a delay, replace with your actual refresh logic
          setState(() {}); // Trigger a rebuild
        },
        child: FutureBuilder<List<Food_CRUD>>(
          future: fetchFoodData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                List<Food_CRUD> foodList = snapshot.data!;
                return ListView.builder(
                  itemCount: foodList.length,
                  itemBuilder: (context, index) {
                    Food_CRUD food = foodList[index];
                    return ListTile(
                      leading: Image.network(food.FoodImage,),
                      title: Text(food.FoodName),
                      subtitle: Text('Calo: ${food.FoodCalo.toDouble()}'),
                      onTap: () {
                        // Handle tap on a bus item (e.g., navigate to details screen)
                      },
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Lỗi: ${snapshot.error.toString()}',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }
            }

            // Loading indicator while fetching data
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
