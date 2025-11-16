import 'package:app/core/base/base_repository.dart';
import 'package:app/api_services/my_account_api.dart';
import 'package:app/api_services/ProfileUpdateAPI.dart';

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

  /// Update user profile
  Future<dynamic> updateProfile(Map<String, dynamic> profileData) async {
    return await execute(
      operation: () => ProfileUpdateAPI.updateUserProfile(profileData),
      errorContext: 'Update user profile',
    );
  }
}
