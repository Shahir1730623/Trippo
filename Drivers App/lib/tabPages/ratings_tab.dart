import 'package:drivers_app/global/global.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

import '../InfoHandler/app_info.dart';


class RatingsTabPage extends StatefulWidget {
  const RatingsTabPage({Key? key}) : super(key: key);

  @override
  _RatingsTabPageState createState() => _RatingsTabPageState();
}

class _RatingsTabPageState extends State<RatingsTabPage> {
  String titleStarRating = "";
  double driverRating = 0;

  @override
  void initState() {
    super.initState();
    getDriverRating();
  }

  void getDriverRating() {
    setState(() {
       driverRating =  double.parse(Provider.of<AppInfo>(context,listen: false).driverAverageRating);
    });

    setUpRatingTitle();
  }

  void setUpRatingTitle(){
    if(driverRating <= 1){
      setState(() {
        titleStarRating = "Inexperienced";
      });
    }

    else if(driverRating <= 2){
      setState(() {
        titleStarRating = "Bad";
      });
    }

    else if(driverRating <= 3){
      setState(() {
        titleStarRating = "Moderate";
      });
    }

    else if(driverRating <= 4){
      setState(() {
        titleStarRating = "Good";
      });
    }

    else if(driverRating <= 5){
      setState(() {
        titleStarRating = "Experienced";
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text(
          "Your Rating",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black
          ),
        ),

        leadingWidth: 50, // Keeps skip button in single line

        leading: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, "/main_screen");
          },

          style: ElevatedButton.styleFrom(
            primary: Colors.white
          ),

          child: Icon(
            Icons.arrow_back_outlined,
            color: Colors.redAccent,
          ),

        ),
      ),

      backgroundColor: Colors.white,

      body: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        backgroundColor: Colors.white,
        child: Container(
          margin: const EdgeInsets.all(8),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 5.0,),

              CircleAvatar(
                backgroundColor: Colors.white,
                child: Image.asset(
                  "images/Passport_Photo.png",
                ),
                radius: 60,
              ),

              const SizedBox(height: 20.0,),

              // Driver Name
              Text(
                driverData.name!,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                ),
              ),

              const SizedBox(height: 15.0,),

              const Center(
                child: Text(
                  "This is the average rating of your\ntotal trips",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),

              const SizedBox(height: 10.0,),

              SmoothStarRating(
                rating: driverRating,
                allowHalfRating: false,
                starCount: 5,
                color: Colors.orange,
                borderColor: Colors.orange,
                size: 40,
              ),

              const SizedBox(height: 10.0,),

              Text(
                "Rating: " + driverRating.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                )
              ),

              const SizedBox(height: 10.0),

              Text(
                "Driver Type: " + titleStarRating,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 15.0,),

            ],
          ),
        ),
      ),
    );
  }


}
