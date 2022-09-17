import 'package:drivers_app/InfoHandler/app_info.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/splashScreen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({Key? key}) : super(key: key);

  @override
  _ProfileTabPageState createState() => _ProfileTabPageState();
}


class _ProfileTabPageState extends State<ProfileTabPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              Container(
                height: 150,
                decoration: const BoxDecoration(
                  color: Colors.black,
                ),
              ),

              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                      )
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const SizedBox(height: 60,),

                      Center(
                        child: Text(
                          driverData.name!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),


                      Center(
                        child: TextButton(
                          onPressed: () {
                           //
                          },
                          child: Text(
                              'Total Trips: ' + Provider.of<AppInfo>(context).countTotalTrips.toString() ,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.grey[600],
                              )
                          ),
                        ),
                      ),

                      const SizedBox(height: 40,),

                      // Name
                      Text(
                        "Name",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.grey[600]
                        ),
                      ),

                      const SizedBox(height: 15,),

                      // Name - Value
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                driverData.name!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),

                          const Icon(Icons.arrow_forward_ios),

                        ],
                      ),

                      const SizedBox(height: 2,),

                      const Divider(
                        thickness: 1,
                      ),

                      SizedBox(height: 10,),

                      // Email
                      Text(
                        "Email",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.grey[600]
                        ),
                      ),

                      const SizedBox(height: 15,),

                      // Email - value
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                driverData.email!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),

                          Icon(Icons.arrow_forward_ios),

                        ],
                      ),

                      SizedBox(height: 2,),

                      const Divider(
                        thickness: 1,
                      ),

                      const SizedBox(height: 10,),

                      Text(
                        "Phone Number",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.grey[600]
                        ),
                      ),

                      const SizedBox(height: 15,),

                      // Number - value
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                driverData.phone!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),

                          Icon(Icons.arrow_forward_ios),

                        ],
                      ),

                      SizedBox(height: 10,),

                      const Divider(
                        thickness: 1,
                      ),

                      SizedBox(height: 10,),

                      // Password
                      Text(
                        "Password",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.grey[600]
                        ),
                      ),

                      const SizedBox(height: 15,),

                      // Password - value
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text(
                                ".......",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),

                          Icon(Icons.arrow_forward_ios),

                        ],
                      ),

                      const SizedBox(height: 10,),

                    ],
                  ),
                ),
              ),



            ],
          ),

          Positioned(
            top: 100,
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                  border: Border.all(
                    width: 2,
                    color: Colors.white,
                  )
              ),
              child: Icon(Icons.person),
            ),
          ),



        ],
      ),
    );
  }
}
