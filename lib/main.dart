import 'package:customer_app/src/core/constant/route.dart';
import 'package:customer_app/src/feature/auth/business/repository/auth_repository.dart';
import 'package:customer_app/src/feature/auth/business/usecase/auth_get_user_usecase.dart';
import 'package:customer_app/src/feature/auth/business/usecase/auth_is_looged_in_usecase.dart';
import 'package:customer_app/src/feature/auth/business/usecase/auth_logout_usecase.dart';
import 'package:customer_app/src/feature/auth/business/usecase/auth_on_auth_change_usecase.dart';
import 'package:customer_app/src/feature/auth/business/usecase/send_otp_usecase.dart';
import 'package:customer_app/src/feature/auth/business/usecase/verify_otp_usecase.dart';
import 'package:customer_app/src/feature/auth/data/datasource/auth_datasource.dart';
import 'package:customer_app/src/feature/auth/data/repository/auth_repository_impl.dart';
import 'package:customer_app/src/feature/auth/presentation/provider/auth_provider.dart';
import 'package:customer_app/src/feature/provider/theme_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
/*
import 'package:paged_datatable/l10n/generated/l10n.dart';
*/
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://qlhzemdpzbonyqdecfxn.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFsaHplbWRwemJvbnlxZGVjZnhuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDQ4ODY4MDYsImV4cCI6MjAyMDQ2MjgwNn0.lcUJMI3dvMDT7LaO7MiudIkdxAZOZwF_hNtkQtF3OC8',
  );

  final supabaseAdmin = SupabaseClient(
      'https://qlhzemdpzbonyqdecfxn.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFsaHplbWRwemJvbnlxZGVjZnhuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDQ4ODY4MDYsImV4cCI6MjAyMDQ2MjgwNn0.lcUJMI3dvMDT7LaO7MiudIkdxAZOZwF_hNtkQtF3OC8');
  final supabaseClient = Supabase.instance;
  AuthRepository authRepository =
      AuthRepositoryImpl(dataSource: AuthDataSource());

  // set path strategy
  usePathUrlStrategy();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            authSendOtpUseCase:
                AuthSendOtpUseCase(authRepository: authRepository),
            authLogoutUseCase:
                AuthLogoutUseCase(authRepository: authRepository),
            authGetUserUseCase:
                AuthGetUserUseCase(authRepository: authRepository),
            authIsLoggedInUseCase:
                AuthIsLoggedInUseCase(authRepository: authRepository),
            authOnAuthChangeUseCase:
                AuthOnAuthOnAuthChangeUseCase(authRepository: authRepository),
            authVerifyOtpUseCase:
                AuthVerifyOtpUseCase(authRepository: authRepository),
          ),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  GoRouter? router;

  GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    context.read<ThemeProvider>().getThemeMode();
    router = RouterHelper().getRouter(context);
  }

  @override
  Widget build(BuildContext context) {
    return FluentApp.router(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
/*
        PagedDataTableLocalization.delegate
*/
      ],
      supportedLocales: const [Locale("es"), Locale("en")],
      locale: const Locale("en"),
      theme: FluentThemeData.light(),
      darkTheme: FluentThemeData.dark(),
      themeMode: context.watch<ThemeProvider>().themeMode == 'system'
          ? ThemeMode.system
          : context.watch<ThemeProvider>().themeMode == 'light'
              ? ThemeMode.light
              : ThemeMode.dark,
      /* defaultTransition: Transition.fadeIn,
      scaffoldMessengerKey: scaffoldMessengerKey,*/
      routerDelegate: router!.routerDelegate,
      routeInformationParser: router!.routeInformationParser,
      routeInformationProvider: router!.routeInformationProvider,
      /* routingCallback: (routing) {
        print('route: ${routing?.current}');

        if (routing?.current == '/login') {
          if (context.read<AuthProvider>().checkIsLoggedIn()) {
            routing?.current = '/home';
          }
        } else {
          if (!context.read<AuthProvider>().checkIsLoggedIn()) {
            routing?.current = '/login';
          }
        }
      },*/
      /*getPages: Routes().getPages,
      initialRoute: '/login',
      home: StreamBuilder<AuthState>(
        stream: context.read<AuthProvider>().onAuthStateChange(),
        builder: (context, snapshot) {
          print('snapshot: ${snapshot.connectionState}');
          if (snapshot.connectionState == ConnectionState.active) {
            final user = snapshot.data;
            if (user == null) {
              return SignInScreen();
            } else {
              return const HomeScreen();
            }
          }
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),*/
    );
  }
}
