import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive_flutter/adapters.dart';

import '../categories.dart';
import '../edit_category_record.dart';
import '../edit_record.dart';
import '../markers_category_model.dart';
import '../markers_model.dart';

class CategoryPickerDialogEditMarker extends StatefulWidget {

  final int markerIndex;
  final MyMarkers marker;
  final double? markerLat;
  final double? markerLong;
  MapController mapController;

  CategoryPickerDialogEditMarker({
    Key? key, required this.markerIndex, required this.marker, required this.mapController,this.markerLong,this.markerLat
  }) : super(key: key);


  @override
  State<CategoryPickerDialogEditMarker> createState() => _CategoryPickerDialogEditMarkerState();
}

class _CategoryPickerDialogEditMarkerState extends State<CategoryPickerDialogEditMarker> {


  late Box<MyMarkers> myMarkersBox;
  late Box<MyMarkersCategory> myCategoryBox;

  String? categoryTitle;
  String? categoryKey;
  String? selectedRadio;
  String? editedCategoryTitle;

  @override
  void initState() {
    super.initState();
    selectedRadio = '';
    myMarkersBox = Hive.box('myMarkersBox');
    myCategoryBox = Hive.box('myMarkersCategoryBox');
    categoryKey = widget.marker.markerCategoryKey;
  }

  // Changes the selected value on 'onChanged' click on each radio button
  setSelectedRadio(String val) {
    setState(() {
      selectedRadio = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    //final categoryItemList = context.watch<CategoryProvider>().myCategoryList;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(color: HexColor('#d8ded5'),
          width: 200,  child:

          myCategoryBox.length < 0 ?

          Column(children: [
            Text('No category set up'),
          ],) :
          Container(width: double.maxFinite,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(top: 20,left: 15,right: 15,bottom: 0),
                child: Text('Select a category'.toUpperCase(),style: TextStyle(fontSize: 20,color: HexColor('#8C4332'),fontWeight: FontWeight.w500),),
              ),
              TextButton(onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const MarkerCategories()));
              },
                  child: Text('Add new category'.toUpperCase())),


              Padding(
                padding: const EdgeInsets.only(left: 10,right: 10),
                child:   Divider(height: 4,),
              ),

              Container(
                child: Expanded(
                  child: ValueListenableBuilder(
                      valueListenable: myCategoryBox.listenable(),

                      builder: (BuildContext context, Box<MyMarkersCategory> myCategories, Widget? child) {

                        List<int> markerCategoryKeys;

                        markerCategoryKeys = myCategories.keys.cast<int>().toList();




                        return ListView.builder(
                            itemCount: markerCategoryKeys.length,
                            itemBuilder: (context, int index) {

                              final int key = markerCategoryKeys[index];
                              final MyMarkersCategory? categories = myCategories.get(key);

                              if (index == 1000)  {return SizedBox();} else {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 10, right: 10),
                                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Radio(activeColor: Colors.green,
                                          value: categories?.key.toString(),
                                          groupValue: selectedRadio,
                                          onChanged: (val) {
                                            print(val);
                                            setSelectedRadio(val!);
                                            Navigator.pop(context, selectedRadio);
                                          }),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Text(categories?.markerCategoryTitle ?? 'No Title',
                                            softWrap: true,
                                            overflow: TextOverflow.fade,
                                            maxLines: 2,),
                                        ),
                                      ),
                                      //Text('${categories?.key!}'),
                                      IconButton(onPressed: () {
                                        //Provider.of<CategoryProvider>(context, listen: false).removeFromList(categories!);

                                        final markerCategoryKeyUpdate = MyMarkers(dateTime: widget.marker.dateTime, name: widget.marker.name, description: widget.marker.description, lat: double.parse('${widget.marker.lat}') , long: double.parse('${widget.marker.long}'), altitude: double.parse('${widget.marker.altitude}'), accuracy: double.parse('${widget.marker.accuracy}'), street: widget.marker.street, city: widget.marker.city, county: widget.marker.county, state: widget.marker.state,zip: widget.marker.zip,  countryCode: widget.marker.countryCode, subLocality: widget.marker.subLocality, administrativeArea: widget.marker.administrativeArea, markerCategory: 'uncategorized',markerCategoryKey: '000');
                                        myMarkersBox.put(widget.marker.key, markerCategoryKeyUpdate);
                                        myCategoryBox.delete(categories?.key);


                                        //final markerCategoryKeyupdate = MyMarkers(dateTime: DateTime.now(), name: nameController.text, description: descriptionController.text, lat: double.parse(latitudeController.text) , long: double.parse(longitudeController.text), altitude: double.parse(altitudeController.text), accuracy: double.parse(accuracyController.text), street: streetController.text, city: townController.text, county: countyController.text, state: stateController.text,zip: zipController.text,  countryCode: countryCodeController.text, subLocality: subLocalityController.text, administrativeArea: administrativeAreaController.text, markerCategory: markerCategoryTitleController.text,markerCategoryKey: myMarkerCategoryKey ?? '');
                                        setState(() {
                                          categoryKey = '000';
                                        });

                                      },
                                        icon: FaIcon(FontAwesomeIcons.trashCan, size: 15,),
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(),color: Colors.red,),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10,right: 10),
                                        child: IconButton(onPressed: () async {String? newCategoryTitle = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditCategoryRecord(index: index, category: categories!, categoryKey: categories.key)));


                                          setState(() {
                                            editedCategoryTitle = newCategoryTitle;
                                          });
                                          },
                                          icon: FaIcon(FontAwesomeIcons.pencil, size: 15,),
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),color: HexColor('#3B592D'),),
                                      ),

                                    ],
                                  ),
                                );
                              }});
                      }
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  ElevatedButton(style: ElevatedButton.styleFrom(foregroundColor: HexColor('#f0d8c3'), backgroundColor: HexColor('#8C4332') ),onPressed: () {
                    
                   // if (editedCategoryTitle == widget.categoryTitle) {
                   //   print('oldCategoryTitle: ${widget.categoryTitle}');
                   //   Navigator.pop(context,);
                   // } else {
                   //   print('editedCategoryTitle: ${editedCategoryTitle}');
                   //  print('edited CATEGORY title: $editedCategoryTitle');
                   //  print('edited CATEGORY key: $categoryKey');
                   //  print('original CATEGORY title: ${widget.marker.markerCategory}');
                   //  print('original CATEGORY key: ${widget.marker.markerCategoryKey}');
                   //  print('selected radio: ${widget.marker.markerCategoryKey}');
                    //Navigator.pop(context, widget.marker.markerCategoryKey);
                    Navigator.pop(context, categoryKey);
                   //                      }

                    //Navigator.push(context, MaterialPageRoute(builder: (context) => EditRecord(index: widget.markerIndex, marker: widget.marker, markerLat: widget.markerLat,markerLong: widget.markerLong, mapController: widget.mapController)));
                  }, child: Text('Cancel')),
                  //ElevatedButton(onPressed:() {Navigator.pop(context,selectedRadio);}, child: Text('Confirm'))
                ],),
              )

            ],),
          )
      ),
    );
  }
}