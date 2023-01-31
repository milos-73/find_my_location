import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

import '../categories.dart';
import '../category_provider.dart';
import '../edit_category_record.dart';
import '../markers_category_model.dart';
import '../markers_model.dart';

class CategoryPickerDialog extends StatefulWidget {

  const CategoryPickerDialog({
    Key? key,
  }) : super(key: key);


  @override
  State<CategoryPickerDialog> createState() => _CategoryPickerDialogState();
}

class _CategoryPickerDialogState extends State<CategoryPickerDialog> {


  late Box<MyMarkers> myMarkersBox;
  late Box<MyMarkersCategory> myCategoryBox;

  String? categoryTitle;
  String? categoryKey;
  String? selectedRadio;

  @override
  void initState() {
    super.initState();
    selectedRadio = '';
    myMarkersBox = Hive.box('myMarkersBox');
    myCategoryBox = Hive.box('myMarkersCategoryBox');
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
          Padding(
            padding: const EdgeInsets.only(left: 10,right: 10),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Radio(activeColor: Colors.green,
                    value: 'Uncategorized',
                    groupValue: selectedRadio,
                    onChanged: (val) {
                      print(val);
                      setSelectedRadio(val!);
                      Navigator.pop(context, 'uncategorized');
                    }),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text('Uncategorized',
                      softWrap: true,
                      overflow: TextOverflow.fade,
                      maxLines: 1,),
                  ),
                ),
                //Text('${categories?.key!}'),


              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 10,right: 10),
            child:   Divider(height: 4,),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 10,right: 10),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Radio(activeColor: Colors.green,
                    value: 'Show All',
                    groupValue: selectedRadio,
                    onChanged: (val) {
                      print(val);
                      setSelectedRadio(val!);
                      Navigator.pop(context, '');
                    }),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text('Show All',
                      softWrap: true,
                      overflow: TextOverflow.fade,
                      maxLines: 1,style: TextStyle(fontWeight: FontWeight.w500),),

                  ),
                ),
                //Text('${categories?.key!}'),


              ],
            ),
          ),
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
                            value: categories?.markerCategoryTitle,
                            groupValue: selectedRadio,
                            onChanged: (val) {
                              print(val);
                              setSelectedRadio(val!);
                              Navigator.pop(context, selectedRadio);
                            }),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(categories?.markerCategoryTitle ?? '',
                              softWrap: true,
                              overflow: TextOverflow.fade,
                              maxLines: 2,),
                          ),
                        ),
                        //Text('${categories?.key!}'),
                        IconButton(onPressed: () {
                          //Provider.of<CategoryProvider>(context, listen: false).removeFromList(categories!);
                          myCategoryBox.delete(categories?.key);
                        },
                          icon: FaIcon(FontAwesomeIcons.trashCan, size: 15,),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),color: Colors.red,),
                        Padding(
                          padding: const EdgeInsets.only(left: 10,right: 10),
                          child: IconButton(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => EditCategoryRecord(index: index, category: categories!, categoryKey: categories.key,)));},
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
                Navigator.pop(context, '');
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