// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gesture.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GestureAdapter extends TypeAdapter<Gesture> {
  @override
  final int typeId = 0;

  @override
  Gesture read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Gesture(
      objectKey: fields[0] as String,
      objectValue: fields[1] as String,
      objectUse: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Gesture obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.objectKey)
      ..writeByte(1)
      ..write(obj.objectValue)
      ..writeByte(2)
      ..write(obj.objectUse);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GestureAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
