import 'dart:async';
import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:users_app/assistants/Geofire_assistant.dart';
import 'package:users_app/global/global.dart';
import 'package:users_app/mainScreens/rate_driver_screen.dart';
import 'package:users_app/mainScreens/select_active_driver_screen.dart';
import 'package:users_app/models/active_nearby_available_drivers.dart';
import 'package:users_app/models/direction_details_info.dart';
import 'package:users_app/models/directions.dart';
import 'package:users_app/widgets/dashboard_drawer.dart';
import 'package:http/http.dart';
import 'package:users_app/widgets/driver_cancel_message_dialog.dart';
import 'package:users_app/widgets/pay_fare_amount_dialog.dart';

import '../InfoHandler/app_info.dart';
import '../assistants/assistant_methods.dart';
import '../widgets/progress_dialog.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  double searchLocationContainerHeight = 220;
  double responseFromDriverContainerHeight = 0;
  double assignedDriverInfoContainerHeight= 0;

  Position? userCurrentPosition;
  var geoLocator = Geolocator();
  LocationPermission? _locationPermission;

  List<LatLng> polyLineCoordinatesList = [];
  Set<Polyline> polyLineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  List<ActiveNearbyAvailableDrivers> onlineAvailableDriversList = [];

  bool openNavigationDrawer = true;
  bool activeNearbyDriverKeysLoaded = false;
  bool requestPositionInfo = true;
  BitmapDescriptor? activeNearbyIcon;

  DatabaseReference? referenceRideRequest;

  String userName = "";
  String driverRideStatus = "Your driver is coming in";
  double bottomPaddingofMap = 0;
  String rideRequestStatus = "";

  StreamSubscription<DatabaseEvent>? rideRequestInfoStreamSubscription;

  void checkIfPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();
    if(_locationPermission == LocationPermission.denied){
      _locationPermission = await Geolocator.requestPermission();
    }

  }

  // Get Current Location of the user
  locateUserPosition() async{
    userCurrentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    LatLng latLngPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

    CameraPosition cameraPosition = CameraPosition(target:latLngPosition, zoom: 16);
    newMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    userName = currentUserInfo!.name!;
    String humanReadableAddress = await AssistantMethods.searchAddressForGeographicCoordinates(userCurrentPosition!,context);
    initializeGeoFireListener(); // Show Active Drivers
  }

  void saveRideRequestInformation() {
    // save Ride Request Information
    referenceRideRequest = FirebaseDatabase.instance.ref().child("AllRideRequests").push();

    var sourceLocation =  Provider.of<AppInfo>(context,listen: false).userPickupLocation;
    var destinationLocation = Provider.of<AppInfo>(context,listen: false).userDropOffLocation;

    Map sourceLocationMap ={
      "latitude" : sourceLocation!.locationLatitude,
      "longitude" : sourceLocation.locationLongitude
    };

    Map destinationLocationMap ={
      "latitude" : destinationLocation!.locationLatitude,
      "longitude" : destinationLocation.locationLongitude
    };

    Map userInformationMap = {
      "source": sourceLocationMap,
      "destination": destinationLocationMap,
      "userName" : currentUserInfo!.name,
      "userPhone" : currentUserInfo!.phone,
      "sourceAddress": sourceLocation.locationName,
      "destinationAddress" : destinationLocation.locationName,
      "driverId": "waiting",
      "time": DateTime.now().toString(),
    };

    // Saving user Information on database (AllRideRequests)
    referenceRideRequest!.set(userInformationMap);

    // Retrieving ride request information if there is any live changes/ When driver accepts the ride request
    referenceRideRequest!.onValue.listen((eventSnap) async {
      DataSnapshot snapshot = eventSnap.snapshot;
      if(snapshot.value == null){
        return;
      }

      if ((snapshot.value as Map)["carDetails"] != null){
        setState(() {
          carModel = (snapshot.value as Map)["carDetails"]["carModel"].toString();
          carNumber = (snapshot.value as Map)["carDetails"]["carNumber"].toString();
          carType = (snapshot.value as Map)["carDetails"]["carType"].toString();
        });
      }

      if ((snapshot.value as Map)["userName"] != null){
        setState(() {
          driverName = (snapshot.value as Map)["userName"].toString();
        });
      }

      if ((snapshot.value as Map)["userPhone"] != null){
        setState(() {
          driverPhone = (snapshot.value as Map)["userPhone"].toString();
        });
      }

      if ((snapshot.value as Map)["status"] != null){
        rideRequestStatus = (snapshot.value as Map)["status"].toString();
      }

      if ((snapshot.value as Map)["driverLocationData"] != null){
        double driverLocationLat = double.parse((snapshot.value as Map)["driverLocationData"]["latitude"].toString());
        double driverLocationLng = double.parse((snapshot.value as Map)["driverLocationData"]["longitude"].toString());
        LatLng driverLocationLatLng = LatLng(driverLocationLat, driverLocationLng);

        // Ride status == Accepted
        if(rideRequestStatus == "Accepted"){
          Fluttertoast.showToast(msg: "LatLng:" + driverLocationLatLng.latitude.toString() + driverLocationLatLng.longitude.toString());
          // Estimating time to reach from driver current location to user pickup location
          updateArrivalTimeToUserPickupLocation(driverLocationLatLng);
        }

        // Ride status == Arrived
        else if(rideRequestStatus == "Arrived"){
          setState(() {
            driverRideStatus = "Driver has arrived";
          });

        }

        // Ride status == On Trip
        else if(rideRequestStatus == "On Trip"){
          // Estimating time to reach from driver current location to user dropoff location
          updateTimeToReachUserDropoffLocation(driverLocationLatLng);
        }

        // Ride status == Arrived
        else if(rideRequestStatus == "Ended"){
          if((snapshot.value as Map)["fareAmount"] != null){
            double fareAmount = double.parse((snapshot.value as Map)["fareAmount"].toString());
            var response = await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context){
                return PayFareDialog(fareAmount: fareAmount);
              }
            );

            if(response == "Cash Paid"){
              // Rate the driver
              if((snapshot.value as Map)["driverId"].toString() != null){
                // fetch the driverId and move to RateDriverScreen
                String assignedDriverId = (snapshot.value as Map)["driverId"].toString();
                Navigator.push(context, MaterialPageRoute(builder: (context) => RateDriverScreen(
                  assignedDriverId : assignedDriverId,
                  driverName: driverName
                )));

                referenceRideRequest!.onDisconnect(); //Stop listening to live changes on the rideRequest
                rideRequestInfoStreamSubscription!.cancel();
              }
            }

          }

        }

      }

    });

    onlineAvailableDriversList = GeoFireAssistant.activeNearbyAvailableDriversList;
    searchNearestOnlineDrivers();

  }

  updateArrivalTimeToUserPickupLocation(driverLocationLatLng) async{
    if(requestPositionInfo == true){
      requestPositionInfo = false;

      LatLng userLocationLatLng = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
      var directionDetailsInfo = await AssistantMethods.getOriginToDestinationDirectionDetails(driverLocationLatLng, userLocationLatLng);

      if(directionDetailsInfo == null){
        return;
      }

      setState(() {
        driverRideStatus = "Your driver is coming in " + directionDetailsInfo.duration_text.toString();
      });

      requestPositionInfo = true;
    }
  }

  updateTimeToReachUserDropoffLocation(driverLocationLatLng) async{
    if(requestPositionInfo == true){
      requestPositionInfo = false;

      var userDropOffLocation = Provider.of<AppInfo>(context,listen: false).userDropOffLocation;
      LatLng userDropoffLocationLatLng = LatLng(
          userDropOffLocation!.locationLatitude!,
          userDropOffLocation.locationLongitude!
      );

      var directionDetailsInfo = await AssistantMethods.getOriginToDestinationDirectionDetails(driverLocationLatLng, userDropoffLocationLatLng);

      if(directionDetailsInfo == null){
        return;
      }

      setState(() {
        Fluttertoast.showToast(msg: directionDetailsInfo.duration_text.toString());
        driverRideStatus = "Time to destination: " + directionDetailsInfo.duration_text.toString();
      });

      requestPositionInfo = true;
    }
  }

  void searchNearestOnlineDrivers() async{
    if (onlineAvailableDriversList.isEmpty){

      // Remove user Information for ride request from database
      referenceRideRequest!.remove();

      setState(() {
        markersSet.clear();
        circlesSet.clear();
        polyLineSet.clear();
        polyLineCoordinatesList.clear();
      });

      Fluttertoast.showToast(msg: "No drivers Available");
      Future.delayed(const Duration(milliseconds: 4), (){
        SystemNavigator.pop();
      });

      return;
    }

    //retrieve active driver information
    await retrieveOnlineDriversInformation(onlineAvailableDriversList);

    // Move to select driver screen
    SelectActiveDriverScreen.referenceRideRequest = referenceRideRequest;
    var response = await Navigator.pushNamed(context, '/select_active_driver_screen');

    if(response == "Driver chosen"){
      FirebaseDatabase.instance.ref()
          .child("Drivers")
          .child(chosenDriverId)
          .once()
          .then((snapData){
            DataSnapshot snapshot = snapData.snapshot;
            if(snapshot.exists){
              setRideStatusAndGetRegToken(chosenDriverId);
            }

            else{
              Fluttertoast.showToast(msg: "This driver does not exist!Please try again");
            }
      } );
    }

  }

  retrieveOnlineDriversInformation(List onlineAvailableDriversList) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("Drivers");

    for(int i=0; i<onlineAvailableDriversList.length; i++)
    {
      await ref.child(onlineAvailableDriversList[i].driverId.toString())
          .once()
          .then((dataSnapshot) {
            var driverInfo = dataSnapshot.snapshot.value;
            driversList.add(driverInfo);

      });
    }
  }

  setRideStatusAndGetRegToken(chosenDriverId){
    FirebaseDatabase.instance.ref()
        .child("Drivers")
        .child(chosenDriverId)
        .child("newRideStatus")
        .set(referenceRideRequest!.key);

    // automate the push notifications
    FirebaseDatabase.instance.ref()
        .child("Drivers")
        .child(chosenDriverId)
        .child("tokens")
        .once()
        .then((SnapData){
          DataSnapshot snapshot = SnapData.snapshot;
          if(snapshot.exists){
            showWaitingResponseFromDriversUI(); // Waiting UI Container

            String deviceRegistrationToken = snapshot.value.toString(); // Fetching the reg token of current driver
            AssistantMethods.sendNotificationToDriver(context,referenceRideRequest!.key,deviceRegistrationToken);

            FirebaseDatabase.instance.ref()
                .child("Drivers")
                .child(chosenDriverId)
                .child("newRideStatus")
                .onValue
                .listen((eventSnapShoot) // Listen to changes of newRideStatus
            {

              DataSnapshot dataSnap = eventSnapShoot.snapshot;
              // newRideStatus == "idle", Driver Cancelled the trip
              if(dataSnap.value == "idle") {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return DriverCancelMessageDialog();
                    }
                );
              }

              // newRideStatus == "Accepted", Driver Cancelled the trip
              else if (dataSnap.value == "Accepted"){
                showUIForAssignedDriverInfo();
              }

            }

          );
        }

        });

  }

  showUIForAssignedDriverInfo(){
    setState(() {
      searchLocationContainerHeight = 0;
      responseFromDriverContainerHeight = 0;
      assignedDriverInfoContainerHeight = 240;
    });
  }

  showWaitingResponseFromDriversUI(){
    setState(() {
      searchLocationContainerHeight = 0;
      responseFromDriverContainerHeight = 220;
    });
  }



  @override
  void initState() {
    super.initState();
    checkIfPermissionAllowed();
    AssistantMethods.readRideRequestKeys(context);
  }


  @override
  Widget build(BuildContext context) {
    createActiveDriverIconMarker();
    return Scaffold(
      key: sKey,
      drawer: DashboardDrawer(name: userName),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingofMap),
            mapType: MapType.normal,
            polylines: polyLineSet,
            markers: markersSet,
            circles: circlesSet,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller){
              _controllerGoogleMap.complete(controller);
              newMapController = controller;
              setState(() {
                bottomPaddingofMap = 235;
              });
              locateUserPosition();
            },
          ),

          // Button for Drawer
          Positioned(
            top: 35,
            left: 15,
            child: GestureDetector(
              onTap: (){
                if(openNavigationDrawer){
                  sKey.currentState!.openDrawer();
                }

                else{
                  // Restart - Refresh - Minimize App Programmatically
                  SystemNavigator.pop();
                }
              },

              child:  CircleAvatar(
                backgroundColor: Colors.white70,
                child: Icon(
                  openNavigationDrawer ? Icons.menu : Icons.close,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          //UI to search location
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              curve: Curves.easeIn,
              duration: Duration(milliseconds: 120),
              child: Container(
                height: searchLocationContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),

                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    children: [
                      //From
                      Row(
                        children: [
                          Icon(Icons.add_location_alt_outlined,color: Colors.black),
                          SizedBox(width: 12.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                               "From",
                                style: TextStyle(
                                    color: Colors.black,fontSize: 12
                                ),
                              ),

                              Text(
                                Provider.of<AppInfo>(context).userPickupLocation!=null ?
                                Provider.of<AppInfo>(context).userPickupLocation!.locationName!.substring(0,16)
                                    : "No Address found",
                                style: const TextStyle(
                                    color: Colors.black,fontSize: 14
                                ),
                              ),

                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.black,
                      ),

                      const SizedBox(height: 16),

                      // To
                      GestureDetector(
                        onTap: () async{
                          var response = await Navigator.pushNamed(context, '/search_places_screen');
                          if(response == "Obtained"){
                            setState(() {
                              openNavigationDrawer = false;
                            });

                            await drawPolylineFromSourceToDestination();
                          }

                        },
                        child: Row(
                          children: [
                            Icon(Icons.add_location_alt_outlined,color: Colors.black),
                            SizedBox(width: 12.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "To",
                                  style: TextStyle(
                                      color: Colors.black,fontSize: 12
                                  ),
                                ),

                                Text(
                                  Provider.of<AppInfo>(context).userDropOffLocation!=null ?
                                  Provider.of<AppInfo>(context).userDropOffLocation!.locationName!
                                  : "Where to?",
                                  style: const TextStyle(
                                      color: Colors.black,fontSize: 14
                                  ),
                                ),

                              ],
                            ),



                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.black,
                      ),

                      const SizedBox(height: 16),

                      ElevatedButton(
                        onPressed: (){
                          if(Provider.of<AppInfo>(context,listen: false).userDropOffLocation!=null){
                            saveRideRequestInformation();
                          }

                          else{
                            Fluttertoast.showToast(msg: "Please select your destination");
                          }
                        },

                        style: ElevatedButton.styleFrom(
                          primary: Colors.black,
                          textStyle: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold)
                        ),

                        child: const Text("Request a ride"),


                      )



                    ],
                  ),
                ),
              ),


            ),



          ),

          //UI of driver response waiting
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: responseFromDriverContainerHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),

              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: AnimatedTextKit(
                    animatedTexts: [
                      FadeAnimatedText(
                        'Waiting for driver response\n from driver',
                        duration: const Duration(seconds: 10),
                        textAlign: TextAlign.center,
                        textStyle: const TextStyle(color: Colors.black, fontSize: 30.0, fontWeight: FontWeight.bold),
                      ),
                      ScaleAnimatedText(
                        'Please wait',
                        duration: const Duration(seconds: 10),
                        textAlign: TextAlign.center,
                        textStyle: const TextStyle(color: Colors.black, fontSize: 35.0, fontWeight: FontWeight.bold, fontFamily: 'Canterbury'),
                      ),
                    ],
                  ),


                ),
              ),
            ),
          ),

          //ui for waiting response from driver
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: assignedDriverInfoContainerHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),

              ),

              child: Padding(
                padding: const EdgeInsets.fromLTRB(20,0,0,0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10.0,
                    ),

                    Text(
                      driverRideStatus,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black
                      ),
                    ),

                    const SizedBox(
                      height: 10.0,
                    ),

                    const Divider(
                      height: 0.5,
                      thickness: 0.5,
                      color: Colors.grey,
                    ),

                    const SizedBox(
                      height: 10.0,
                    ),

                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Image.asset(
                              "images/Passport_Photo.png",
                            ),
                            minRadius: 30,
                            maxRadius: 40,
                          ),

                          const SizedBox(
                            width: 3.0,
                          ),

                          // driverName,Duration and Rating
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                driverName,
                                style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold
                                ),
                              ),

                              const SizedBox(
                                height: 10.0,
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.car_rental),
                                  SizedBox(width: 5),
                                  Text(
                                    carModel,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 15),
                                  )
                                ],
                              ),


                              const SizedBox(
                                height: 5.0,
                              ),

                              // Driver rating
                              Row(
                                children: const [
                                  Icon(
                                    Icons.star,
                                    color: CupertinoColors.systemYellow,
                                  ),
                                  SizedBox(width: 5),

                                  Text(
                                    "5",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 12),
                                  )
                                ],
                              ),

                            ],
                          ),

                          const SizedBox(
                            width: 40.0,
                          ),

                          //driver information
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Image.asset("images/" + carType + ".png"),
                                radius: 35,
                              ),

                              //driver vehicle details
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    carNumber,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),

                                ],
                              ),
                          ]
                        ),

                      ]
                    ),

                    const SizedBox(
                      height: 12.0,
                    ),

                    const Divider(
                      height: 0.5,
                      thickness: 0.5,
                      color: Colors.grey,
                    ),

                    const SizedBox(
                      height: 15.0,
                    ),


                    //call driver button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(width: 10,),

                            //call button
                            TextButton(
                              onPressed: (){
                                //
                              },
                              style: ElevatedButton.styleFrom(
                                shape:  RoundedRectangleBorder(side: BorderSide(
                                    color: Colors.lightBlue,
                                    width: 2,
                                    style: BorderStyle.solid
                                ), borderRadius: BorderRadius.circular(10)),
                                primary: Colors.white,
                                padding: const EdgeInsets.fromLTRB(20,15,20,15),
                              ),
                              child: const Icon(
                                Icons.phone_android,
                                color: Colors.lightBlue,
                                size: 25,
                              ),
                            ),

                            const SizedBox(width: 10,),

                            //text button
                            TextButton(
                              onPressed: (){
                                //
                              },
                              style: ElevatedButton.styleFrom(
                                shape:  RoundedRectangleBorder(side: BorderSide(
                                    color: Colors.lightBlue,
                                    width: 2,
                                    style: BorderStyle.solid
                                ), borderRadius: BorderRadius.circular(10)),
                                primary: Colors.white,
                                padding: const EdgeInsets.fromLTRB(20,15,20,15),
                              ),
                              child: const Icon(
                                Icons.chat_outlined,
                                color: Colors.lightBlue,
                                size: 25,
                              ),
                            ),

                            const SizedBox(width: 10,),

                            /*ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                primary: Colors.grey[200],
                                padding: const EdgeInsets.fromLTRB(60,15,60,15),
                              ),

                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),*/
                          ],
                        ),

                    const SizedBox(
                      height: 10.0,
                    ),


                  ]



                ),
              ),

            ),
          )

    ]
      )
    );


  }

  Future<void> drawPolylineFromSourceToDestination() async{
    var sourcePosition = Provider.of<AppInfo>(context,listen: false).userPickupLocation;
    var destinationPosition = Provider.of<AppInfo>(context,listen: false).userDropOffLocation;

    var sourceLatLng = LatLng(sourcePosition!.locationLatitude!, sourcePosition.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!, destinationPosition.locationLongitude!);

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(message: 'Please wait..',)
    );

    var directionDetailsInfo = await AssistantMethods.getOriginToDestinationDirectionDetails(sourceLatLng,destinationLatLng);

    setState(() {
      tripDirectionDetailsInfo = directionDetailsInfo;
    });

    Navigator.pop(context);

    print(directionDetailsInfo!.e_points);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsList = polylinePoints.decodePolyline(directionDetailsInfo.e_points!);

    polyLineCoordinatesList.clear();

    if(decodedPolyLinePointsList.isNotEmpty){
      decodedPolyLinePointsList.forEach((PointLatLng pointLatLng) {
        polyLineCoordinatesList.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polyLineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.black,
        polylineId: const PolylineId("PolyLineID"),
        jointType: JointType.bevel,
        points: polyLineCoordinatesList,
        startCap: Cap.roundCap,
        endCap:  Cap.squareCap,
        geodesic: true,
      );

      polyLineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if(sourceLatLng.latitude > destinationLatLng.latitude && sourceLatLng.longitude > destinationLatLng.longitude)
    {
      boundsLatLng = LatLngBounds(southwest: destinationLatLng, northeast: sourceLatLng);
    }
    else if(sourceLatLng.longitude > destinationLatLng.longitude)
    {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(sourceLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, sourceLatLng.longitude),
      );
    }
    else if(sourceLatLng.latitude > destinationLatLng.latitude)
    {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, sourceLatLng.longitude),
        northeast: LatLng(sourceLatLng.latitude, destinationLatLng.longitude),
      );
    }
    else
    {
      boundsLatLng = LatLngBounds(southwest: sourceLatLng, northeast: destinationLatLng);
    }

    newMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: const MarkerId("sourceID"),
      infoWindow: InfoWindow(title: sourcePosition.locationName, snippet: "Pickup"),
      position: sourceLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      infoWindow: InfoWindow(title: destinationPosition.locationName, snippet: "Destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      markersSet.add(originMarker);
      markersSet.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: Colors.black,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: sourceLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationID"),
      fillColor: Colors.black,
      radius: 12,
      strokeWidth: 15,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      circlesSet.add(originCircle);
      circlesSet.add(destinationCircle);
    });

  }

  initializeGeoFireListener(){
    Geofire.initialize("ActiveDrivers");
    Geofire.queryAtLocation(userCurrentPosition!.latitude, userCurrentPosition!.longitude,10)!.listen((map) { // Search for active drivers from user's location upto 10km radius
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
        //whenever any driver become active/online
          case Geofire.onKeyEntered:
            ActiveNearbyAvailableDrivers activeNearbyAvailableDriver = ActiveNearbyAvailableDrivers();
            activeNearbyAvailableDriver.locationLatitude = map['latitude'];
            activeNearbyAvailableDriver.locationLongitude = map['longitude'];
            activeNearbyAvailableDriver.driverId = map['key'];
            GeoFireAssistant.activeNearbyAvailableDriversList.add(activeNearbyAvailableDriver);
            if(activeNearbyDriverKeysLoaded == true)
            {
              displayActiveDriversOnUsersMap();
            }
            break;

        //whenever any driver become non-active/offline
          case Geofire.onKeyExited:
            GeoFireAssistant.deleteOfflineDriverFromList(map['key']);
            displayActiveDriversOnUsersMap();
            break;

        //whenever driver moves - update driver location
          case Geofire.onKeyMoved:
            ActiveNearbyAvailableDrivers activeNearbyAvailableDriver = ActiveNearbyAvailableDrivers();
            activeNearbyAvailableDriver.locationLatitude = map['latitude'];
            activeNearbyAvailableDriver.locationLongitude = map['longitude'];
            activeNearbyAvailableDriver.driverId = map['key'];
            GeoFireAssistant.updateActiveNearbyAvailableDriverLocation(activeNearbyAvailableDriver);
            displayActiveDriversOnUsersMap();
            break;

        //display those online/active drivers on user's map
          case Geofire.onGeoQueryReady:
            displayActiveDriversOnUsersMap();
            break;
        }
      }

      setState(() {});

    });
  }

  void displayActiveDriversOnUsersMap(){
    setState(() {
      markersSet.clear();
      circlesSet.clear();
    });

    Set<Marker> driversMarkerSet = Set<Marker>();

    for(ActiveNearbyAvailableDrivers eachDriver in GeoFireAssistant.activeNearbyAvailableDriversList){
      LatLng eachDriverPosition = LatLng(eachDriver.locationLatitude!, eachDriver.locationLongitude!);

      Marker marker = Marker(
        markerId: MarkerId(eachDriver.driverId!),
        position: eachDriverPosition,
        icon: activeNearbyIcon!,
        rotation: 360,
      );

      driversMarkerSet.add(marker);
    }

    setState(() {
      markersSet = driversMarkerSet;
    });


  }

  createActiveDriverIconMarker()
  {
    if(activeNearbyIcon == null)
    {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car-2.png").then((value)
      {
        activeNearbyIcon = value;
      });
    }
  }





}
