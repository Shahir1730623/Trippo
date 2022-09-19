import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:users_app/global/global.dart';
import 'package:users_app/mainScreens/profile_screen.dart';
import 'package:users_app/mainScreens/trip_history_screen.dart';

class DashboardDrawer extends StatefulWidget {
  String? name;

  DashboardDrawer({this.name});

  @override
  State<DashboardDrawer> createState() => _DashboardDrawerState();
}

class _DashboardDrawerState extends State<DashboardDrawer> {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Container(
            height: 165,
            color: Colors.black,
            child: DrawerHeader(
              decoration: const BoxDecoration(color: Colors.black),
              child: Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.white,
                  ),

                  const SizedBox(width: 16),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.name.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      ),

                    ],
                  )
                ],
              ),

            ),
          ),

          const SizedBox(height: 12),

          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => const TripHistoryScreen()));
            },

            child: const ListTile(
              leading: Icon(Icons.history, color: Colors.black),
              title: Text(
                "History",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16
                ),
              ),
            ),
          ),

          GestureDetector(
            onTap: (){

            },

            child: const ListTile(
              leading: Icon(Icons.local_offer, color: Colors.black),
              title: Text(
                "Promos",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                ),
              ),
            ),
          ),

          GestureDetector(
            onTap: (){

            },

            child: const ListTile(
              leading: Icon(Icons.notifications, color: Colors.black),
              title: Text(
                "Notifications",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                ),
              ),
            ),
          ),

          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
            },

            child: const ListTile(
              leading: Icon(Icons.person, color: Colors.black),
              title: Text(
                "Profile",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                ),
              ),
            ),
          ),

          GestureDetector(
            onTap: (){

            },

            child: const ListTile(
              leading: Icon(Icons.info, color: Colors.black),
              title: Text(
                "About Us",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                ),
              ),
            ),
          ),

          GestureDetector(
            onTap: (){
              //Signout
              firebaseAuth.signOut();
              Navigator.pushNamed(context, '/');
            },

            child: const ListTile(
              leading: Icon(Icons.logout, color: Colors.black),
              title: Text(
                "Sign Out",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                ),
              ),
            ),
          ),



        ],
      ),
    );
  }
}
