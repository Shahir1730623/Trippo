import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_app/global/map_key.dart';
import 'package:users_app/models/predicted_places.dart';
import 'package:users_app/widgets/placesPredictionTileDesign.dart';

import '../InfoHandler/app_info.dart';
import '../assistants/request_assistant.dart';

class SearchPlaces extends StatefulWidget {
  const SearchPlaces({Key? key}) : super(key: key);

  @override
  State<SearchPlaces> createState() => _SearchPlacesState();
}

class _SearchPlacesState extends State<SearchPlaces> {
  TextEditingController searchLocationTextEditingController = TextEditingController();
  List<PredictedPlaces> placesPredictedList = [];

  void findPlaceAutoCompleteSearch(String input) async {
    if(input.length > 1){
      // Create Api Url to fetch Addresses
      String urlAutoCompleteSearch = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$mapKey&components=country:BD";
      var responseAutoCompleteSearch =  await RequestAssistant.ReceiveRequest(urlAutoCompleteSearch);

      if(responseAutoCompleteSearch == "Error fetching the request"){
        return;
      }

      if(responseAutoCompleteSearch["status"] == "OK"){ // Response Successful
         var placesPredictions = responseAutoCompleteSearch["predictions"]; // JsonData

         // Converting all JsonData to List of model PredictedPlaces and storing in placesPredictionList
         var placesPredictionList =  (placesPredictions as List).map((jsonData) => PredictedPlaces.fromJson(jsonData)).toList();

         setState(() {
           placesPredictedList = placesPredictionList; // Storing all the list of places
         });
      }



    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Search Place UI
            Container(
              height: 210,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 5,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),

              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    Stack(
                      children: [
                        GestureDetector(
                          onTap: (){
                            // Return to Main Screen
                            Navigator.pop(context);
                          },

                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                        ),

                        const Center(
                          child: Text(
                            "Search Dropoff Location",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        const Icon(
                          Icons.adjust_sharp,
                          color: Colors.black,
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                                hintText: Provider.of<AppInfo>(context).userPickupLocation!=null ?
                                Provider.of<AppInfo>(context).userPickupLocation!.locationName!.substring(0,16)
                                    : "No Address found",
                                fillColor: Colors.grey.shade100,
                                filled: true,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade100,
                                    width: 1.5,
                                  ),
                                ),

                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade100,
                                  ),
                                ),

                                contentPadding: EdgeInsets.only(
                                    top: 8.0,
                                    bottom: 8.0,
                                    left: 10.0
                                )
                            ),

                          ),
                        ),

                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        const Icon(
                          Icons.adjust_sharp,
                          color: Colors.black,
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: TextFormField(
                            onChanged: (textTyped) {
                              findPlaceAutoCompleteSearch(textTyped);
                            },
                            decoration: InputDecoration(
                              hintText: "Where to?",
                              fillColor: Colors.grey.shade100,
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade100,
                                    width: 1.5,
                                  ),
                                ),

                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade100,
                                  ),
                              ),

                              contentPadding: const EdgeInsets.only(
                                top: 8.0,
                                bottom: 8.0,
                                left: 10.0
                              )
                            ),

                          ),
                        ),

                      ],
                    ),

                  ],
                ),
              ),

            ),

            // Display Place Predicted Results
            (placesPredictedList.length > 0)
                ? Expanded(
                    child: ListView.separated(
                      itemCount: placesPredictedList.length,
                      physics: const ClampingScrollPhysics(),

                      itemBuilder: (context, index){
                        return PlacesPredictionTileDesign(
                          predictedPlaces: placesPredictedList[index],
                        );
                      },

                      separatorBuilder: (BuildContext context, int index){
                        return const Divider(
                          height: 1,
                          color: Colors.black,
                          thickness: 1,
                        );
                      },
                    ),
            )
            : Container(),

          ],
        ));
  }
}
