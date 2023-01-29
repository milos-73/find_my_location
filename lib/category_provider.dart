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
    _myCategoryList.add(category);
     notifyListeners();
  }

    // Removing a movie from the favorites list
  Future<void> removeFromList(MyMarkersCategory category) async {
    _myCategoryList.remove(category);
   notifyListeners();
  }
}