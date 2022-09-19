import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PayFareDialog extends StatefulWidget {

  double? fareAmount;

  PayFareDialog({this.fareAmount});

  @override
  State<PayFareDialog> createState() => _PayFareDialogState();
}

class _PayFareDialogState extends State<PayFareDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5)
      ),
      backgroundColor: Color.fromRGBO(0 , 177 , 118, 1),
      child: Container(
        margin: EdgeInsets.all(6),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color.fromRGBO(0 , 177 , 118, 1),
          borderRadius: BorderRadius.circular(6)
        ),

        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Trip Fare Amount",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Pay Driver",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                ),
              ),

              const SizedBox(height: 10),

              Text(
                widget.fareAmount.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 60,
                    color: Colors.white
                ),
              ),
              const SizedBox(height: 40),

              const Divider(
                height: 1,
                thickness: 1,
                color: Colors.white,
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  onPressed: (){
                    // If the pay cash button is pressed
                    Navigator.pop(context,"Cash Paid");
                  },

                  style: ElevatedButton.styleFrom(
                    primary: Colors.redAccent
                  ),

                  child: const Text(
                    "Pay cash",
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
