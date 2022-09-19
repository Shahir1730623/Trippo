import 'package:users_app/models/active_nearby_available_drivers.dart';

class GeoFireAssistant{

  static List<ActiveNearbyAvailableDrivers> activeNearbyAvailableDriversList = [];

  static void deleteOfflineDriverFromList(String driverId){
    int index = activeNearbyAvailableDriversList.indexWhere((element) => element.driverId  == driverId);
    activeNearbyAvailableDriversList.removeAt(index);
  }

  static void updateActiveNearbyAvailableDriverLocation(ActiveNearbyAvailableDrivers driverWhoMoves){
    int index = activeNearbyAvailableDriversList.indexWhere((element) => element.driverId  == driverWhoMoves.driverId);

    activeNearbyAvailableDriversList[index].locationLatitude = driverWhoMoves.locationLatitude;
    activeNearbyAvailableDriversList[index].locationLongitude = driverWhoMoves.locationLongitude;
  }

}