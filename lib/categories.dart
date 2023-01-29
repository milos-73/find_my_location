import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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


    return Scaffold(
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
                        controller: markerCategoryDescriptionController,
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
                          Text('${category.markerCategoryTitle}'),
                          Text('${category.markerCategoryDescription}'),

                          Row(children: [
                            Column(children: [
                              IconButton(highlightColor: Colors.green,color: Colors.black54, onPressed: () {Provider.of<CategoryProvider>(context, listen: false).removeFromList(category); Navigator.push(context, MaterialPageRoute(builder: (context) => EditCategoryRecord(index: index, category: category))); }, icon: const FaIcon(FontAwesomeIcons.pencil),),
                              IconButton(highlightColor: Colors.red,color: Colors.black54, onPressed: () {myMarkersCategoryList.deleteAt(index);  Provider.of<CategoryProvider>(context, listen: false).removeFromList(category); }, icon: const FaIcon(FontAwesomeIcons.trashCan),),
                            ],)
                          ],)
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
