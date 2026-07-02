import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:pulkam/features/profile/data/profile_model.dart';

const String kProfileBoxName = 'profiles';
const String kProfileKey = 'profile';

class ProfileState {
  final ProfileModel? profile;
  const ProfileState({this.profile});

  String? get name => profile?.name;
  String? get lastName => profile?.lastName;
  String? get avatarPath => profile?.avatarPath;
}

class ProfileCubit extends Cubit<ProfileState> {
  final Box<ProfileModel> _box = Hive.box<ProfileModel>(kProfileBoxName);

  ProfileCubit()
      : super(
          ProfileState(
            profile: Hive.box<ProfileModel>(kProfileBoxName).get(kProfileKey),
          ),
        );

  Future<void> saveProfile({
    required String name,
    String? lastName,
    String? avatarPath,
  }) async {
    final existing = _box.get(kProfileKey);
    final updated = ProfileModel(
      name: name,
      lastName: lastName,
      avatarPath: avatarPath ?? existing?.avatarPath,
    );
    await _box.put(kProfileKey, updated);
    emit(ProfileState(profile: updated));
  }
}