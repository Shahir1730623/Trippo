import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class RequestAssistant{

  static Future<dynamic> ReceiveRequest(String url) async {

    try{
      http.Response httpResponse = await http.get(Uri.parse(url)); //Fetching the Response/ JsonData of this address

      if(httpResponse.statusCode == 200){ // Response is successful
        var decodedResponseData = jsonDecode(httpResponse.body);
        return decodedResponseData; // Returning the human readable address
      }

      else{
        return "Error fetching the request";
      }
    }

    catch(error){
      return "Error fetching the request";
    }

  }


}