// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'markers_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MyMarkersAdapter extends TypeAdapter<MyMarkers> {
  @override
  final int typeId = 1;

  @override
  MyMarkers read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MyMarkers(
      dateTime: fields[0] as DateTime?,
      name: fields[1] as String?,
      description: fields[2] as String?,
      lat: fields[3] as double?,
      long: fields[4] as double?,
      altitude: fields[5] as double?,
      accuracy: fields[6] as double?,
      street: fields[7] as String?,
      city: fields[8] as String?,
      county: fields[9] as String?,
      state: fields[10] as String?,
      zip: fields[11] as String?,
      administrativeArea: fields[13] as String?,
      subLocality: fields[12] as String?,
      countryCode: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MyMarkers obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.dateTime)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.lat)
      ..writeByte(4)
      ..write(obj.long)
      ..writeByte(5)
      ..write(obj.altitude)
      ..writeByte(6)
      ..write(obj.accuracy)
      ..writeByte(7)
      ..write(obj.street)
      ..writeByte(8)
      ..write(obj.city)
      ..writeByte(9)
      ..write(obj.county)
      ..writeByte(10)
      ..write(obj.state)
      ..writeByte(11)
      ..write(obj.zip)
      ..writeByte(12)
      ..write(obj.subLocality)
      ..writeByte(13)
      ..write(obj.administrativeArea)
      ..writeByte(14)
      ..write(obj.countryCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyMarkersAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
