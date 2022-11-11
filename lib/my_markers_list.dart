import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'markers_model.dart';

class MyMarkersList extends StatefulWidget {
  const MyMarkersList({Key? key}) : super(key: key);

  @override
  State<MyMarkersList> createState() => _MyMarkersListState();
}

class _MyMarkersListState extends State<MyMarkersList> {
  @override
  Widget build(BuildContext context) {
    final markersList = Hive.box('myMarkersBox');
    return Scaffold(
      body: Container(
        child: ListView.builder(
            itemCount: markersList.length,
            itemBuilder: (BuildContext context, int index){
              final marker = markersList.getAt(index) as MyMarkers;
              return ListTile(
                title: Text('${marker.name}'),
                subtitle: Text('${marker.dateTime}'),
              );

            }),
      ),
    );
  }
}
