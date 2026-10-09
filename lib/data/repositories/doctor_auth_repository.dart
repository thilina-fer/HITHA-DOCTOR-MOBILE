import '../../domain/models/models.dart';
import '../services/api_client.dart';

class DoctorAuthRepository {
  DoctorAuthRepository(this._apiClient);

  final ApiClient _apiClient;
  DoctorProfile? _cachedProfile;

  DoctorProfile? get cachedProfile => _cachedProfile;
  bool get isAuthenticated => _apiClient.isAuthenticated;

  Future<DoctorProfile> login({
    required String identifier,
    required String password,
  }) async {
    final res = await _apiClient.post('/doctor/login', {
      'identifier': identifier.trim(),
      'password': password,
    });

    if (res is Map<String, dynamic>) {
      final accessToken = res['accessToken'] as String?;
      final refreshToken = res['refreshToken'] as String?;
      await _apiClient.setTokens(accessToken: accessToken, refreshToken: refreshToken);
    }

    return await getMe();
  }

  Future<void> register({
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
    await _apiClient.post('/doctor/register', {
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'email': email.trim().toLowerCase(),
      'phoneNumber': phoneNumber.trim(),
      'password': password,
      'category': category.value,
      'slmcLicenseNumber': slmcLicenseNumber.trim().toUpperCase(),
      'profilePictureUrl': profilePictureUrl,
      'certifiedDocumentUrl': certifiedDocumentUrl,
    });
  }

  Future<void> sendOtp({
    required String identifier,
    required String purpose, // 'DOCTOR_LOGIN' | 'PASSWORD_RESET'
  }) async {
    await _apiClient.post('/auth/send-code', {
      'identifier': identifier.trim(),
      'purpose': purpose,
    });
  }

  Future<DoctorProfile> verifyOtp({
    required String identifier,
    required String code,
  }) async {
    final res = await _apiClient.post('/auth/verify-code', {
      'identifier': identifier.trim(),
      'verificationCode': code.trim(),
    });

    if (res is Map<String, dynamic>) {
      final accessToken = res['accessToken'] as String?;
      final refreshToken = res['refreshToken'] as String?;
      if (accessToken != null) {
        await _apiClient.setTokens(accessToken: accessToken, refreshToken: refreshToken);
      }
    }

    return await getMe();
  }

  Future<void> resetPassword({
    required String identifier,
    required String verificationCode,
    required String newPassword,
  }) async {
    await _apiClient.post('/doctor/forgot-password', {
      'identifier': identifier.trim(),
      'verificationCode': verificationCode.trim(),
      'newPassword': newPassword,
    });
  }

  Future<DoctorProfile> completeProfile({
    required String professionalBio,
    required String gender,
    required List<String> languages,
    required List<String> qualifications,
    required List<String> specialties,
  }) async {
    final res = await _apiClient.post('/doctors/me/complete-profile', {
      'professionalBio': professionalBio.trim(),
      'gender': gender,
      'languages': languages,
      'qualifications': qualifications,
      'specialties': specialties,
    });

    if (res is Map<String, dynamic>) {
      _cachedProfile = DoctorProfile.fromJson(res);
      return _cachedProfile!;
    }
    return await getMe();
  }

  Future<DoctorProfile> getMe() async {
    try {
      final res = await _apiClient.get('/doctors/me');
      if (res is Map<String, dynamic>) {
        _cachedProfile = DoctorProfile.fromJson(res);
        return _cachedProfile!;
      }
      throw ApiException('Invalid profile payload returned');
    } catch (e) {
      if (_cachedProfile != null) {
        return _cachedProfile!;
      }
      rethrow;
    }
  }

  Future<DoctorProfile> updateProfile({
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
    final payload = <String, dynamic>{
      if (firstName != null) 'firstName': firstName.trim(),
      if (lastName != null) 'lastName': lastName.trim(),
      if (phoneNumber != null && phoneNumber.trim().isNotEmpty) 'phoneNumber': phoneNumber.trim(),
      if (slmcLicenseNumber != null && slmcLicenseNumber.trim().isNotEmpty) 'slmcLicenseNumber': slmcLicenseNumber.trim(),
      if (category != null && category.trim().isNotEmpty) 'category': category.trim(),
      if (professionalBio != null) 'professionalBio': professionalBio.trim(),
      if (gender != null) 'gender': gender,
      if (profilePicture != null) 'profilePicture': profilePicture,
      if (languages != null) 'languages': languages,
      if (qualifications != null) 'qualifications': qualifications,
      if (specialties != null) 'specialties': specialties,
      if (basePriceLkr != null) 'basePriceLkr': basePriceLkr,
    };
    final res = await _apiClient.put('/doctors/me', payload);

    if (res is Map<String, dynamic>) {
      _cachedProfile = DoctorProfile.fromJson(res);
      return _cachedProfile!;
    }
    return await getMe();
  }

  Future<void> updateOnlineStatus(DoctorStatus status) async {
    await _apiClient.patch('/doctors/status', {
      'status': status.value,
    });
    if (_cachedProfile != null) {
      _cachedProfile = _cachedProfile!.copyWith(status: status);
    }
  }

  Future<String?> uploadFile({required String filePath, String folder = 'uploads'}) async {
    try {
      final res = await _apiClient.uploadFile('/files/upload?folder=$folder', filePath: filePath);
      if (res is String) return res;
      if (res is Map<String, dynamic>) return res['url'] as String? ?? res['fileUrl'] as String?;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> updateProfilePicture(String url) async {
    await _apiClient.patch('/doctors/me/profile-picture', {
      'profilePicture': url,
    });
    if (_cachedProfile != null) {
      _cachedProfile = _cachedProfile!.copyWith(profilePictureUrl: url);
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout', {
        'refreshToken': _apiClient.refreshToken,
      });
    } catch (_) {
      // Continue clearing session locally regardless of server error
    } finally {
      _cachedProfile = null;
      await _apiClient.clearSession();
    }
  }
}
