import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive/hive.dart';
import 'package:latlong_to_osgrid/latlong_to_osgrid.dart';



import 'markers_model.dart';
import 'package:intl/intl.dart';

class MyMarkersList extends StatefulWidget {
  const MyMarkersList({Key? key}) : super(key: key);

  @override
  State<MyMarkersList> createState() => _MyMarkersListState();
}

LatLongConverter converter = LatLongConverter();


class _MyMarkersListState extends State<MyMarkersList> {
  @override
  Widget build(BuildContext context) {
    final markersList = Hive.box('myMarkersBox');
    return Scaffold(backgroundColor: HexColor('#C1D96C'),
      body: Container(
        child: ListView.builder(
            itemCount: markersList.length,
            itemBuilder: (BuildContext context, int index){

              final marker = markersList.getAt(index) as MyMarkers;
              final latDms = converter.getDegreeFromDecimal(marker.lat!);
              final longDms = converter.getDegreeFromDecimal(marker.long!);


              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 4,
                margin: EdgeInsets.all(10),
                color: HexColor('#733439'),
                child: Column(
                  children: <Widget>[
                  Stack(
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Column(mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${marker.name}',style: TextStyle(fontSize: 20,color: HexColor('#049DBF'),fontWeight: FontWeight.w500),),
                                const Padding(
                                  padding: EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 15),
                                  child: Divider(height: 1,color: Colors.black,),
                                )
                                  ],
                            ),
                          ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 35),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Column(
                            children: [
                                Column(crossAxisAlignment:CrossAxisAlignment.start ,children: [
                                Text("Lat: ${latDms?[0]}° ${latDms?[1]}' ${latDms?[2].toString().substring(0,7)}\"",style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: HexColor('#F2C36B')),),
                                Text('DD: ${marker.lat}',style: TextStyle(fontSize: 13,color: HexColor('#ADD4D9').withAlpha(180)),),
                                                           ],),],
                          ),
                          Column(children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(alignment: Alignment.centerRight ,
                                child: FaIcon(FontAwesomeIcons.pen,color: HexColor('#F2C36B').withAlpha(180))
                                //child: Text('UPRAVIŤ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),)
                                ),
                            )],),
                        ],
                        ),
                  ),
                     const SizedBox(height: 5,),
                             Padding(
                            padding: const EdgeInsets.only(left: 30, right: 35),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Column(crossAxisAlignment:CrossAxisAlignment.start ,children: [
                                      Text("Long: ${longDms?[0]}° ${longDms?[1]}' ${longDms?[2].toString().substring(0,7)}\"",style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: HexColor('#F2C36B')),),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 3),
                                        child: Text('DD: ${marker.long}',style: TextStyle(fontSize: 13,color: HexColor('#ADD4D9').withAlpha(180)),),
                                      ),
                                    ],),
                                  ],
                                ),
                                Column(children: [Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: FaIcon(FontAwesomeIcons.trashCan, color: HexColor('#ADD4D9'),)
                                  //child: Text('ZMAZAŤ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),),
                                )],),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 15),
                            child: Divider(height: 1,color: Colors.black,),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(left: 60, bottom: 8, right: 60),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Column(
                                children: [
                                  Row(children: [
                                    FaIcon(FontAwesomeIcons.mountainSun,color: HexColor('#ADD4D9'),size: 18,),
                                    const SizedBox(width: 10,),
                                    Text('${marker.altitude?.toStringAsFixed(2)} m', style: TextStyle(color: HexColor('#ADD4D9')),)
                                  ],),
                                ],
                              ),

                              Column(
                                children: [
                                  Row(children: [
                                    FaIcon(FontAwesomeIcons.ruler,color: HexColor('#ADD4D9'),size: 18,),
                                    const SizedBox(width: 10,),
                                    Text('${marker.accuracy?.toStringAsFixed(2)} m', style: TextStyle(color: HexColor('#ADD4D9')),)
                                  ],),
                                ],
                              ),
                            ],
                            ),
                          ),

                          const Padding(
                            padding: EdgeInsets.only(bottom: 8, left: 30, right: 30),
                            child: Divider(height: 1,color: Colors.black,),
                          ),

                          Row( mainAxisAlignment: MainAxisAlignment.center,children: [
                            Column(children: [
                              Row(children: [
                                Text('${marker.street}', style: const TextStyle(color: Colors.white70))
                              ],
                                 ),
                           Row(children: [Text('${marker.zip} ${marker.city}', style: const TextStyle(color: Colors.white70),)
                           ],
                           ),
                              Row(children: [Text('${marker.state}', style: const TextStyle(color: Colors.white70))
                              ],
                              ),

                            ],


                            ),
                          ],
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 15, bottom: 10),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(DateFormat().format(marker.dateTime!),style: const TextStyle(fontSize: 15,color: Colors.white),),
                              ],
                            ),
                          )
                    ],
                  )





                      ],),

                ],) ,
                // title: Text('${marker.name}'),
                // subtitle: Text('${marker.dateTime}'),
              );

            }),
      ),
    );
  }
}
