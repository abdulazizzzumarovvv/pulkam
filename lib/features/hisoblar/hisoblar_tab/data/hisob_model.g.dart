// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hisob_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HisobModelAdapter extends TypeAdapter<HisobModel> {
  @override
  final int typeId = 0;

  @override
  HisobModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HisobModel(
      name: fields[0] as String,
      balance: fields[1] as String,
      iconCode: fields[2] as int,
      colorValue: fields[3] as int,
      defaultKey: fields[4] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, HisobModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.balance)
      ..writeByte(2)
      ..write(obj.iconCode)
      ..writeByte(3)
      ..write(obj.colorValue)
      ..writeByte(4)
      ..write(obj.defaultKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HisobModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
