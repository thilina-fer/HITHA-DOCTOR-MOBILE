import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'config/router.dart';
import 'data/repositories/dashboard_repository.dart';
import 'data/repositories/doctor_auth_repository.dart';
import 'data/services/api_client.dart';
import 'ui/core/theme/hitha_theme.dart';
import 'ui/features/auth/view_models/auth_view_model.dart';
import 'ui/features/dashboard/view_models/dashboard_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient();
  await apiClient.restoreSession();

  final authRepo = DoctorAuthRepository(apiClient);
  final dashRepo = DashboardRepository(apiClient);

  final authVm = AuthViewModel(authRepo);
  final dashVm = DashboardViewModel(dashRepo);

  await authVm.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        Provider<DoctorAuthRepository>.value(value: authRepo),
        Provider<DashboardRepository>.value(value: dashRepo),
        ChangeNotifierProvider<AuthViewModel>.value(value: authVm),
        ChangeNotifierProvider<DashboardViewModel>.value(value: dashVm),
      ],
      child: const HithaDoctorApp(),
    ),
  );
}

class HithaDoctorApp extends StatefulWidget {
  const HithaDoctorApp({super.key});

  @override
  State<HithaDoctorApp> createState() => _HithaDoctorAppState();
}

class _HithaDoctorAppState extends State<HithaDoctorApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter(context.read<AuthViewModel>());
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hitha Doctor Portal',
      debugShowCheckedModeBanner: false,
      theme: buildHithaTheme(),
      routerConfig: _router,
    );
  }
}
