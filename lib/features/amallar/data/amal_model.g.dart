// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'amal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AmalModelAdapter extends TypeAdapter<AmalModel> {
  @override
  final int typeId = 3;

  @override
  AmalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AmalModel(
      kategoriyaName: fields[0] as String,
      amount: fields[1] as String,
      kategoriyaIconCode: fields[2] as int,
      kategoriyaColorValue: fields[3] as int,
      hisobName: fields[4] as String,
      isKirim: fields[5] as bool,
      timestamp: fields[6] as int,
      isTransfer: fields[7] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, AmalModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.kategoriyaName)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.kategoriyaIconCode)
      ..writeByte(3)
      ..write(obj.kategoriyaColorValue)
      ..writeByte(4)
      ..write(obj.hisobName)
      ..writeByte(5)
      ..write(obj.isKirim)
      ..writeByte(6)
      ..write(obj.timestamp)
      ..writeByte(7)
      ..write(obj.isTransfer);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AmalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
