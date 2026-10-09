import 'package:flutter/foundation.dart';

import '../../../../data/repositories/doctor_auth_repository.dart';
import '../../../../domain/models/models.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._authRepository);

  final DoctorAuthRepository _authRepository;

  bool _loading = false;
  String? _errorMessage;
  DoctorProfile? _doctor;
  String? _pendingPhoneIdentifier;
  bool _isInitialized = false;

  bool get loading => _loading;
  String? get errorMessage => _errorMessage;
  DoctorProfile? get doctor => _doctor;
  String? get pendingPhoneIdentifier => _pendingPhoneIdentifier;
  bool get isInitialized => _isInitialized;

  bool get isAuthenticated => _authRepository.isAuthenticated && _doctor != null;
  bool get isProfileComplete => _doctor?.profileComplete ?? false;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void setPendingIdentifier(String identifier) {
    _pendingPhoneIdentifier = identifier;
    notifyListeners();
  }

  Future<void> init() async {
    if (_isInitialized) return;
    _loading = true;
    notifyListeners();
    try {
      if (_authRepository.isAuthenticated) {
        _doctor = await _authRepository.getMe();
      }
    } catch (_) {
      _doctor = null;
    } finally {
      _loading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> login(String identifier, String password) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _doctor = await _authRepository.login(
        identifier: identifier,
        password: password,
      );
      _pendingPhoneIdentifier = identifier;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
    required DoctorCategory category,
    required String slmcLicenseNumber,
    String? profilePictureUrl,
    String? certifiedDocumentUrl,
  }) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authRepository.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        category: category,
        slmcLicenseNumber: slmcLicenseNumber,
        profilePictureUrl: profilePictureUrl,
        certifiedDocumentUrl: certifiedDocumentUrl,
      );
      _pendingPhoneIdentifier = phoneNumber;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> sendOtp({required String identifier, String purpose = 'DOCTOR_LOGIN'}) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authRepository.sendOtp(identifier: identifier, purpose: purpose);
      _pendingPhoneIdentifier = identifier;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp(String code) async {
    if (_pendingPhoneIdentifier == null) {
      _errorMessage = 'No pending phone number found.';
      notifyListeners();
      return false;
    }
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _doctor = await _authRepository.verifyOtp(
        identifier: _pendingPhoneIdentifier!,
        code: code,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword({
    required String identifier,
    required String code,
    required String newPassword,
  }) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authRepository.resetPassword(
        identifier: identifier,
        verificationCode: code,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> completeProfile({
    required String professionalBio,
    required String gender,
    required List<String> languages,
    required List<String> qualifications,
    required List<String> specialties,
  }) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _doctor = await _authRepository.completeProfile(
        professionalBio: professionalBio,
        gender: gender,
        languages: languages,
        qualifications: qualifications,
        specialties: specialties,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? slmcLicenseNumber,
    String? category,
    String? professionalBio,
    String? gender,
    List<String>? languages,
    List<String>? qualifications,
    List<String>? specialties,
    String? profilePicture,
    double? basePriceLkr,
  }) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _doctor = await _authRepository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        slmcLicenseNumber: slmcLicenseNumber,
        category: category,
        professionalBio: professionalBio,
        gender: gender,
        languages: languages,
        qualifications: qualifications,
        specialties: specialties,
        profilePicture: profilePicture,
        basePriceLkr: basePriceLkr,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfilePicture(String url) async {
    try {
      await _authRepository.updateProfilePicture(url);
      if (_doctor != null) {
        _doctor = _doctor!.copyWith(profilePictureUrl: url);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<String?> uploadFile(String filePath, {String folder = 'doctors'}) async {
    return _authRepository.uploadFile(filePath: filePath, folder: folder);
  }

  Future<void> updateOnlineStatus(DoctorStatus status) async {
    if (_doctor == null) return;
    try {
      _doctor = _doctor!.copyWith(status: status);
      notifyListeners();
      await _authRepository.updateOnlineStatus(status);
    } catch (e) {
      // Revert if API fails
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _loading = true;
    notifyListeners();
    try {
      await _authRepository.logout();
    } finally {
      _doctor = null;
      _pendingPhoneIdentifier = null;
      _loading = false;
      notifyListeners();
    }
  }
}
