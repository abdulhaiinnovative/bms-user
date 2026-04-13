import 'dart:io';
import 'package:app/core/base/base_repository.dart';
import 'package:app/api_services/my_account_api.dart';

/// Repository for user profile operations
class ProfileRepository extends BaseRepository {
  final MyAccountAPI _profileAPI;

  ProfileRepository({MyAccountAPI? profileAPI})
      : _profileAPI = profileAPI ?? MyAccountAPI();

  /// Get user profile data
  Future<dynamic> getProfile() async {
    return await execute(
      operation: () => _profileAPI.getMyAccount(),
      errorContext: 'Get user profile',
    );
  }

  /// Update user profile data
  Future<dynamic> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? dob,
    String? gender,
    String? country,
    String? state,
    String? city,
    String? address,
    File? image,
  }) async {
    return await execute(
      operation: () => _profileAPI.updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        dob: dob,
        gender: gender,
        country: country,
        state: state,
        city: city,
        address: address,
        image: image,
      ),
      errorContext: 'Update user profile',
    );
  }
}
