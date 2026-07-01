// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kategoriya_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KategoriyaModelAdapter extends TypeAdapter<KategoriyaModel> {
  @override
  final int typeId = 2;

  @override
  KategoriyaModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KategoriyaModel(
      name: fields[0] as String,
      iconCode: fields[1] as int,
      colorValue: fields[2] as int,
      turi: fields[3] as String,
      amount: fields[4] as String,
      hisobIndex: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, KategoriyaModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.iconCode)
      ..writeByte(2)
      ..write(obj.colorValue)
      ..writeByte(3)
      ..write(obj.turi)
      ..writeByte(4)
      ..write(obj.amount)
      ..writeByte(5)
      ..write(obj.hisobIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KategoriyaModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
