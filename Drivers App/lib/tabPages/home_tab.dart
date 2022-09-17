import 'dart:async';
import 'dart:ffi';
import 'package:drivers_app/assistants/assistant_methods.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/main.dart';
import 'package:drivers_app/push_notifications/push_notifications_system.dart';
import 'package:drivers_app/splashScreen/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class HomeTabPage extends StatefulWidget {
  const HomeTabPage({Key? key}) : super(key: key);

  @override
  _HomeTabPageState createState() => _HomeTabPageState();
}


class _HomeTabPageState extends State<HomeTabPage> {
  GoogleMapController? newMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  var geoLocator = Geolocator();
  LocationPermission? _locationPermission;



  checkIfLocationPermissionAllowed() async
  {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  // Get Current Location of the driver
  locateDriverPosition() async{
    driverCurrentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    LatLng latLngPosition = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

    CameraPosition cameraPosition = CameraPosition(target:latLngPosition, zoom: 16);
    newMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    //userName = currentUserInfo!.name!;
    String humanReadableAddress = await AssistantMethods.searchAddressForGeographicCoordinates(driverCurrentPosition!,context);
    print("this is your address = " + humanReadableAddress);
  }

  // Enable Push Notifications
  readCurrentDriverInformation() async {
    currentFirebaseUser = firebaseAuth.currentUser;

    await FirebaseDatabase.instance.ref()
        .child("Drivers")
        .child(currentFirebaseUser!.uid)
        .once()
        .then((snapData) {
         DataSnapshot snapshot = snapData.snapshot;
         if(snapshot.exists){
           driverData.id = (snapshot.value as Map)["id"];
           driverData.name = (snapshot.value as Map)["name"];
           driverData.email = (snapshot.value as Map)["email"];
           driverData.phone = (snapshot.value as Map)["phone"];
           driverData.carColor = (snapshot.value as Map)["carDetails"]["carColor"];
           driverData.carModel = (snapshot.value as Map)["carDetails"]["carModel"];
           driverData.carNumber = (snapshot.value as Map)["carDetails"]["carNumber"];
           driverData.carType = (snapshot.value as Map)["carDetails"]["carType"];
           driverData.lastTripId = (snapshot.value as Map)["lastTripId"];
           driverData.totalEarnings = (snapshot.value as Map)["totalEarnings"];
         }

    });

    AssistantMethods.getLastTripInformation(context);

    //currentFirebaseUser = firebaseAuth.currentUser;
    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging(context);
    pushNotificationSystem.generateRegistrationToken();

    // Get Driver Ratings
    AssistantMethods.getDriverRating(context);
  }

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
    readCurrentDriverInformation();
    AssistantMethods.readRideRequestKeys(context);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          myLocationEnabled: true,
          zoomControlsEnabled: true,
          zoomGesturesEnabled: true,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);
            newMapController = controller;
            locateDriverPosition();
          },
        ),

        statusText != "Online"
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                color: Colors.black54,
              )
            : Container(),

        Positioned(
          top: statusText != "Online"
              ? MediaQuery.of(context).size.height * 0.46
              : 35,
          left: 0,
          right: 0,

          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: (){
                  if(statusText != "Online"){ // Offline
                    driverIsOnlineNow();
                    updateDriversLocationAtRealTime();

                    setState(() {
                      statusText = "Online";
                      isDriverActive = true;
                      buttonColor = Colors.black;
                    });

                    Fluttertoast.showToast(msg: "You are online now");
                  }

                  else{
                    driverIsOfflineNow();
                    setState(() {
                      statusText = "Offline";
                      isDriverActive = false;
                      buttonColor = Colors.black;
                    });

                    Fluttertoast.showToast(msg: "You are offline now");
                  }

                },

                style: ElevatedButton.styleFrom(
                  primary: buttonColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32,vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26)
                  )
                ),

                child: statusText != "Online"
                    ? Text(
                        statusText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      )
                    : const Icon(
                       Icons.phonelink_ring,
                       color: Colors.white,
                       size: 30,
                      )
              )
            ],
          ),
        )
      ],
    );
  }

  driverIsOnlineNow() async{
    driverCurrentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    
    Geofire.initialize("ActiveDrivers"); // Setting up a new node in realtime database
    Geofire.setLocation(currentFirebaseUser!.uid, driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
    
    DatabaseReference reference = FirebaseDatabase.instance.ref()
        .child("Drivers").child(currentFirebaseUser!.uid).child("newRideStatus");

    reference.set("Idle");
    reference.onValue.listen((event) { });


  }

  driverIsOfflineNow() async{
    Geofire.removeLocation(currentFirebaseUser!.uid); // ActiveDrivers child with this id deleted from Realtime Firebase

    DatabaseReference? reference = FirebaseDatabase.instance.ref()
        .child("Drivers").child(currentFirebaseUser!.uid).child("newRideStatus");

    reference.onDisconnect();
    reference.remove(); // child newRideStatus removed
    reference = null;

  }

  updateDriversLocationAtRealTime()
  {
    streamSubscriptionPosition = Geolocator.getPositionStream() // Get Updated position of the driver
        .listen((Position position)
    {
      driverCurrentPosition = position;

      if(isDriverActive == true)
      {
        Geofire.setLocation  // Updating live location in realtime database
        (
            currentFirebaseUser!.uid,
            driverCurrentPosition!.latitude,
            driverCurrentPosition!.longitude
        );
      }

      LatLng latLng = LatLng(
        driverCurrentPosition!.latitude,
        driverCurrentPosition!.longitude,
      );

      newMapController!.animateCamera(CameraUpdate.newLatLng(latLng)); // Animating camera in google map according to LatLng
    });
  }


}
