// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maqsad_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MaqsadModelAdapter extends TypeAdapter<MaqsadModel> {
  @override
  final int typeId = 1;

  @override
  MaqsadModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MaqsadModel(
      name: fields[0] as String,
      balance: fields[1] as String,
      target: fields[2] as String,
      iconCode: fields[3] as int,
      colorValue: fields[4] as int,
      isCompleted: fields[5] as bool? ?? false,
      completedAt: fields[6] as int? ?? 0,
      defaultKey: fields[7] as String? ?? '',
      deadline: fields[8] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, MaqsadModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.balance)
      ..writeByte(2)
      ..write(obj.target)
      ..writeByte(3)
      ..write(obj.iconCode)
      ..writeByte(4)
      ..write(obj.colorValue)
      ..writeByte(5)
      ..write(obj.isCompleted)
      ..writeByte(6)
      ..write(obj.completedAt)
      ..writeByte(7)
      ..write(obj.defaultKey)
      ..writeByte(8)
      ..write(obj.deadline);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaqsadModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
