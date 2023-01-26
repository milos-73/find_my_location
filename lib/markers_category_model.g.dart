// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'markers_category_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MyMarkersCategoryAdapter extends TypeAdapter<MyMarkersCategory> {
  @override
  final int typeId = 2;

  @override
  MyMarkersCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MyMarkersCategory(
      markerCategoryTitle: fields[0] as String?,
      markerCategoryDescription: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MyMarkersCategory obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.markerCategoryTitle)
      ..writeByte(1)
      ..write(obj.markerCategoryDescription);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyMarkersCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
