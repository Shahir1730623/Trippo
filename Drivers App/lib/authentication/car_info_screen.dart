import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/splashScreen/splash_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CarInfoScreen extends StatefulWidget
{

  @override
  _CarInfoScreenState createState() => _CarInfoScreenState();
}



class _CarInfoScreenState extends State<CarInfoScreen>
{
  TextEditingController carModelTextEditingController = TextEditingController();
  TextEditingController carNumberTextEditingController = TextEditingController();
  TextEditingController carColorTextEditingController = TextEditingController();

  List<String> carTypesList = ["UberX", "Uber Premier", "Bike"];
  String? selectedCarType;


  saveCarInfo()
  {
    Map driverCarInfoMap =
    {
      "carColor": carColorTextEditingController.text.trim(),
      "carModel": carModelTextEditingController.text.trim(),
      "carNumber": carNumberTextEditingController.text.trim(),
      "carType": selectedCarType,
    };

    DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("Drivers");
    driversRef.child(currentFirebaseUser!.uid).child("carDetails").set(driverCarInfoMap);

    Fluttertoast.showToast(msg: "Car Details has been saved");
    Navigator.pushNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [

              const SizedBox(height: 24,),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("images/Trippo Logo.png"),
              ),

              const SizedBox(height: 10,),

              const Text(
                "Write Car Details",
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),

              TextField(
                controller: carModelTextEditingController,
                style: const TextStyle(
                    color: Colors.black
                ),
                decoration: const InputDecoration(
                  labelText: "Car Model",
                  hintText: "Car Model",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
              ),

              const SizedBox(height: 20,),

              TextField(
                controller: carNumberTextEditingController,
                style: const TextStyle(
                    color: Colors.black
                ),
                decoration: const InputDecoration(
                  labelText: "Car Number",
                  hintText: "Car Number",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
              ),

              const SizedBox(height: 20,),

              TextField(
                controller: carColorTextEditingController,
                style: const TextStyle(
                    color: Colors.black
                ),
                decoration: const InputDecoration(
                  labelText: "Car Color",
                  hintText: "Car Color",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
              ),

              const SizedBox(height: 20,),

              DropdownButton(
                iconSize: 26,
                dropdownColor: Colors.white,
                hint: const Text(
                  "Please choose Car Type",
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                ),
                value: selectedCarType,
                onChanged: (newValue)
                {
                  setState(() {
                    selectedCarType = newValue.toString();
                  });
                },
                items: carTypesList.map((car){
                  return DropdownMenuItem(
                    child: Text(
                      car,
                      style: const TextStyle(color: Colors.black),
                    ),
                    value: car,
                  );
                }).toList(),
              ),

              const SizedBox(height: 20,),

              ElevatedButton(
                onPressed: ()
                {
                  if(carColorTextEditingController.text.isNotEmpty
                      && carNumberTextEditingController.text.isNotEmpty
                      && carModelTextEditingController.text.isNotEmpty && selectedCarType != null)
                  {
                    saveCarInfo();
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                ),
                child: const Text(
                  "Save Now",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
