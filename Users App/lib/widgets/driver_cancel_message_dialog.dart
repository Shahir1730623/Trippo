import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DriverCancelMessageDialog extends StatefulWidget {
  const DriverCancelMessageDialog({Key? key}) : super(key: key);

  @override
  State<DriverCancelMessageDialog> createState() => _DriverCancelMessageDialogState();
}

class _DriverCancelMessageDialogState extends State<DriverCancelMessageDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5)
      ),
      backgroundColor: Colors.black,
      child: Container(
        margin: EdgeInsets.all(6),
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6)
        ),

        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Trip Message",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Driver has cancelled your trip",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Ride Status:\n Cancelled",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.black
                ),
              ),
              const SizedBox(height: 40),

              const Divider(
                height: 1,
                thickness: 1,
                color: Colors.black,
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  onPressed: (){
                    SystemNavigator.pop();
                  },

                  style: ElevatedButton.styleFrom(
                      primary: const Color.fromRGBO(0 , 177 , 118, 1)
                  ),

                  child: const Text(
                    "Okay",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),
                  ),
                ),
              )

            ],
          ),
        ),

      ),
    );
  }
}
