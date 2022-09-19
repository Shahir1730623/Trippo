import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:users_app/global/global.dart';
import 'package:users_app/mainScreens/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
                decoration: BoxDecoration(
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

                      SizedBox(height: 8,),

                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                          },
                          child: Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.grey[600],
                              )
                          ),
                        ),
                      ),

                     const SizedBox(height: 20,),

                      const Text(
                        'FAVOURITES',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 20,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.home,size: 30,color: Colors.grey[400]),

                              SizedBox(width: 15,),

                              const Text(
                                'Home',
                                style: TextStyle(
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

                      Divider(
                        thickness: 1,
                      ),

                      SizedBox(height: 10,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.work,size: 30,color: Colors.grey[400],),

                              SizedBox(width: 15,),

                              Text(
                                'Work',
                                style: TextStyle(
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

                      Divider(
                        thickness: 1,
                      ),

                      SizedBox(height: 10,),

                      Text(
                        'FAVOURITES',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),

                      SizedBox(height: 20,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Notifications',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),

                          Icon(Icons.notifications),
                        ],
                      ),

                      SizedBox(height: 10,),

                      Divider(
                        thickness: 1,
                      ),

                      SizedBox(height: 10,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Payment Method',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),

                          Icon(Icons.arrow_forward_ios),
                        ],
                      ),

                      SizedBox(height: 10,),

                      Divider(
                        thickness: 1,
                      ),

                      SizedBox(height: 10,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'My Rewards',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),

                          Icon(Icons.arrow_forward_ios),
                        ],
                      ),

                      const SizedBox(height: 10,),

                      Divider(
                        thickness: 1,
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
