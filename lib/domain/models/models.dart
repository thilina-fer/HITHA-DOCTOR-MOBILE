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

  factory DoctorProfile.fromJson(Map<String, dynamic> json) {
    return DoctorProfile(
      id: '${json['id'] ?? ''}',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      slmcLicenseNumber: json['slmcLicenseNumber'] as String? ?? '',
      category: DoctorCategory.fromString(json['category'] as String?),
      status: DoctorStatus.fromString(json['status'] as String?),
      verificationStatus: VerificationStatus.fromString(
        json['verificationStatus'] as String? ?? json['status'] as String?,
      ),
      profilePictureUrl: json['profilePictureUrl'] as String? ?? json['profilePicture'] as String?,
      certifiedDocumentUrl: json['certifiedDocumentUrl'] as String?,
      professionalBio: json['professionalBio'] as String? ?? '',
      gender: json['gender'] as String? ?? 'MALE',
      languages: (json['languages'] as List?)?.map((e) => '$e').toList() ?? ['en', 'si'],
      qualifications: (json['qualifications'] as List?)?.map((e) => '$e').toList() ?? [],
      specialties: (json['specialties'] as List?)?.map((e) => '$e').toList() ?? [],
      profileComplete: json['profileComplete'] as bool? ?? json['isProfileComplete'] as bool? ?? false,
      basePriceLkr: (json['basePriceLkr'] as num?)?.toDouble() ?? 3000.0,
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
    return BookingItem(
      id: '${json['id'] ?? ''}',
      bookingReference: json['bookingReference'] as String? ?? 'HTH-BK',
      patientName: json['patientName'] as String? ?? 'Client',
      patientPhone: json['patientPhone'] as String?,
      patientAvatarUrl: json['patientAvatarUrl'] as String?,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      scheduledStartTime: DateTime.tryParse(json['scheduledStartTime'] as String? ?? '') ?? DateTime.now(),
      scheduledEndTime: DateTime.tryParse(json['scheduledEndTime'] as String? ?? '') ??
          DateTime.now().add(const Duration(minutes: 50)),
      status: BookingStatus.fromString(json['status'] as String?),
      feeLkr: (json['feeLkr'] as num?)?.toDouble() ?? 3500.0,
      sessionNotes: json['sessionNotes'] as String?,
      meetingRoomName: json['meetingRoomName'] as String?,
    );
  }
}

class AvailabilityWindow {
  final int dayOfWeek; // 1 = Monday, 7 = Sunday
  final String dayName;
  final String startTime;
  final String endTime;
  final double priceLkr;

  const AvailabilityWindow({
    required this.dayOfWeek,
    required this.dayName,
    required this.startTime,
    required this.endTime,
    required this.priceLkr,
  });

  factory AvailabilityWindow.fromJson(Map<String, dynamic> json) {
    return AvailabilityWindow(
      dayOfWeek: json['dayOfWeek'] as int? ?? 1,
      dayName: json['dayName'] as String? ?? 'Monday',
      startTime: json['startTime'] as String? ?? '09:00',
      endTime: json['endTime'] as String? ?? '17:00',
      priceLkr: (json['priceLkr'] as num?)?.toDouble() ?? 3500.0,
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
