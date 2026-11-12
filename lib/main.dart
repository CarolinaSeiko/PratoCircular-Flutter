import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/donation_provider.dart';
import 'screens/home_page.dart';
import 'screens/login_page.dart';
import 'screens/onboarding_page.dart';
import 'screens/splash_page.dart';
import 'services/local_storage_service.dart';

void main() {
  runApp(const PratoCircularApp());
}

class PratoCircularApp extends StatelessWidget {
  const PratoCircularApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = LocalStorageService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(storage)),
        ChangeNotifierProvider(create: (_) => DonationProvider(storage)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Prato Circular',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF7F8F4),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1F7A4D),
            primary: const Color(0xFF1F7A4D),
            secondary: const Color(0xFFF4A340),
            surface: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF173126),
            elevation: 0,
            centerTitle: false,
            surfaceTintColor: Colors.transparent,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: const BorderSide(
                color: Color(0xFFE5E9E3),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFDDE3DD),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFDDE3DD),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF1F7A4D),
                width: 1.6,
              ),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              side: const BorderSide(
                color: Color(0xFFCAD6CE),
              ),
            ),
          ),
        ),
        home: const AppStartPage(),
      ),
    );
  }
}

class AppStartPage extends StatefulWidget {
  const AppStartPage({super.key});

  @override
  State<AppStartPage> createState() => _AppStartPageState();
}

class _AppStartPageState extends State<AppStartPage> {
  bool splash = true;
  bool loading = true;
  bool onboardingSeen = false;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    final auth = context.read<AuthProvider>();
    final storage = auth.storage;
    onboardingSeen = await storage.wasOnboardingSeen();
    await auth.restoreSession();

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (splash) {
      return SplashPage(
        onFinish: () {
          if (!mounted) return;
          setState(() {
            splash = false;
          });
        },
      );
    }

    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final auth = context.watch<AuthProvider>();

    if (!onboardingSeen) {
      return OnboardingPage(
        onFinish: (doNotShowAgain) async {
          if (doNotShowAgain) {
            await auth.storage.setOnboardingSeen(true);
          }

          if (!mounted) return;

          setState(() {
            onboardingSeen = true;
          });
        },
      );
    }

    if (!auth.isLoggedIn) {
      return LoginPage(
        onSuccess: () {
          if (!mounted) return;
          setState(() {});
        },
      );
    }

    return const HomePage();
  }
}
