import 'package:hive/hive.dart';
part 'markers_category_model.g.dart';

@HiveType(typeId: 2)

class MyMarkersCategory extends HiveObject {

  MyMarkersCategory({
    this.markerCategoryTitle,
    this.markerCategoryDescription
  });

  @HiveField(0)
  String? markerCategoryTitle;

  @HiveField(1)
  String? markerCategoryDescription;

}
