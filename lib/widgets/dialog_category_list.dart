import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
      child: Container(
          width: 200, height: 400, child:

      myCategoryBox.length < 0 ?

      Column(children: [
        Text('No category set up'),
      ],) :
      Container(width: double.maxFinite,
        child: Column(children: [
          Text('Some Categories in list'),
          TextButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => const MarkerCategories()));
          }, child: Text('Add category')),
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
                        Text('${categories?.key!}'),
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: IconButton(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => EditCategoryRecord(index: index, category: categories!, categoryKey: categories.key,)));},
                            icon: FaIcon(FontAwesomeIcons.pencil, size: 15,),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),),
                        ),
                        IconButton(onPressed: () {
                          Provider.of<CategoryProvider>(context, listen: false).removeFromList(categories!);
                          myCategoryBox.delete(categories.key);
                        },
                          icon: FaIcon(FontAwesomeIcons.trashCan, size: 15,),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),),

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
              ElevatedButton(onPressed: () {
                Navigator.pop(context);
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