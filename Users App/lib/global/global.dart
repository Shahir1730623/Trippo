import 'package:firebase_auth/firebase_auth.dart';

import '../models/active_nearby_available_drivers.dart';
import '../models/direction_details_info.dart';
import '../models/user_model.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
UserModel? currentUserInfo;
List driversList = [];
DirectionDetailsInfo? tripDirectionDetailsInfo;
String chosenDriverId = "";
String cloudMessagingServerToken = "key=AAAAcHgHMho:APA91bFmPbK13L7pKr1HpAC9N_lu4mb9O9ZQH7BVNCzOQ_oYMBsjXCpTbioSqsGt36khuKPopulAy6A7FPw4TnuqsWOEfLHOjcVc26jHCGOBRAFy12HP7WjTx1_o7FLmv3t4VR-GWTRW";
String driverCarDetails = "";
String carModel = "";
String carNumber = "";
String carType = "";
String driverName = "";
String driverPhone = "";
double countRatingStars = 0.0;
String titleStarsRating = "";