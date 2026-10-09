import 'package:flutter_test/flutter_test.dart';
import 'package:hitha_doctor_mobile/config/router.dart';
import 'package:hitha_doctor_mobile/config/routes.dart';
import 'package:hitha_doctor_mobile/data/repositories/doctor_auth_repository.dart';
import 'package:hitha_doctor_mobile/data/services/api_client.dart';
import 'package:hitha_doctor_mobile/ui/features/auth/view_models/auth_view_model.dart';

void main() {
  test('Router initializes to get-started when unauthenticated', () {
    final client = ApiClient();
    final authRepo = DoctorAuthRepository(client);
    final authVm = AuthViewModel(authRepo);

    final router = createRouter(authVm);
    expect(router.routeInformationProvider.value.uri.path, Routes.getStarted);
    router.dispose();
  });
}
