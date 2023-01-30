import 'package:flutter/cupertino.dart';

import 'markers_category_model.dart';

class CategoryProvider with ChangeNotifier {

  List<MyMarkersCategory> _categoryList = <MyMarkersCategory>[];

    void initialValues() {
    _categoryList = <MyMarkersCategory>[];
    notifyListeners();
  }

  // Favorite movies (that will be shown on the MyList screen)
  final List<MyMarkersCategory> _myCategoryList = [];


  // Retrieve favorite movies
  List<MyMarkersCategory> get myCategoryList => _myCategoryList;


  // Adding a movie to the favorites list
  Future<void> addToCategoryList(MyMarkersCategory category) async {
    print('CATEGORY.KEY to ADD: ${category.key}');
    _myCategoryList.add(category);
     notifyListeners();
  }

  Future<void> updateCategoryList(MyMarkersCategory category, int categoryKey) async {
    print('CATEGORY.KEY: ${categoryKey}');
    for (var i=0; i<_myCategoryList.length; i++){
    print('myCategoryList.KEY: ${_myCategoryList[i].key}');}

    _myCategoryList.removeWhere((element) => element.key == categoryKey);
    //_myCategoryList.add(category);

    for (var i=0; i<_myCategoryList.length; i++){
      print('myCategoryList.KEY2: ${_myCategoryList[i].key}');}

    notifyListeners();
  }

    // Removing a movie from the favorites list
  Future<void> removeFromList(MyMarkersCategory category) async {
    _myCategoryList.removeWhere((element) => element.key == category.key);
   notifyListeners();
  }
}