import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_app/InfoHandler/app_info.dart';

import '../global/global.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
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
                          currentUserInfo!.name!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),


                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                          },
                          child: Text(
                              'Total Trips: ' + Provider.of<AppInfo>(context,listen: false).countTotalTrips!.toString(),
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
                                currentUserInfo!.name!,
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
                                currentUserInfo!.email!,
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
                                currentUserInfo!.phone!,
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
