import 'package:firebase_database/firebase_database.dart';

class TripHistoryModel{
  String? time;
  String? sourceAddress;
  String? destinationAddress;
  String? carNumber;
  String? carModel;
  String? driverName;
  String? fareAmount;
  String? status;

  TripHistoryModel({
    this.time,
    this.sourceAddress,
    this.destinationAddress,
    this.carNumber,
    this.carModel,
    this.driverName,
    this.fareAmount,
    this.status
  });

  TripHistoryModel.fromSnapshot(DataSnapshot snapshot){
    time = (snapshot.value as Map)["time"].toString();
    sourceAddress = (snapshot.value as Map)["sourceAddress"].toString();
    destinationAddress = (snapshot.value as Map)["destinationAddress"].toString();
    carNumber = (snapshot.value as Map)["carDetails"]["carNumber"].toString();
    carModel = (snapshot.value as Map)["carDetails"]["carModel"].toString();
    driverName = (snapshot.value as Map)["driverName"].toString();
    fareAmount = (snapshot.value as Map)["fareAmount"].toString();
    status = (snapshot.value as Map)["status"].toString();
  }


}