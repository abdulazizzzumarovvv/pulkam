// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qarz_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QarzModelAdapter extends TypeAdapter<QarzModel> {
  @override
  final int typeId = 4;

  @override
  QarzModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QarzModel(
      personName: fields[0] as String,
      amount: fields[1] as String,
      paid: fields[2] as String,
      isQarzBerdim: fields[3] as bool,
      hisobName: fields[4] as String,
      timestamp: fields[5] as int,
      tolovlar:
          (fields[6] as List?)?.cast<TolovModel>() ?? const <TolovModel>[],
    );
  }

  @override
  void write(BinaryWriter writer, QarzModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.personName)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.paid)
      ..writeByte(3)
      ..write(obj.isQarzBerdim)
      ..writeByte(4)
      ..write(obj.hisobName)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.tolovlar);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QarzModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TolovModelAdapter extends TypeAdapter<TolovModel> {
  @override
  final int typeId = 5;

  @override
  TolovModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TolovModel(
      amount: fields[0] as String,
      timestamp: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TolovModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.amount)
      ..writeByte(1)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TolovModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
