import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_app/InfoHandler/app_info.dart';
import 'package:users_app/global/map_key.dart';
import 'package:users_app/models/directions.dart';
import 'package:users_app/models/predicted_places.dart';
import 'package:users_app/widgets/progress_dialog.dart';

import '../assistants/request_assistant.dart';

class PlacesPredictionTileDesign extends StatelessWidget {
  final PredictedPlaces? predictedPlaces;

  PlacesPredictionTileDesign({this.predictedPlaces});

  void getPlaceDirectionDetails(String? place_id,context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(message: "Setting up Dropoff")
    );

    // Create connection of api to fetch places Details
    String placesDirectionDetailUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$place_id&key=$mapKey";

    // Close the dialog
    Navigator.pop(context);

    var responseApi =  await RequestAssistant.ReceiveRequest(placesDirectionDetailUrl); // Receiving api Response

    if(responseApi == "Error fetching the request"){
      return;
    }

    if(responseApi["status"] == "OK"){
      Directions userDropOffAddress = Directions();
      userDropOffAddress.locationId = place_id;
      userDropOffAddress.locationName = responseApi["result"]["name"];
      userDropOffAddress.locationLatitude = responseApi["result"]["geometry"]["location"]["lat"];
      userDropOffAddress.locationLongitude = responseApi["result"]["geometry"]["location"]["lng"];

      Provider.of<AppInfo>(context,listen: false).updateDropOffLocationAddress(userDropOffAddress);
      Navigator.pop(context,"Obtained");
    }

  }



  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (){
        getPlaceDirectionDetails(predictedPlaces!.place_id,context);
      },

      style: ElevatedButton.styleFrom(
          primary: Colors.white
      ),

      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            const Icon(
              Icons.add_location,
              color: Colors.black,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    predictedPlaces!.main_text!,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    predictedPlaces!.secondary_text!,
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.black,
                    ),
                  ),

                ],
              ),
            )

          ],
        ),
      ),
    );
  }
}
