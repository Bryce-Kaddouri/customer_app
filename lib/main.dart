import 'package:customer_app/src/core/constant/route.dart';
import 'package:customer_app/src/feature/auth/business/repository/auth_repository.dart';
import 'package:customer_app/src/feature/auth/business/usecase/auth_get_user_usecase.dart';
import 'package:customer_app/src/feature/auth/business/usecase/auth_is_looged_in_usecase.dart';
import 'package:customer_app/src/feature/auth/business/usecase/auth_logout_usecase.dart';
import 'package:customer_app/src/feature/auth/business/usecase/auth_on_auth_change_usecase.dart';
import 'package:customer_app/src/feature/auth/business/usecase/send_otp_usecase.dart';
import 'package:customer_app/src/feature/auth/business/usecase/update_user_data.dart';
import 'package:customer_app/src/feature/auth/business/usecase/verify_otp_usecase.dart';
import 'package:customer_app/src/feature/auth/data/datasource/auth_datasource.dart';
import 'package:customer_app/src/feature/auth/data/repository/auth_repository_impl.dart';
import 'package:customer_app/src/feature/auth/presentation/provider/auth_provider.dart';
import 'package:customer_app/src/feature/order/business/repository/order_repository.dart';
import 'package:customer_app/src/feature/order/business/usecase/order_get_order_by_id_usecase.dart';
import 'package:customer_app/src/feature/order/business/usecase/order_get_orders_by_customer_id_usecase.dart';
import 'package:customer_app/src/feature/order/data/datasource/order_datasource.dart';
import 'package:customer_app/src/feature/order/data/repository/order_repository_impl.dart';
import 'package:customer_app/src/feature/order/presentation/provider/order_provider.dart';
import 'package:customer_app/src/feature/provider/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
/*
import 'package:paged_datatable/l10n/generated/l10n.dart';
*/
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupFlutterNotifications();
  showFlutterNotification(message);
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print('Handling a background message ${message.messageId}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null && !kIsWeb) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          // TODO add a proper drawable resource to android, for now using
          //      one that already exists in example app.
          icon: 'launch_background',
        ),
      ),
    );
  }
}

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    await setupFlutterNotifications();
  }
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
  OrderRepository orderRepository =
      OrderRepositoryImpl(orderDataSource: OrderDataSource());

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
            authUpdateUserDataUseCase:
                AuthUpdateUserDataUseCase(authRepository: authRepository),
          ),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(),
        ),
        ChangeNotifierProvider<OrderProvider>(
          create: (context) => OrderProvider(
              orderGetOrdersByCustomerIdUseCase:
                  OrderGetOrdersByCustomerIdUseCase(
                      orderRepository: orderRepository),
              orderGetOrdersByIdUseCase:
                  OrderGetOrdersByIdUseCase(orderRepository: orderRepository)),
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

  String? _token;
  late Stream<String> _tokenStream;

  void setToken(String? token) {
    print('FCM Token: $token');
    setState(() {
      _token = token;
    });
  }

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen(showFlutterNotification);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      /*Navigator.pushNamed(
        context,
        '/message',
        arguments: MessageArguments(message, true),
      );*/
    });
    FirebaseMessaging.instance
        .getToken(
            vapidKey:
                'BIfSAPxXNxdo1Op2i2QY9XY4orb7QclmiGD5fOmKfwB9UbS1MDZXjT1KInp0xuqyu5VK8AtIhWk0A8_yB9s0lyQ')
        .then(setToken);
    _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
    _tokenStream.listen(setToken);
    context.read<ThemeProvider>().getThemeMode();
    router = RouterHelper().getRouter(context);

    print(_token);
    // request permission for local notification
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
