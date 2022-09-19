import 'package:flutter/widgets.dart';
import 'package:users_app/models/trip_history_model.dart';
import '../models/directions.dart';

class AppInfo extends ChangeNotifier{
  Directions? userPickupLocation,userDropOffLocation;
  int? countTotalTrips;
  List<String> historyTripsKeyList = [];
  List<TripHistoryModel> historyInformationList = [];

  void updatePickupLocationAddress(Directions userPickupAddress){
    userPickupLocation = userPickupAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Directions userDropOffAddress){
    userDropOffLocation = userDropOffAddress;
    notifyListeners();
  }

  // Will be used in later part of the app through provider
  void updateTotalTrips(int totalTripsCount){
    countTotalTrips = totalTripsCount;
    notifyListeners();
  }

  void updateTotalTripsList(List<String> rideRequestKeyList) {
    historyTripsKeyList = rideRequestKeyList;
    notifyListeners();
  }

  void updateTotalHistoryInformation(TripHistoryModel eachTripHistoryInformation) {
    historyInformationList.add(eachTripHistoryInformation);
    notifyListeners();
  }

}