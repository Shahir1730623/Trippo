import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:users_app/models/trip_history_model.dart';

class HistoryDesignUI extends StatefulWidget {
  TripHistoryModel? tripHistoryModel;

  HistoryDesignUI({this.tripHistoryModel});

  @override
  State<HistoryDesignUI> createState() => _HistoryDesignUIState();
}

class _HistoryDesignUIState extends State<HistoryDesignUI> {

  String formatDateAndTime(String dateTimeFromDB){
    DateTime dateTime = DateTime.parse(dateTimeFromDB);
    String formattedDate = "${DateFormat.MMMd().format(dateTime)}, ${DateFormat.y().format(dateTime)} , ${DateFormat.jm().format(dateTime)}";
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30,vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("images/Map snippet new.png"),

            const SizedBox(height: 20),

            // Trip Date
            Text(
              formatDateAndTime(widget.tripHistoryModel!.time!),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black
              ),
            ),

            const SizedBox(height: 5),

            // Car details
            Text(
              widget.tripHistoryModel!.carModel! + " - " + widget.tripHistoryModel!.carNumber!,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[400]
              ),
            ),

            const SizedBox(height: 5),

            // " - "
            const Text(
              "-",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // Trip Distance
                Column(
                  children: [
                    const Text(
                      "Distance",
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      "1.5 KM",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 20),

                // Trip Duration
                Column(
                  children: [
                    const Text(
                      "Duration",
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      "30 mins",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 20),

                // Trip Fare
                Column(
                  children: [
                    const Text(
                      "Fare",
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      widget.tripHistoryModel!.fareAmount!,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                      ),
                    ),
                  ],
                ),
              ],

            ),

            const SizedBox(height: 2),

          ]
        )
      ),
    );
  }
}
