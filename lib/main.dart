import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'state/app_state.dart';
import 'pages/app_shell.dart';
import 'pages/welcome_view.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
    _appState.init();
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      state: _appState,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "L'Artisan Dulce",
        theme: ThemeData(useMaterial3: true, fontFamily: 'Poppins'),
        home: ListenableBuilder(
          listenable: _appState,
          builder: (context, _) {
            if (_appState.isLoadingAuth) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _appState.isSignedIn
                  ? const AppShell(key: ValueKey('shell'))
                  : WelcomeView(
                      key: const ValueKey('welcome'),
                      onSignIn: _appState.signInWithEmail,
                      onRegister: _appState.registerWithEmail,
                    ),
            );
          },
        ),
      ),
    );
  }
}
