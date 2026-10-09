import 'package:flutter_test/flutter_test.dart';
import 'package:hitha_doctor_mobile/domain/models/models.dart';

void main() {
  test('Sample doctor matches practitioner domain rules', () {
    const doc = DoctorProfile(
      id: 'doc-001',
      firstName: 'Kasun',
      lastName: 'Perera',
      email: 'kasun.perera@hitha.lk',
      phoneNumber: '+94771234567',
      slmcLicenseNumber: 'SLMC-98765',
      category: DoctorCategory.CLINICAL_PSYCHOLOGIST,
      status: DoctorStatus.ONLINE,
      verificationStatus: VerificationStatus.ACTIVE,
      basePriceLkr: 4000.0,
      approvedCustomPriceLkr: 4500.0,
    );
    expect(doc.category, DoctorCategory.CLINICAL_PSYCHOLOGIST);
    expect(doc.status, DoctorStatus.ONLINE);
    expect(doc.verificationStatus, VerificationStatus.ACTIVE);
    expect(doc.effectivePrice, 4500.0);
  });

  test('Parses real backend /doctors/me payload seamlessly', () {
    final raw = {
      "id": "bca70d17-d43b-4a7c-9912-84c5df6bd404",
      "firstName": "Thilina",
      "lastName": "Dilshan Fernando",
      "email": "dilshanthilina1010@gmail.com",
      "phoneNumber": "0766497071",
      "profilePicture": "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=600",
      "status": "ACTIVE",
      "isProfileComplete": true,
      "category": "CLINICAL_COUNSELOR",
      "approvedCustomPriceLkr": 5000.00,
      "basePriceLkr": 2500.00,
      "sessionPriceLkr": 5000.00,
      "ongoingSessionsCount": 0
    };

    final doc = DoctorProfile.fromJson(raw);
    expect(doc.firstName, "Thilina");
    expect(doc.lastName, "Dilshan Fernando");
    expect(doc.fullName, "Dr. Thilina Dilshan Fernando");
    expect(doc.category, DoctorCategory.CLINICAL_COUNSELOR);
    expect(doc.status, DoctorStatus.ONLINE);
    expect(doc.verificationStatus, VerificationStatus.ACTIVE);
    expect(doc.profilePictureUrl, isNotNull);
    expect(doc.profileComplete, true);
    expect(doc.effectivePrice, 5000.0);
    expect(doc.phoneNumber, "0766497071");
  });

  test('DoctorProfile parses string-delimited and array-delimited credentials', () {
    final rawWithArrays = {
      'id': 'doc-arrays',
      'email': 'doc@test.com',
      'phoneNumber': '0771234567',
      'slmcLicenseNumber': 'SLMC-12345',
      'qualifications': ['MBBS (Col)', 'MD (Psych)'],
      'specialties': ['Depression', 'Anxiety'],
      'languages': ['Sinhala', 'English'],
    };
    final doc1 = DoctorProfile.fromJson(rawWithArrays);
    expect(doc1.slmcLicenseNumber, 'SLMC-12345');
    expect(doc1.qualifications, ['MBBS (Col)', 'MD (Psych)']);
    expect(doc1.specialties, ['Depression', 'Anxiety']);
    expect(doc1.languages, ['Sinhala', 'English']);

    final rawWithStrings = {
      'id': 'doc-strings',
      'email': 'doc@test.com',
      'mobile': '0779876543',
      'slmcRegNo': 'SLMC-99999',
      'qualifications': 'MBBS, PhD',
      'specialties': 'CBT, PTSD',
      'languages': 'Sinhala, Tamil',
    };
    final doc2 = DoctorProfile.fromJson(rawWithStrings);
    expect(doc2.phoneNumber, '0779876543');
    expect(doc2.slmcLicenseNumber, 'SLMC-99999');
    expect(doc2.qualifications, ['MBBS', 'PhD']);
    expect(doc2.specialties, ['CBT', 'PTSD']);
    expect(doc2.languages, ['Sinhala', 'Tamil']);
  });

  test('WeeklyTemplateItem correctly normalizes time to HH:mm:ss for backend compatibility', () {
    const item1 = WeeklyTemplateItem(dayOfWeek: 1, startTime: '9:00', endTime: '17:00');
    expect(item1.toJson(), {
      'dayOfWeek': 1,
      'startTime': '09:00:00',
      'endTime': '17:00:00',
    });

    const item2 = WeeklyTemplateItem(dayOfWeek: 2, startTime: '07:30', endTime: '12:00:00');
    expect(item2.toJson(), {
      'dayOfWeek': 2,
      'startTime': '07:30:00',
      'endTime': '12:00:00',
    });
  });

  test('CustomSlotItem preserves raw timestamps and parses correctly', () {
    final slot = CustomSlotItem.fromJson({
      'id': 'slot-123',
      'startTime': '2026-10-15T08:00:00Z',
      'endTime': '2026-10-15T10:00:00Z',
    });

    expect(slot.id, 'slot-123');
    expect(slot.rawStartTime, '2026-10-15T08:00:00Z');
    expect(slot.rawEndTime, '2026-10-15T10:00:00Z');
    expect(slot.startTime.isBefore(slot.endTime), true);
  });
}
