import 'dart:async';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/widgets/fare_amount_collection_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../assistants/assistant_methods.dart';

import '../models/ride_request_information.dart';
import '../widgets/progress_dialog.dart';

class NewTripScreen extends StatefulWidget {

  RideRequestInformation? rideRequestInformation;

  NewTripScreen({this.rideRequestInformation});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  GoogleMapController? newTripMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Set<Marker> setOfMarkers = Set<Marker>();
  Set<Circle> setOfCircles = Set<Circle>();
  Set<Polyline> polyLineSet = Set<Polyline>();
  List<LatLng> polyLineCoordinatesList = [];
  PolylinePoints polylinePoints = PolylinePoints();

  double mapPadding = 0;
  var geoLocator = Geolocator();
  BitmapDescriptor? driverIconMarker;

  Position? driverLiveLocation;

  String rideRequestStatus = "Accepted";
  String buttonTitle = "Arrived";
  Color buttonColor = Colors.green;
  String durationFromSourceToDestination = "";

  bool isRequestDirectionDetails = false;

  // When driver accepts ride request, sourceLatLng = driver Current Location, destinationLatLng = driver pickup Location
  // When driver starts the ride, sourceLatLng = User Current Location, destinationLatLng = User Dropoff Location

  Future<void> drawPolylineFromSourceToDestination(LatLng sourceLatLng,LatLng destinationLatLng) async{
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(message: 'Please wait..',)
    );

    var directionDetailsInfo = await AssistantMethods.getOriginToDestinationDirectionDetails(sourceLatLng,destinationLatLng);

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

    newTripMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: const MarkerId("sourceID"),
      position: sourceLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      setOfMarkers.add(originMarker);
      setOfMarkers.add(destinationMarker);
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
      setOfCircles.add(originCircle);
      setOfCircles.add(destinationCircle);
    });

  }

  endTrip() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return ProgressDialog(message: "Please wait");
        });

    var currentDriverPositionLatLng = LatLng(driverLiveLocation!.latitude, driverLiveLocation!.longitude);

    //Get Trip direction details - Distance and duration travelled
    var tripDirectionDetailsInfo = await AssistantMethods.getOriginToDestinationDirectionDetails(
        currentDriverPositionLatLng,
        widget.rideRequestInformation!.sourceLatLng!
    );

    Fluttertoast.showToast(msg: "KM:" + tripDirectionDetailsInfo!.duration_text! + " Time:" + tripDirectionDetailsInfo.distance_text!);

    // Fare Amount
    double? fareAmount = AssistantMethods.calculateFareAmountFromSourceToDestination(tripDirectionDetailsInfo, driverData.carType);

    FirebaseDatabase.instance.ref()
        .child("AllRideRequests")
        .child(widget.rideRequestInformation!.rideRequestId!)
        .child("status")
        .set("Ended");

    FirebaseDatabase.instance.ref()
        .child("AllRideRequests")
        .child(widget.rideRequestInformation!.rideRequestId!)
        .child("fareAmount")
        .set(fareAmount);

    streamSubscriptionPosition!.cancel();

    Navigator.pop(context);
    
    // Display Fare amount dialogbox
    showDialog(
      context: context,

      builder: (BuildContext context){
        return FareAmountDialog(
          fareAmount: fareAmount,
          userName: widget.rideRequestInformation!.userName
        );
      }
    );

    // Store current earning to total earnings in database
    FirebaseDatabase.instance.ref()
        .child("Drivers")
        .child(currentFirebaseUser!.uid)
        .child("totalEarnings")
        .once()
        .then((snapData){
          DataSnapshot snapshot = snapData.snapshot;
          // If total earnings exist in realtime database
          if(snapshot.exists){
            double previousEarnings = double.parse(snapshot.value.toString());
            double totalEarning = previousEarnings + fareAmount;
            FirebaseDatabase.instance.ref()
                .child("Drivers")
                .child(currentFirebaseUser!.uid)
                .child("totalEarnings")
                .set(totalEarning.toString());
          }

          else{
            FirebaseDatabase.instance.ref()
                .child("Drivers")
                .child(currentFirebaseUser!.uid)
                .child("totalEarnings")
                .set(fareAmount.toString());
          }

      });

  }

  @override
  void initState() {
    super.initState();
    saveAssignedDriverDetailsToRideRequest();
  }

  @override
  Widget build(BuildContext context) {
    createActiveDriverIconMarker();
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            markers: setOfMarkers,
            circles: setOfCircles,
            polylines: polyLineSet,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newTripMapController = controller;

              setState(() {
                mapPadding = 320;
              });

              var driverCurrentLatLng = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
              var userCurrentLatLng = widget.rideRequestInformation!.sourceLatLng;

              drawPolylineFromSourceToDestination(driverCurrentLatLng,userCurrentLatLng!);
              updateDriversLocationAtRealTime();

            },
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,

            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,

                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 10,
                    spreadRadius: 0.5,
                    offset: Offset(0.6, 0.6),
                  )
                ]
              ),

              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 25,vertical: 20),
                child: Column(
                  children: [
                    //duration
                    Text(
                      durationFromSourceToDestination,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 18,),

                    const Divider(
                      thickness: 2,
                      height: 2,
                      color: Colors.black,
                    ),

                    const SizedBox(height: 15),

                    //user name - icon
                    Row(
                      children: [
                        Text(
                          widget.rideRequestInformation!.userName!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.phone_android,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12,),

                    //user PickUp Address with icon
                    Row(
                      children: [
                        Image.asset(
                          "images/source.png",
                          width: 30,
                          height: 30,
                        ),

                        const SizedBox(width: 14,),

                        Expanded(
                          child: Container(
                            child: Text(
                              widget.rideRequestInformation!.sourceAddress!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    //user DropOff Address with icon
                    Row(
                      children: [
                        Image.asset(
                          "images/destination.png",
                          width: 30,
                          height: 30,
                        ),

                        const SizedBox(
                          width: 14,
                        ),

                        Expanded(
                          child: Container(
                            child: Text(
                              widget.rideRequestInformation!.destinationAddress!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30,),

                    const Divider(
                      thickness: 2,
                      height: 2,
                      color: Colors.black,
                    ),

                    const SizedBox(height: 20),



                    ElevatedButton.icon(
                      onPressed: () async {
                        // When driver has arrived at the pickup location - Arrived Button
                        if(rideRequestStatus == "Accepted"){
                          rideRequestStatus = "Arrived";

                          setState(() {
                            buttonTitle = "Start Trip";
                            buttonColor = Colors.green;
                          });

                          FirebaseDatabase.instance.ref()
                              .child("AllRideRequests")
                              .child(widget.rideRequestInformation!.rideRequestId!)
                              .child("status")
                              .set(rideRequestStatus);

                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context){
                                return ProgressDialog(message: "Loading");
                              });

                          await drawPolylineFromSourceToDestination(
                              widget.rideRequestInformation!.sourceLatLng!,
                              widget.rideRequestInformation!.destinationLatLng!
                          );

                          Navigator.pop(context);
                        }

                        // When driver has started the trip - Start Trip Button
                        else if(rideRequestStatus == "Arrived"){
                          rideRequestStatus = "On Trip";

                          setState(() {
                            buttonTitle = "End Trip";
                            buttonColor = Colors.redAccent;
                          });

                          FirebaseDatabase.instance.ref()
                              .child("AllRideRequests")
                              .child(widget.rideRequestInformation!.rideRequestId!)
                              .child("status")
                              .set(rideRequestStatus);

                        }

                        // When driver has ended the trip - End Trip Button
                        else if(rideRequestStatus == "On Trip"){
                          endTrip();
                        }
                      },

                      style: ElevatedButton.styleFrom(
                        primary: buttonColor,
                      ),

                      icon: const Icon(
                        Icons.directions_car,
                        color: Colors.white,
                        size: 25,
                      ),

                      label: Text(
                        buttonTitle,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],



                ),
              )),
          )

        ]
      ),
    );
  }

  // Save All information about driver in Ride Request section of database
  saveAssignedDriverDetailsToRideRequest(){
    DatabaseReference reference = FirebaseDatabase.instance.ref().child("AllRideRequests")
                                                                 .child(widget.rideRequestInformation!.rideRequestId!);

    Map driverCarDetailsMap = {
      "carColor" : driverData.carColor,
      "carModel" : driverData.carModel,
      "carNumber" : driverData.carNumber,
      "carType" : driverData.carType
    };

    Map driverLocationDataMap = {
      "latitude" : driverCurrentPosition!.latitude,
      "longitude" : driverCurrentPosition!.longitude,
    };

    reference.child("status").set("Accepted");
    reference.child("driverId").set(driverData.id);
    reference.child("driverName").set(driverData.name);
    reference.child("driverPhone").set(driverData.phone);
    reference.child("carDetails").set(driverCarDetailsMap);
    reference.child("driverLocationData").set(driverLocationDataMap);

    // Save Ride request id to driver's history
    saveRideRequestId();

  }

  saveRideRequestId() {
    DatabaseReference reference = FirebaseDatabase.instance.ref().child("Drivers")
                                                                 .child(currentFirebaseUser!.uid)
                                                                 .child("tripHistory"); 

    reference.child(widget.rideRequestInformation!.rideRequestId!).set(true);
  }

  createActiveDriverIconMarker()
  {
    if(driverIconMarker == null)
    {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car-2.png").then((value)
      {
        driverIconMarker = value;
      });
    }
  }


  updateDriversLocationAtRealTime() {
    Fluttertoast.showToast(msg: "Inside updateDriversLocationAtRealTime()");
    streamSubscriptionPosition = Geolocator.getPositionStream() // Get Updated position of the driver
            .listen((Position position)
    {

      driverCurrentPosition = position;
      driverLiveLocation = position;

      LatLng driverLivePositionLatLng = LatLng(
        driverLiveLocation!.latitude,
        driverLiveLocation!.longitude,
      );

      Marker animatingCarMarker = Marker(
          markerId: const MarkerId("animatingCarMarker"),
          position: driverLivePositionLatLng,
          icon: driverIconMarker!
      );

      setState(() {
        CameraPosition cameraPosition = CameraPosition(target: driverLivePositionLatLng, zoom: 16); // New CameraPosition everytime the location is updated
        newTripMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition)); // Animating camera in google map according to LatLng

        setOfMarkers.removeWhere((element) => element.markerId.value == "animatingCarMarker");
        setOfMarkers.add(animatingCarMarker);
      });

      updateDurationAtRealTime();

      Map driverUpdatedLocationMap = {
        "latitude": driverLiveLocation!.latitude.toString(),
        "longitude": driverLiveLocation!.longitude.toString(),
      };

      // Updating live location of the driver in realtime database
      FirebaseDatabase.instance
          .ref()
          .child("AllRideRequests")
          .child(widget.rideRequestInformation!.rideRequestId!)
          .child("driverLocationData")
          .set(driverUpdatedLocationMap);
    });
  }

  updateDurationAtRealTime() async{
    Fluttertoast.showToast(msg: "Inside updateDurationAtRealTime()");
    if (isRequestDirectionDetails == false) {
      isRequestDirectionDetails = true;

      if (driverLiveLocation == null) {
        return;
      }

      // Driver Current Position
      var sourceLatLng = LatLng(driverLiveLocation!.latitude, driverLiveLocation!.longitude);
      var destinationLatLng;

      if (rideRequestStatus == "Accepted") {
        destinationLatLng = widget.rideRequestInformation!.sourceLatLng; // User Pickup Address
      }

      else {
        destinationLatLng = widget.rideRequestInformation!.destinationLatLng; // User Dropoff Address
      }

      var directionDetailsInfo = await AssistantMethods.getOriginToDestinationDirectionDetails(sourceLatLng, destinationLatLng);

      if (directionDetailsInfo != null) {
        setState(() {
          durationFromSourceToDestination = directionDetailsInfo.duration_text!;
        });

        isRequestDirectionDetails = false;

      }

    }

  }

}




