import 'package:firebase_database/firebase_database.dart';

class TripHistoryModel{
  String? time;
  String? sourceAddress;
  String? destinationAddress;
  String? fareAmount;
  String? status;

  TripHistoryModel({
    this.time,
    this.sourceAddress,
    this.destinationAddress,
    this.fareAmount,
    this.status
  });

  TripHistoryModel.fromSnapshot(DataSnapshot snapshot){
    time = (snapshot.value as Map)["time"].toString();
    sourceAddress = (snapshot.value as Map)["sourceAddress"].toString();
    destinationAddress = (snapshot.value as Map)["destinationAddress"].toString();
    fareAmount = (snapshot.value as Map)["fareAmount"].toString();
    status = (snapshot.value as Map)["status"].toString();
  }


}