import 'package:hive/hive.dart';
part 'markers_model.g.dart';



@HiveType(typeId: 1)

class MyMarkers extends HiveObject {

  MyMarkers({
    this.dateTime,
    this.name,
    this.description,
    this.lat,
    this.long,
    this.altitude,
    this.accuracy,
    this.street,
    this.city,
    this.county,
    this.state,
    this.zip,
    this.administrativeArea,
    this.subLocality,
    this.countryCode,
    this.markerCategory,
    this.markerCategoryKey
  });

  @HiveField(0)
  DateTime? dateTime;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  double? lat;

  @HiveField(4)
  double? long;

  @HiveField(5)
  double? altitude;

  @HiveField(6)
  double? accuracy;

  @HiveField(7)
  String? street;

  @HiveField(8)
  String? city;

  @HiveField(9)
  String? county;

  @HiveField(10)
  String? state;

  @HiveField(11)
  String? zip;

  @HiveField(12)
  String? subLocality;

  @HiveField(13)
  String? administrativeArea;

  @HiveField(14)
  String? countryCode;

  @HiveField(15)
  String? markerCategory;

  @HiveField(16)
  int? markerCategoryKey;
}
