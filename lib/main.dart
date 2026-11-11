import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/app_strings.dart';
import 'providers/auth_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/node_provider.dart';
import 'screens/login_screen.dart';
import 'screens/map_screen.dart';
import 'services/local_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // reads google-services.json / GoogleService-Info.plist
  await LocalStore.init();
  runApp(const NetMapApp());
}

class NetMapApp extends StatelessWidget {
  const NetMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // NodeProvider follows the signed-in user: switching account swaps the data set.
        ChangeNotifierProxyProvider<AuthProvider, NodeProvider>(
          create: (_) => NodeProvider(),
          update: (_, auth, nodes) {
            nodes!.bind(auth.user?.uid);
            return nodes;
          },
        ),
      ],
      child: Consumer<LocaleProvider>(
        builder: (_, lp, __) => MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (c) => S.of(c).t('app_name'),
          locale: lp.locale, // Arabic by default
          supportedLocales: S.supported,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF1565C0),
            inputDecorationTheme:
                const InputDecorationTheme(border: OutlineInputBorder()),
          ),
          home: const _AuthGate(),
        ),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();
  @override
  Widget build(BuildContext context) {
    final signedIn = context.watch<AuthProvider>().user != null;
    return signedIn ? const MapScreen() : const LoginScreen();
  }
}
