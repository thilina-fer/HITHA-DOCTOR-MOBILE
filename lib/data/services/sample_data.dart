import '../../domain/models/models.dart';

abstract final class SampleData {
  static final doctor = DoctorProfile(
    id: 'doc-001',
    firstName: 'Kasun',
    lastName: 'Perera',
    email: 'kasun.perera@hitha.lk',
    phoneNumber: '+94771234567',
    slmcLicenseNumber: 'SLMC-98765',
    category: DoctorCategory.CLINICAL_PSYCHOLOGIST,
    status: DoctorStatus.ONLINE,
    verificationStatus: VerificationStatus.ACTIVE,
    profilePictureUrl: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=300',
    certifiedDocumentUrl: 'https://example.com/slmc_cert.pdf',
    professionalBio:
        'Licensed Clinical Psychologist with 8+ years specializing in Cognitive Behavioral Therapy (CBT), adult anxiety disorders, trauma resilience, and workplace burnout in Sri Lanka.',
    gender: 'MALE',
    languages: const ['en', 'si'],
    qualifications: const [
      'MBBS (Univ. of Colombo)',
      'MSc Clinical Psychology (UK)',
      'Chartered Member SLPA',
    ],
    specialties: const ['Anxiety & Panic', 'Depression & Mood', 'Trauma / PTSD', 'CBT'],
    profileComplete: true,
    basePriceLkr: 4000.0,
    approvedCustomPriceLkr: 4500.0,
  );

  static final todayBookings = [
    BookingItem(
      id: 'bk-101',
      bookingReference: 'HTH-BK-8901',
      patientName: 'Sanduni Fernando',
      patientPhone: '+94718899001',
      scheduledStartTime: DateTime.now().subtract(const Duration(hours: 3)),
      scheduledEndTime: DateTime.now().subtract(const Duration(hours: 2, minutes: 10)),
      status: BookingStatus.COMPLETED,
      feeLkr: 4500.0,
      sessionNotes: 'Follow up on generalized anxiety disorder. Marked mood stabilization.',
    ),
    BookingItem(
      id: 'bk-102',
      bookingReference: 'HTH-BK-8902',
      patientName: 'Niroshan Bandara',
      patientPhone: '+94773344556',
      scheduledStartTime: DateTime.now().subtract(const Duration(hours: 1)),
      scheduledEndTime: DateTime.now().subtract(const Duration(minutes: 10)),
      status: BookingStatus.COMPLETED,
      feeLkr: 4500.0,
      sessionNotes: 'Initial intake completed. Commenced behavioral activation cycle.',
    ),
    BookingItem(
      id: 'bk-103',
      bookingReference: 'HTH-BK-8903',
      patientName: 'Anonymous Client',
      isAnonymous: true,
      scheduledStartTime: DateTime.now().add(const Duration(minutes: 5)),
      scheduledEndTime: DateTime.now().add(const Duration(minutes: 55)),
      status: BookingStatus.ACTIVE,
      feeLkr: 4500.0,
      meetingRoomName: 'hitha-session-bk103',
    ),
    BookingItem(
      id: 'bk-104',
      bookingReference: 'HTH-BK-8904',
      patientName: 'Tharindu Jayasuriya',
      patientPhone: '+94701122334',
      scheduledStartTime: DateTime.now().add(const Duration(hours: 2)),
      scheduledEndTime: DateTime.now().add(const Duration(hours: 2, minutes: 50)),
      status: BookingStatus.CONFIRMED,
      feeLkr: 4500.0,
    ),
  ];

  static const walletSummary = WalletSummary(
    balanceAvailable: 48600.0,
    balanceEscrow: 12000.0,
    balancePendingPayout: 15000.0,
    balanceFrozen: 0.0,
    totalWithdrawn: 135000.0,
  );

  static const availabilityWindows = [
    AvailabilityWindow(
      dayOfWeek: 1,
      dayName: 'Monday',
      startTime: '09:00',
      endTime: '17:00',
      priceLkr: 4500.0,
    ),
    AvailabilityWindow(
      dayOfWeek: 2,
      dayName: 'Tuesday',
      startTime: '10:00',
      endTime: '16:00',
      priceLkr: 4500.0,
    ),
    AvailabilityWindow(
      dayOfWeek: 3,
      dayName: 'Wednesday',
      startTime: '14:00',
      endTime: '19:00',
      priceLkr: 4500.0,
    ),
    AvailabilityWindow(
      dayOfWeek: 5,
      dayName: 'Friday',
      startTime: '09:00',
      endTime: '15:00',
      priceLkr: 4500.0,
    ),
    AvailabilityWindow(
      dayOfWeek: 6,
      dayName: 'Saturday',
      startTime: '09:00',
      endTime: '13:00',
      priceLkr: 4500.0,
    ),
  ];

  static const drugCatalog = [
    {'name': 'Sertraline Hydrochloride', 'category': 'SSRI Antidepressant', 'dosages': ['25mg', '50mg', '100mg']},
    {'name': 'Fluoxetine', 'category': 'SSRI Antidepressant', 'dosages': ['20mg', '40mg']},
    {'name': 'Escitalopram Oxalate', 'category': 'SSRI Antidepressant', 'dosages': ['10mg', '20mg']},
    {'name': 'Clonazepam', 'category': 'Benzodiazepine (Anxiolytic)', 'dosages': ['0.5mg', '1mg', '2mg']},
    {'name': 'Propranolol', 'category': 'Beta-blocker (Somatic Anxiety)', 'dosages': ['10mg', '20mg', '40mg']},
    {'name': 'Quetiapine Fumarate', 'category': 'Atypical Antipsychotic', 'dosages': ['25mg', '50mg', '100mg']},
  ];
}
