import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'pages/app_shell.dart';
import 'pages/welcome_view.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/cart_viewmodel.dart';
import 'viewmodels/favorites_viewmodel.dart';
import 'viewmodels/navigation_viewmodel.dart';
import 'viewmodels/orders_viewmodel.dart';
import 'viewmodels/products_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()..init()),
        ChangeNotifierProvider(create: (_) => NavigationViewModel()),
        ChangeNotifierProvider(create: (_) => ProductsViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => FavoritesViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        ChangeNotifierProvider(create: (_) => OrdersViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "L'Artisan Dulce",
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      ),
      home: Consumer<AuthViewModel>(
        builder: (context, auth, _) {
          if (auth.isLoadingAuth) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (auth.isSignedIn) {
            // Load data when user signs in
            context.read<ProfileViewModel>().loadProfile();
            context.read<FavoritesViewModel>().loadFavorites();
            context.read<CartViewModel>().loadCart();
            context.read<OrdersViewModel>().loadOrders();
            
            return const AppShell(key: ValueKey('shell'));
          } else {
            return WelcomeView(
              key: const ValueKey('welcome'),
              onSignIn: auth.signInWithEmail,
              onRegister: auth.registerWithEmail,
            );
          }
        },
      ),
    );
  }
}
