import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:drivers_app/models/ride_request_information.dart';
import 'package:drivers_app/widgets/push_notification_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../global/global.dart';

class PushNotificationSystem {

  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future initializeCloudMessaging(BuildContext context) async{

    // Terminated - When the app is completely closed and the app resumes from the push notification
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMessage){
      if(remoteMessage!=null){
        // display ride request information
        retrieveRideRequestInformation(remoteMessage.data["rideRequestId"],context);
      }
    });


    // Background - When the app is minimized and the app resumes from the push notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {
      if(remoteMessage!=null){
        // display ride request information
        retrieveRideRequestInformation(remoteMessage.data["rideRequestId"],context);
      }
    });

    // Foreground - When the app is open and receives a notification
    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
      if(remoteMessage!=null){
        // display ride request information
        retrieveRideRequestInformation(remoteMessage.data["rideRequestId"],context);
        //Fluttertoast.showToast(msg: "This is the ride request ID:" + remoteMessage.data["rideRequestId"]);
      }
    });


  }

  Future generateRegistrationToken() async{
    String? registrationToken = await firebaseMessaging.getToken(); // Generate and get registration token

    FirebaseDatabase.instance.ref()  // Saving the registration token
        .child("Drivers")
        .child(currentFirebaseUser!.uid)
        .child("tokens")
        .set(registrationToken);

    firebaseMessaging.subscribeToTopic("allDrivers");
    firebaseMessaging.subscribeToTopic("allUsers");
  }

  retrieveRideRequestInformation(String rideRequestID,BuildContext context){
    FirebaseDatabase.instance.ref()
        .child("AllRideRequests")
        .child(rideRequestID)
        .once()
        .then((snapData)
    {
          DataSnapshot snapshot = snapData.snapshot;
          if(snapshot.exists){
            audioPlayer.open(Audio("music/music_notification.mp3"));
            audioPlayer.play();

            String? rideRequestID  = snapshot.key;

            double sourceLat = (snapshot.value! as Map)["source"]["latitude"];
            double sourceLng = (snapshot.value! as Map)["source"]["longitude"];
            String sourceAddress = (snapshot.value! as Map)["sourceAddress"];

            double destinationLat = (snapshot.value! as Map)["destination"]["latitude"];
            double destinationLng = (snapshot.value! as Map)["destination"]["longitude"];
            String destinationAddress = (snapshot.value! as Map)["destinationAddress"];

            String userName = (snapshot.value! as Map)["userName"];
            String userPhone = (snapshot.value! as Map)["userPhone"];

            RideRequestInformation rideRequestInformation = RideRequestInformation();
            rideRequestInformation.rideRequestId = rideRequestID;
            rideRequestInformation.userName = userName;
            rideRequestInformation.userPhone = userPhone;
            rideRequestInformation.sourceLatLng = LatLng(sourceLat, sourceLng);
            rideRequestInformation.destinationLatLng = LatLng(destinationLat, destinationLng);
            rideRequestInformation.sourceAddress = sourceAddress;
            rideRequestInformation.destinationAddress = destinationAddress;

            showDialog(
              context: context,
              builder: (BuildContext context) => NotificationDialogBox(
                  rideRequestInformation: rideRequestInformation,
              ),
            );

          }

          else{
            Fluttertoast.showToast(msg: "This ride request is invalid!");
          }

    });

  }
}