import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

import 'category_provider.dart';
import 'edit_category_record.dart';
import 'markers_category_model.dart';

class MarkerCategories extends StatefulWidget {
  const MarkerCategories({Key? key}) : super(key: key);

  @override
  State<MarkerCategories> createState() => _MarkerCategoriesState();
}

class _MarkerCategoriesState extends State<MarkerCategories> {


  late Box<MyMarkersCategory> myMarkersCategoryList;
  final TextEditingController markerCategoryTitleController = TextEditingController();
  final TextEditingController markerCategoryDescriptionController = TextEditingController();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myMarkersCategoryList = Hive.box<MyMarkersCategory>('myMarkersCategoryBox');
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(backgroundColor: HexColor('#899b81'),
      floatingActionButton: FloatingActionButton(onPressed: () {

        showDialog(
            context: context,
            builder: (ctx) => Dialog(

                backgroundColor: Colors.blueGrey[100],
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        decoration: InputDecoration(hintText: "Title"),
                        controller: markerCategoryTitleController,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      TextField(
                        decoration: InputDecoration(hintText: "Description"),
                        controller: markerCategoryDescriptionController,maxLines: 6, minLines:1
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      TextButton(
                        child: Text("Add Data",style: TextStyle(color: Colors.white),),
                        onPressed: () {
                          final String title = markerCategoryTitleController.text;
                          final String description = markerCategoryDescriptionController.text;
                          markerCategoryTitleController.clear();
                          markerCategoryDescriptionController.clear();
                          MyMarkersCategory data = MyMarkersCategory(markerCategoryTitle: title, markerCategoryDescription: description);
                          myMarkersCategoryList.add(data);
                          Provider.of<CategoryProvider>(context, listen: false).addToCategoryList(data);
                          Navigator.pop(context);

                        },
                      )
                    ],
                  ),
                )
            )
        );



      },child: Icon(Icons.add),


      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ValueListenableBuilder(valueListenable: myMarkersCategoryList.listenable(),
                builder: (context, Box<MyMarkersCategory> markersCategoryItems, Widget? child){
              myMarkersCategoryList = markersCategoryItems;
              return Container(height: MediaQuery.of(context).size.height, width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                    itemCount: myMarkersCategoryList.values.length,
                    itemBuilder: (BuildContext context, int index){
                      final category = myMarkersCategoryList.getAt(index) as MyMarkersCategory;
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        elevation: 4,
                        margin: const EdgeInsets.all(10),
                        color: Colors.white.withOpacity(0.5),
                        child: Column(children: [
                          //Text('${category.key}'),
                          Padding(
                            padding: const EdgeInsets.only(top: 15,bottom: 15,left: 10,right: 10),
                            child: Text('${category.markerCategoryTitle}',style: TextStyle(fontSize: 20,color: HexColor('#8C4332'),fontWeight: FontWeight.w600)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15,right: 15,bottom: 0),
                            child: Text('${category.markerCategoryDescription}',style: TextStyle(fontSize: 15,color: HexColor('#0c0c0c'),fontWeight: FontWeight.w300)),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(left: 20,right: 20,top: 15,bottom: 10),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              IconButton(padding: EdgeInsets.zero, constraints: BoxConstraints(),highlightColor: Colors.red,color: Colors.black54, onPressed: () {myMarkersCategoryList.deleteAt(index);  Provider.of<CategoryProvider>(context, listen: false).removeFromList(category); }, icon: const FaIcon(FontAwesomeIcons.trashCan,size: 20,color: Colors.red),),
                              IconButton(padding: EdgeInsets.zero, constraints: BoxConstraints(),highlightColor: Colors.green,color: Colors.black54, onPressed: () {print('${category.key}');Navigator.push(context, MaterialPageRoute(builder: (context) => EditCategoryRecord(index: index, category: category, categoryKey: category.key,))); }, icon: FaIcon(FontAwesomeIcons.pencil,size: 20,color: HexColor('#3B592D'),),),

                            ],),
                          )
                        ],),
                      );
                }),
              );
              
                          
              
            })
         
        ],),
      ),





    );
  }
}
