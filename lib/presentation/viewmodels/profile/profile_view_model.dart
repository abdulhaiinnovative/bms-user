import 'dart:developer';
import 'package:app/core/base/base_view_model.dart';
import 'package:app/data/repositories/profile_repository.dart';
import 'package:app/models/my_account_response.dart';

/// ViewModel for user profile management
/// Handles profile data loading and state management
class ProfileViewModel extends BaseViewModel {
  final ProfileRepository _repository;

  ProfileViewModel({ProfileRepository? repository})
      : _repository = repository ?? ProfileRepository();

  // State
  UserData? _userData;
  List<dynamic> _loyaltyTransactions = [];

  // Getters
  UserData? get userData => _userData;
  List<dynamic> get loyaltyTransactions => _loyaltyTransactions;

  String get userName => _userData?.name ?? 'User';
  String get userEmail => _userData?.email ?? '';
  String get userPhone => _userData?.phone ?? '';
  String get userImage => _userData?.image ?? '';
  int get loyaltyPoints => _userData?.loyalty ?? 0;
  int get appointmentCount => _userData?.appointment ?? 0;
  bool get isProfileComplete => (_userData?.completeStatus ?? 0) == 1;
  
  // Marketing preferences
  bool get emailMarketing => (_userData?.emailMarketing ?? 0) == 1;
  bool get marketingNotification => (_userData?.marketingNotification ?? 0) == 1;

  /// Load user profile data
  Future<void> loadProfile() async {
    log('ProfileViewModel: Loading profile');

    await executeAsync(
      operation: () async {
        final response = await _repository.getProfile();

        log('ProfileViewModel: Response received - Status: ${response?.status}');

        if (response != null && response.status == true) {
          _userData = response.response?.user;
          _loyaltyTransactions = response.response?.loyaltyTransactions ?? [];

          log('ProfileViewModel: Profile loaded successfully');
          log('  - Name: ${_userData?.name}');
          log('  - Email: ${_userData?.email}');
          log('  - Loyalty Points: ${_userData?.loyalty}');
          log('  - Appointments: ${_userData?.appointment}');
          log('  - Complete Status: ${_userData?.completeStatus}');
        } else {
          final errorMsg = response?.message ?? 'Failed to load profile';
          log('ProfileViewModel: Profile load failed - $errorMsg');
          throw Exception(errorMsg);
        }

        notifyListeners();
      },
    );
  }

  /// Refresh profile data
  Future<void> refreshProfile() async {
    log('ProfileViewModel: Refreshing profile');
    await loadProfile();
  }

  /// Check if profile data is available
  bool get hasProfileData => _userData != null;

  /// Get full name
  String get fullName {
    if (_userData?.firstName != null && _userData?.lastName != null) {
      return '${_userData!.firstName} ${_userData!.lastName}';
    }
    return _userData?.name ?? 'User';
  }

  /// Get user address
  String get fullAddress {
    final parts = <String>[];
    if (_userData?.address != null && _userData!.address!.isNotEmpty) {
      parts.add(_userData!.address!);
    }
    if (_userData?.city != null && _userData!.city!.isNotEmpty) {
      parts.add(_userData!.city!);
    }
    if (_userData?.state != null && _userData!.state!.isNotEmpty) {
      parts.add(_userData!.state!);
    }
    if (_userData?.country != null && _userData!.country!.isNotEmpty) {
      parts.add(_userData!.country!);
    }
    return parts.join(', ');
  }

  /// Check if user has address
  bool get hasAddress =>
      _userData?.address != null && _userData!.address!.isNotEmpty;

  /// Check if user has location coordinates
  bool get hasLocation =>
      _userData?.latitude != null && _userData?.longitude != null;
}
