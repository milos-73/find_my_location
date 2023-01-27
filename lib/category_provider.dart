import 'package:flutter/cupertino.dart';

import 'markers_category_model.dart';

class CategoryProvider with ChangeNotifier {

  List<String> _categoryList = <String>[];

    void initialValues() {
    _categoryList = <String>[];
    notifyListeners();
  }

  // Favorite movies (that will be shown on the MyList screen)
  final List<String> _myCategoryList = [];


  // Retrieve favorite movies
  List<String> get myCategoryList => _myCategoryList;

  // Adding a movie to the favorites list
  Future<void> addToCategoryList(String categoryTitle) async {
    _myCategoryList.add(categoryTitle);
     notifyListeners();
  }

    // Removing a movie from the favorites list
  Future<void> removeFromList(String categoryTitle) async {
    _myCategoryList.remove(categoryTitle);
   notifyListeners();
  }
}