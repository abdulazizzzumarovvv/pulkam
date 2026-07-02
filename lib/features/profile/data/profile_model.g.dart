// GENERATED CODE - manual mirror of build_runner output.
// Agar `flutter pub run build_runner build` ishlatilsa, bu fayl avtomatik
// generatsiya qilinadi va bu qo'lda yozilgan versiyani almashtirishi mumkin —
// muammo emas, ikkalasi ham bir xil natija beradi.

part of 'profile_model.dart';

class ProfileModelAdapter extends TypeAdapter<ProfileModel> {
  @override
  final int typeId = 20;

  @override
  ProfileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProfileModel(
      name: fields[0] as String,
      avatarPath: fields[1] as String?,
      lastName: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProfileModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.avatarPath)
      ..writeByte(2)
      ..write(obj.lastName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}