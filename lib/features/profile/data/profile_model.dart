import 'package:hive/hive.dart';

part 'profile_model.g.dart';

@HiveType(typeId: 20) // Loyihadagi boshqa typeId'lar bilan to'qnashmasin —
// agar 20 band bo'lsa, bo'sh raqamga o'zgartiring.
class ProfileModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String? avatarPath; // tanlangan rasmning device'dagi fayl yo'li

  @HiveField(2)
  String? lastName;

  ProfileModel({required this.name, this.avatarPath, this.lastName});

  String get fullName => [name, if (lastName != null && lastName!.isNotEmpty) lastName!].join(' ');
}