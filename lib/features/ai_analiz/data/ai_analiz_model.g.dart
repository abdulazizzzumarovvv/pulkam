// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_analiz_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AiAnalizModelAdapter extends TypeAdapter<AiAnalizModel> {
  @override
  final int typeId = 6;

  @override
  AiAnalizModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AiAnalizModel(
      result: fields[0] as String,
      timestamp: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AiAnalizModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.result)
      ..writeByte(1)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiAnalizModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
