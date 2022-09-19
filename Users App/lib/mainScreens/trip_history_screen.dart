import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:users_app/widgets/history_design_UI.dart';

import '../InfoHandler/app_info.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
            "Ride History"
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: ()
          {
            SystemNavigator.pop();
          },
        ),
      ),

      body: ListView.separated(separatorBuilder: (context, i)=> const Divider(
          color: Colors.white,
          thickness: 1,
          height: 1,
        ),

        itemCount: Provider.of<AppInfo>(context, listen: false).historyInformationList.length,
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,

        itemBuilder: (context, i) {
          return Card(
            color: Colors.white54,
            child: HistoryDesignUI(
              tripHistoryModel: Provider.of<AppInfo>(context, listen: false).historyInformationList[i],
            ),
          );
        },

      ),
    );
  }
}
