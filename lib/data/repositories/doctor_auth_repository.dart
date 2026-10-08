import '../../config/app_config.dart';
import '../../domain/models/models.dart';
import '../services/api_client.dart';
import '../services/sample_data.dart';

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
    try {
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
    } catch (e) {
      if (AppConfig.demoMode) {
        await _apiClient.setTokens(accessToken: 'demo-token', refreshToken: 'demo-refresh');
        _cachedProfile = SampleData.doctor;
        return SampleData.doctor;
      }
      rethrow;
    }
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
    try {
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
    } catch (e) {
      if (AppConfig.demoMode) return;
      rethrow;
    }
  }

  Future<void> sendOtp({
    required String identifier,
    required String purpose, // 'DOCTOR_LOGIN' | 'PASSWORD_RESET'
  }) async {
    try {
      await _apiClient.post('/auth/send-code', {
        'identifier': identifier.trim(),
        'purpose': purpose,
      });
    } catch (e) {
      if (AppConfig.demoMode) return;
      rethrow;
    }
  }

  Future<DoctorProfile> verifyOtp({
    required String identifier,
    required String code,
  }) async {
    try {
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
    } catch (e) {
      if (AppConfig.demoMode) {
        await _apiClient.setTokens(accessToken: 'demo-token', refreshToken: 'demo-refresh');
        _cachedProfile = SampleData.doctor;
        return SampleData.doctor;
      }
      rethrow;
    }
  }

  Future<void> resetPassword({
    required String identifier,
    required String verificationCode,
    required String newPassword,
  }) async {
    try {
      await _apiClient.post('/doctor/forgot-password', {
        'identifier': identifier.trim(),
        'verificationCode': verificationCode.trim(),
        'newPassword': newPassword,
      });
    } catch (e) {
      if (AppConfig.demoMode) return;
      rethrow;
    }
  }

  Future<DoctorProfile> completeProfile({
    required String professionalBio,
    required String gender,
    required List<String> languages,
    required List<String> qualifications,
    required List<String> specialties,
  }) async {
    try {
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
    } catch (e) {
      if (AppConfig.demoMode) {
        _cachedProfile = SampleData.doctor.copyWith(
          professionalBio: professionalBio,
          gender: gender,
          languages: languages,
          qualifications: qualifications,
          specialties: specialties,
          profileComplete: true,
          verificationStatus: VerificationStatus.PENDING_VERIFICATION,
        );
        return _cachedProfile!;
      }
      rethrow;
    }
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
      if (AppConfig.demoMode || _cachedProfile != null) {
        _cachedProfile ??= SampleData.doctor;
        return _cachedProfile!;
      }
      rethrow;
    }
  }

  Future<void> updateOnlineStatus(DoctorStatus status) async {
    try {
      await _apiClient.patch('/doctors/status', {
        'status': status.value,
      });
      if (_cachedProfile != null) {
        _cachedProfile = _cachedProfile!.copyWith(status: status);
      }
    } catch (e) {
      if (AppConfig.demoMode) {
        if (_cachedProfile != null) {
          _cachedProfile = _cachedProfile!.copyWith(status: status);
        }
        return;
      }
      rethrow;
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
