enum DoctorCategory {
  COUNSELOR('COUNSELOR', 'Counselor', 2500.0),
  CLINICAL_COUNSELOR('CLINICAL_COUNSELOR', 'Clinical Counselor', 3000.0),
  PSYCHOLOGIST('PSYCHOLOGIST', 'Psychologist', 3500.0),
  CLINICAL_PSYCHOLOGIST('CLINICAL_PSYCHOLOGIST', 'Clinical Psychologist', 4000.0),
  MEDICAL_OFFICER_PSYCHIATRY_DIPLOMA('MEDICAL_OFFICER_PSYCHIATRY_DIPLOMA', 'Medical Officer (Psychiatry Diploma)', 4500.0),
  CONSULTANT_PSYCHIATRIST('CONSULTANT_PSYCHIATRIST', 'Consultant Psychiatrist', 5000.0);

  final String value;
  final String label;
  final double basePriceLkr;

  const DoctorCategory(this.value, this.label, this.basePriceLkr);

  static DoctorCategory fromString(String? val) {
    return DoctorCategory.values.firstWhere(
      (e) => e.value.equalsIgnoreCase(val ?? ''),
      orElse: () => DoctorCategory.COUNSELOR,
    );
  }
}

extension StringIgnoreCase on String {
  bool equalsIgnoreCase(String other) => toLowerCase() == other.toLowerCase();
}

enum DoctorStatus {
  ONLINE('ONLINE', 'Online'),
  AWAY('AWAY', 'Away'),
  PAUSED('PAUSED', 'Paused'),
  BUSY('BUSY', 'Busy'),
  OFFLINE('OFFLINE', 'Offline');

  final String value;
  final String label;
  const DoctorStatus(this.value, this.label);

  static DoctorStatus fromString(String? val) {
    if (val?.equalsIgnoreCase('ACTIVE') == true) return DoctorStatus.ONLINE;
    return DoctorStatus.values.firstWhere(
      (e) => e.value.equalsIgnoreCase(val ?? ''),
      orElse: () => DoctorStatus.ONLINE,
    );
  }
}

enum VerificationStatus {
  UNVERIFIED('UNVERIFIED', 'Unverified'),
  PENDING_VERIFICATION('PENDING_VERIFICATION', 'Pending SLMC Approval'),
  ACTIVE('ACTIVE', 'Active & Approved'),
  REJECTED('REJECTED', 'Rejected'),
  SUSPENDED('SUSPENDED', 'Suspended');

  final String value;
  final String label;
  const VerificationStatus(this.value, this.label);

  static VerificationStatus fromString(String? val) {
    return VerificationStatus.values.firstWhere(
      (e) => e.value.equalsIgnoreCase(val ?? ''),
      orElse: () => VerificationStatus.UNVERIFIED,
    );
  }
}

enum BookingStatus {
  PENDING_PAYMENT('PENDING_PAYMENT', 'Pending Payment'),
  PENDING_APPROVAL('PENDING_APPROVAL', 'Slip Review'),
  SLIP_UNDER_REVIEW('SLIP_UNDER_REVIEW', 'Slip Under Review'),
  CONFIRMED('CONFIRMED', 'Confirmed'),
  ACTIVE('ACTIVE', 'In Session'),
  COMPLETED('COMPLETED', 'Completed'),
  CANCELLED('CANCELLED', 'Cancelled'),
  EXPIRED('EXPIRED', 'Expired');

  final String value;
  final String label;
  const BookingStatus(this.value, this.label);

  static BookingStatus fromString(String? val) {
    return BookingStatus.values.firstWhere(
      (e) => e.value.equalsIgnoreCase(val ?? ''),
      orElse: () => BookingStatus.CONFIRMED,
    );
  }
}

class DoctorProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String slmcLicenseNumber;
  final DoctorCategory category;
  final DoctorStatus status;
  final VerificationStatus verificationStatus;
  final String? profilePictureUrl;
  final String? certifiedDocumentUrl;
  final String professionalBio;
  final String gender;
  final List<String> languages;
  final List<String> qualifications;
  final List<String> specialties;
  final bool profileComplete;
  final double basePriceLkr;
  final double? approvedCustomPriceLkr;

  const DoctorProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.slmcLicenseNumber,
    required this.category,
    required this.status,
    required this.verificationStatus,
    this.profilePictureUrl,
    this.certifiedDocumentUrl,
    this.professionalBio = '',
    this.gender = 'MALE',
    this.languages = const ['en', 'si'],
    this.qualifications = const [],
    this.specialties = const [],
    this.profileComplete = true,
    required this.basePriceLkr,
    this.approvedCustomPriceLkr,
  });

  String get fullName => 'Dr. $firstName $lastName'.trim();
  double get effectivePrice => approvedCustomPriceLkr ?? basePriceLkr;

  static List<String> _parseStringList(dynamic val) {
    if (val == null) return [];
    if (val is List) {
      return val.map((e) => '$e'.trim()).where((e) => e.isNotEmpty).toList();
    }
    if (val is String) {
      if (val.trim().isEmpty) return [];
      return val.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }

  factory DoctorProfile.fromJson(Map<String, dynamic> json) {
    return DoctorProfile(
      id: '${json['id'] ?? ''}',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? json['phone'] as String? ?? json['mobile'] as String? ?? '',
      slmcLicenseNumber: json['slmcLicenseNumber'] as String? ?? json['slmcNumber'] as String? ?? json['slmcRegNo'] as String? ?? json['licenseNumber'] as String? ?? '',
      category: DoctorCategory.fromString(json['category'] as String? ?? json['doctorCategory'] as String? ?? json['clinicalCategory'] as String?),
      status: DoctorStatus.fromString(json['status'] as String?),
      verificationStatus: VerificationStatus.fromString(
        json['verificationStatus'] as String? ?? json['status'] as String?,
      ),
      profilePictureUrl: json['profilePictureUrl'] as String? ?? json['profilePicture'] as String?,
      certifiedDocumentUrl: json['certifiedDocumentUrl'] as String?,
      professionalBio: json['professionalBio'] as String? ?? json['bio'] as String? ?? json['about'] as String? ?? json['description'] as String? ?? '',
      gender: json['gender'] as String? ?? 'MALE',
      languages: _parseStringList(json['languages'] ?? json['languagesSpoken']).isNotEmpty
          ? _parseStringList(json['languages'] ?? json['languagesSpoken'])
          : ['en', 'si'],
      qualifications: _parseStringList(json['qualifications'] ?? json['degrees'] ?? json['education']),
      specialties: _parseStringList(json['specialties'] ?? json['specializations'] ?? json['speciality']),
      profileComplete: json['profileComplete'] as bool? ?? json['isProfileComplete'] as bool? ?? false,
      basePriceLkr: (json['basePriceLkr'] as num?)?.toDouble() ??
          (json['sessionPriceLkr'] as num?)?.toDouble() ??
          (json['baseFee'] as num?)?.toDouble() ??
          3000.0,
      approvedCustomPriceLkr: (json['approvedCustomPriceLkr'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
        'slmcLicenseNumber': slmcLicenseNumber,
        'category': category.value,
        'status': status.value,
        'verificationStatus': verificationStatus.value,
        'profilePictureUrl': profilePictureUrl,
        'certifiedDocumentUrl': certifiedDocumentUrl,
        'professionalBio': professionalBio,
        'gender': gender,
        'languages': languages,
        'qualifications': qualifications,
        'specialties': specialties,
        'profileComplete': profileComplete,
        'basePriceLkr': basePriceLkr,
        'approvedCustomPriceLkr': approvedCustomPriceLkr,
      };

  DoctorProfile copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? slmcLicenseNumber,
    DoctorCategory? category,
    DoctorStatus? status,
    VerificationStatus? verificationStatus,
    String? profilePictureUrl,
    String? certifiedDocumentUrl,
    String? professionalBio,
    String? gender,
    List<String>? languages,
    List<String>? qualifications,
    List<String>? specialties,
    bool? profileComplete,
    double? basePriceLkr,
    double? approvedCustomPriceLkr,
  }) {
    return DoctorProfile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      slmcLicenseNumber: slmcLicenseNumber ?? this.slmcLicenseNumber,
      category: category ?? this.category,
      status: status ?? this.status,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      certifiedDocumentUrl: certifiedDocumentUrl ?? this.certifiedDocumentUrl,
      professionalBio: professionalBio ?? this.professionalBio,
      gender: gender ?? this.gender,
      languages: languages ?? this.languages,
      qualifications: qualifications ?? this.qualifications,
      specialties: specialties ?? this.specialties,
      profileComplete: profileComplete ?? this.profileComplete,
      basePriceLkr: basePriceLkr ?? this.basePriceLkr,
      approvedCustomPriceLkr: approvedCustomPriceLkr ?? this.approvedCustomPriceLkr,
    );
  }
}

class BookingItem {
  final String id;
  final String bookingReference;
  final String patientName;
  final String? patientPhone;
  final String? patientAvatarUrl;
  final bool isAnonymous;
  final DateTime scheduledStartTime;
  final DateTime scheduledEndTime;
  final BookingStatus status;
  final double feeLkr;
  final String? sessionNotes;
  final String? meetingRoomName;

  const BookingItem({
    required this.id,
    required this.bookingReference,
    required this.patientName,
    this.patientPhone,
    this.patientAvatarUrl,
    this.isAnonymous = false,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
    required this.status,
    required this.feeLkr,
    this.sessionNotes,
    this.meetingRoomName,
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    final rawId = '${json['bookingId'] ?? json['id'] ?? ''}';
    final rawRef = json['bookingReference'] as String? ??
        (rawId.length >= 8 ? rawId.substring(0, 8).toUpperCase() : 'HTH-BK');
    final patient = json['patientName'] as String?;
    final isAnon = json['appointmentForSomeoneElse'] == true ||
        json['isAnonymous'] == true ||
        patient == null ||
        patient.trim().isEmpty;

    final start = DateTime.tryParse(json['startTime'] as String? ?? json['scheduledStartTime'] as String? ?? '') ??
        DateTime.now();
    final end = DateTime.tryParse(json['endTime'] as String? ?? json['scheduledEndTime'] as String? ?? '') ??
        start.add(const Duration(minutes: 45));

    return BookingItem(
      id: rawId,
      bookingReference: rawRef,
      patientName: isAnon ? 'Anonymous Patient' : patient,
      patientPhone: json['patientPhone'] as String?,
      patientAvatarUrl: json['patientAvatarUrl'] as String?,
      isAnonymous: isAnon,
      scheduledStartTime: start,
      scheduledEndTime: end,
      status: BookingStatus.fromString(json['status'] as String?),
      feeLkr: (json['totalPriceLkr'] as num?)?.toDouble() ??
          (json['feeLkr'] as num?)?.toDouble() ??
          (json['priceLkr'] as num?)?.toDouble() ??
          5000.0,
      sessionNotes: json['sessionNotes'] as String?,
      meetingRoomName: json['meetingRoomName'] as String?,
    );
  }
}

class AvailabilityWindow {
  final String id;
  final DateTime? startDateTime;
  final DateTime? endDateTime;
  final int dayOfWeek; // 1 = Monday, 7 = Sunday
  final String dayName;
  final String startTime;
  final String endTime;
  final double priceLkr;
  final bool isBooked;

  const AvailabilityWindow({
    this.id = '',
    this.startDateTime,
    this.endDateTime,
    required this.dayOfWeek,
    required this.dayName,
    required this.startTime,
    required this.endTime,
    required this.priceLkr,
    this.isBooked = false,
  });

  factory AvailabilityWindow.fromJson(Map<String, dynamic> json) {
    DateTime? start;
    DateTime? end;
    if (json['startTime'] != null && json['startTime'].toString().contains('T')) {
      start = DateTime.tryParse(json['startTime'] as String)?.toLocal();
    }
    if (json['endTime'] != null && json['endTime'].toString().contains('T')) {
      end = DateTime.tryParse(json['endTime'] as String)?.toLocal();
    }

    final dayOfWeek = start != null ? start.weekday : (json['dayOfWeek'] as int? ?? 1);
    final dayNames = const ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayName = json['dayName'] as String? ?? (dayOfWeek <= 7 ? dayNames[dayOfWeek] : 'Monday');

    String startStr = json['startTime'] as String? ?? '09:00';
    String endStr = json['endTime'] as String? ?? '17:00';

    if (start != null) {
      final hour = start.hour.toString().padLeft(2, '0');
      final min = start.minute.toString().padLeft(2, '0');
      startStr = '$hour:$min';
    }
    if (end != null) {
      final hour = end.hour.toString().padLeft(2, '0');
      final min = end.minute.toString().padLeft(2, '0');
      endStr = '$hour:$min';
    }

    return AvailabilityWindow(
      id: '${json['id'] ?? ''}',
      startDateTime: start,
      endDateTime: end,
      dayOfWeek: dayOfWeek,
      dayName: dayName,
      startTime: startStr,
      endTime: endStr,
      priceLkr: (json['priceLkr'] as num?)?.toDouble() ?? 5000.0,
      isBooked: json['isBooked'] as bool? ?? false,
    );
  }
}

class WalletSummary {
  final double balanceAvailable;
  final double balanceEscrow;
  final double balancePendingPayout;
  final double balanceFrozen;
  final double totalWithdrawn;

  const WalletSummary({
    this.balanceAvailable = 0.0,
    this.balanceEscrow = 0.0,
    this.balancePendingPayout = 0.0,
    this.balanceFrozen = 0.0,
    this.totalWithdrawn = 0.0,
  });

  factory WalletSummary.fromJson(Map<String, dynamic> json) {
    return WalletSummary(
      balanceAvailable: (json['balanceAvailable'] as num?)?.toDouble() ?? 0.0,
      balanceEscrow: (json['balanceEscrow'] as num?)?.toDouble() ?? 0.0,
      balancePendingPayout: (json['balancePendingPayout'] as num?)?.toDouble() ?? 0.0,
      balanceFrozen: (json['balanceFrozen'] as num?)?.toDouble() ?? 0.0,
      totalWithdrawn: (json['totalWithdrawn'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class WeeklyTemplateItem {
  final String id;
  final int dayOfWeek; // 1 = Monday, 7 = Sunday
  final String startTime;
  final String endTime;
  final bool isActive;

  const WeeklyTemplateItem({
    this.id = '',
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.isActive = true,
  });

  String get dayName {
    const names = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return (dayOfWeek >= 1 && dayOfWeek <= 7) ? names[dayOfWeek] : 'Day $dayOfWeek';
  }

  WeeklyTemplateItem copyWith({
    String? id,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    bool? isActive,
  }) {
    return WeeklyTemplateItem(
      id: id ?? this.id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
    );
  }

  static String formatToApiTime(String time) {
    final clean = time.trim();
    final parts = clean.split(':');
    if (parts.isEmpty) return '09:00:00';
    final h = (int.tryParse(parts[0]) ?? 9).toString().padLeft(2, '0');
    final m = (parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0).toString().padLeft(2, '0');
    final s = (parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  factory WeeklyTemplateItem.fromJson(Map<String, dynamic> json) {
    final s = json['startTime'] as String? ?? '09:00';
    final e = json['endTime'] as String? ?? '17:00';
    return WeeklyTemplateItem(
      id: '${json['id'] ?? ''}',
      dayOfWeek: json['dayOfWeek'] as int? ?? 1,
      startTime: s.length >= 5 ? s.substring(0, 5) : s,
      endTime: e.length >= 5 ? e.substring(0, 5) : e,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'dayOfWeek': dayOfWeek,
        'startTime': formatToApiTime(startTime),
        'endTime': formatToApiTime(endTime),
      };
}

class CustomSlotItem {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String? rawStartTime;
  final String? rawEndTime;

  const CustomSlotItem({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.rawStartTime,
    this.rawEndTime,
  });

  factory CustomSlotItem.fromJson(Map<String, dynamic> json) {
    final rawStart = json['startTime'] as String?;
    final rawEnd = json['endTime'] as String?;
    return CustomSlotItem(
      id: '${json['id'] ?? ''}',
      startTime: DateTime.tryParse(rawStart ?? '')?.toLocal() ?? DateTime.now(),
      endTime: DateTime.tryParse(rawEnd ?? '')?.toLocal() ?? DateTime.now().add(const Duration(hours: 1)),
      rawStartTime: rawStart,
      rawEndTime: rawEnd,
    );
  }
}

class BlockedDateItem {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String reason;

  const BlockedDateItem({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.reason = '',
  });

  factory BlockedDateItem.fromJson(Map<String, dynamic> json) {
    return BlockedDateItem(
      id: '${json['id'] ?? ''}',
      startTime: DateTime.tryParse(json['startTime'] as String? ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(json['endTime'] as String? ?? '') ?? DateTime.now().add(const Duration(days: 1)),
      reason: json['reason'] as String? ?? '',
    );
  }
}

class BankInfo {
  final String code;
  final String name;

  const BankInfo({required this.code, required this.name});

  factory BankInfo.fromJson(Map<String, dynamic> json) {
    return BankInfo(
      code: '${json['code'] ?? json['id'] ?? ''}',
      name: '${json['name'] ?? json['bankName'] ?? ''}',
    );
  }
}

class PayoutMethod {
  final String id;
  final String bankName;
  final String accountNumber;
  final String accountHolderName;
  final String branchName;
  final bool isDefault;

  const PayoutMethod({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
    this.branchName = '',
    this.isDefault = false,
  });

  factory PayoutMethod.fromJson(Map<String, dynamic> json) {
    return PayoutMethod(
      id: '${json['id'] ?? ''}',
      bankName: json['bankName'] as String? ?? '',
      accountNumber: json['accountNumber'] as String? ?? '',
      accountHolderName: json['accountHolderName'] as String? ?? '',
      branchName: json['branchName'] as String? ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}

class WalletTransaction {
  final String id;
  final String description;
  final double amountLkr;
  final String type;
  final DateTime createdAt;
  final String status;

  const WalletTransaction({
    required this.id,
    required this.description,
    required this.amountLkr,
    required this.type,
    required this.createdAt,
    this.status = 'COMPLETED',
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: '${json['id'] ?? ''}',
      description: json['description'] as String? ?? 'Consultation credit',
      amountLkr: (json['amountLkr'] as num?)?.toDouble() ?? (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] as String? ?? json['entryType'] as String? ?? 'CREDIT',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      status: json['status'] as String? ?? 'COMPLETED',
    );
  }
}

class PriceRequestItem {
  final String id;
  final double currentPriceLkr;
  final double requestedPriceLkr;
  final String reason;
  final String status;
  final DateTime createdAt;

  const PriceRequestItem({
    required this.id,
    required this.currentPriceLkr,
    required this.requestedPriceLkr,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory PriceRequestItem.fromJson(Map<String, dynamic> json) {
    return PriceRequestItem(
      id: '${json['id'] ?? ''}',
      currentPriceLkr: (json['currentPriceLkr'] as num?)?.toDouble() ?? 3000.0,
      requestedPriceLkr: (json['requestedPriceLkr'] as num?)?.toDouble() ?? 3500.0,
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class ArticleItem {
  final String id;
  final String title;
  final String slug;
  final String excerpt;
  final String? coverImageUrl;
  final String status;
  final DateTime publishedAt;
  final int readTimeMinutes;

  const ArticleItem({
    required this.id,
    required this.title,
    required this.slug,
    required this.excerpt,
    this.coverImageUrl,
    required this.status,
    required this.publishedAt,
    this.readTimeMinutes = 4,
  });

  factory ArticleItem.fromJson(Map<String, dynamic> json) {
    return ArticleItem(
      id: '${json['id'] ?? ''}',
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      excerpt: json['excerpt'] as String? ?? json['content'] as String? ?? '',
      coverImageUrl: json['coverImageUrl'] as String? ?? json['featuredImage'] as String?,
      status: json['status'] as String? ?? 'PUBLISHED',
      publishedAt: DateTime.tryParse(json['publishedAt'] as String? ?? json['createdAt'] as String? ?? '') ?? DateTime.now(),
      readTimeMinutes: (json['readTimeMinutes'] as num?)?.toInt() ?? 4,
    );
  }
}

