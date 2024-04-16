import 'package:customer_app/src/feature/auth/presentation/screen/otp_screen.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' hide IconButton;
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../main.dart';
import '../../feature/auth/presentation/provider/auth_provider.dart';
import '../../feature/auth/presentation/screen/signin_screen.dart';
import '../../feature/notification/presentation/screen/notification_list_screen.dart';
import '../../feature/order/presentation/screen/order_detail_screen.dart';
import '../../feature/order/presentation/screen/order_screen.dart';
import '../share_component/botom_nav_bar_widget.dart';

/*class Routes {
  static const String home = '/home';
  static const String login = '/login';

  final getPages = [
    GetPage(
      participatesInRootNavigator: true,
      name: Routes.home,
      page: () => HomeScreen(),
      transition: Transition.zoom,
      children: [],
    ),
    GetPage(
      participatesInRootNavigator: true,
      name: Routes.login,
      page: () => SignInScreen(),
      transition: Transition.zoom,
      children: [],
    ),
  ];
}*/

class RouterHelper {
  GoRouter getRouter(BuildContext context) {
    return GoRouter(
      navigatorKey: Get.key,
      redirect: (context, state) {
        // check if user is logged in
        // if not, redirect to login page

        print('state: ${state.matchedLocation}');
        print('state: ${state.uri}');

        bool isLoggedIn = context.read<AuthProvider>().checkIsLoggedIn();
        print('isLoggedIn: $isLoggedIn');

        if (!isLoggedIn) {
          if (state.uri.path.startsWith('/otp')) {
            return state.uri.path;
          }
          return '/signin';
        } else {
          return state.uri.path;
        }
      },
      initialLocation: context.read<AuthProvider>().checkIsLoggedIn() ? '/' : '/signin',
      routes: [
        /*GoRoute(
          path: '/',
          builder: (context, state) => HomeScreen(),
        ),
        GoRoute(
          path: '/notification',
          builder: (context, state) => NotificationListScreen(),
        ),*/

        GoRoute(
          path: '/test',
          builder: (context, state) => HomePage(null),
        ),
        GoRoute(
          path: '/second/:payload',
          builder: (context, state) => SecondPage(state.pathParameters['payload']),
        ),
        ShellRoute(
            builder: (BuildContext context, GoRouterState state, Widget child) {
              print('state.uri.path: ${state.uri.path}');
              int currentIndex = 0;
              if (state.uri.path == '/notifications') {
                currentIndex = 2;
              } else if (state.uri.path == '/reminder') {
                currentIndex = 1;
              }
              return BottomNavigationBarScaffold(child: child, currentIndex: currentIndex);
            },
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => OrderScreen(),
              ),
              GoRoute(
                path: '/notifications',
                builder: (context, state) => NotificationListScreen(),
              ),
              GoRoute(
                path: '/reminder',
                builder: (context, state) => Container(),
              ),
            ]),
        GoRoute(
          path: '/orders/:date/:id',
          builder: (context, state) {
            print(state.pathParameters);
            if (state.pathParameters.isEmpty || state.pathParameters['id'] == null || state.pathParameters['date'] == null) {
              return ScaffoldPage(
                  content: Center(
                child: Text('Loading...'),
              ));
            } else {
              int orderId = int.parse(state.pathParameters['id']!);
              DateTime orderDate = DateTime.parse(state.pathParameters['date']!);
              return OrderDetailScreen(orderId: orderId, orderDate: orderDate);
            }
          },
        ),
        GoRoute(
          path: '/signin',
          builder: (context, state) => SignInScreen(),
        ),
        GoRoute(
          name: 'otp',
          path: '/otp/:phone',
          builder: (context, state) {
            print(state.uri.path);
            print(state.uri.queryParameters);
            String phone = state.pathParameters['phone']!;
            return OtpScreen(
              phoneNumber: phone,
            );
          },
        ),
      ],
    );
  }
}

class BottomNavigationBarScaffold extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  const BottomNavigationBarScaffold({super.key, required this.child, required this.currentIndex});

  @override
  State<BottomNavigationBarScaffold> createState() => _BottomNavigationBarScaffoldState();
}

class _BottomNavigationBarScaffoldState extends State<BottomNavigationBarScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FluentTheme.of(context).navigationPaneTheme.backgroundColor,
      appBar: AppBar(
        elevation: 2,
        shadowColor: FluentTheme.of(context).shadowColor,
        surfaceTintColor: FluentTheme.of(context).navigationPaneTheme.overlayBackgroundColor,
        backgroundColor: FluentTheme.of(context).navigationPaneTheme.overlayBackgroundColor,
        centerTitle: true,
        title: Text(
          widget.currentIndex == 0
              ? 'Orders'
              : widget.currentIndex == 1
                  ? 'Reminders'
                  : 'Notifications',
        ),
        actions: [
          IconButton(
            icon: Icon(
              FluentIcons.settings,
              size: 24,
            ),
            onPressed: () {},
          ),
          SizedBox(width: 10),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: BottomNavBarWidget(
        currentIndex: widget.currentIndex,
      ),
    );
  }
}
