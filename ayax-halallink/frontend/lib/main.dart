import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/language_selection_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final savedLangCode = prefs.getString('selected_language') ?? 'en';

  runApp(AyaxHalalLinkApp(initialLocale: Locale(savedLangCode)));
}

class AyaxHalalLinkApp extends StatefulWidget {
  final Locale initialLocale;
  const AyaxHalalLinkApp({super.key, required this.initialLocale});

  static void setLocale(BuildContext context, Locale newLocale) {
    _AyaxHalalLinkAppState? state =
        context.findAncestorStateOfType<_AyaxHalalLinkAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<AyaxHalalLinkApp> createState() => _AyaxHalalLinkAppState();
}

class _AyaxHalalLinkAppState extends State<AyaxHalalLinkApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ayax HalalLink',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      // Automatically handles Left-to-Right (LTR) and Right-to-Left (RTL)
      supportedLocales: const [
        Locale('en'), Locale('ar'), Locale('fr'), Locale('es'),
        Locale('ur'), Locale('id'), Locale('ms'), Locale('tr'),
        Locale('bn'), Locale('hi'), Locale('fa'), Locale('sw'),
        Locale('ru'), Locale('de'), Locale('pt'), Locale('zh'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0E6B50), // Emerald Halal Green
          primary: const Color(0xFF0E6B50),
          secondary: const Color(0xFFD4AF37), // Gold Accent
        ),
        useMaterial3: true,
      ),
      home: const LanguageSelectionScreen(),
      // Ƙara Hanyoyin Shafuka (Routes) anan
      routes: {
        '/login': (context) => const LoginScreen(),
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
      },
    );
  }
}