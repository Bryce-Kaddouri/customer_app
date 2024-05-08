import 'package:customer_app/src/core/constant/app_color.dart';
import 'package:customer_app/src/feature/auth/presentation/screen/otp_screen.dart';
import 'package:customer_app/src/feature/notification/data/model/notification_model.dart';
import 'package:customer_app/src/feature/notification/presentation/screen/notification_detail_screen.dart';
import 'package:customer_app/src/feature/reminder/presentation/screen/reminder_list_screen.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' hide IconButton, Button, ButtonStyle, Colors, ListTile, Card;
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../feature/auth/presentation/provider/auth_provider.dart';
import '../../feature/auth/presentation/screen/signin_screen.dart';
import '../../feature/notification/presentation/screen/notification_list_screen.dart';
import '../../feature/order/presentation/screen/order_detail_screen.dart';
import '../../feature/order/presentation/screen/order_screen.dart';
import '../../feature/reminder/presentation/screen/callendar_event_screen.dart';
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
                builder: (context, state) => /* ReminderScreen()*/ RemindersListScreen(),
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
        GoRoute(
          path: '/reminder/detail/:id',
          builder: (context, state) {
            print(state.pathParameters);
            Map<String, dynamic>? extra = state.extra as Map<String, dynamic>?;
            return CalendarEventPage(
              extra: extra,
            );
          },
        ),
        GoRoute(
          path: '/notification/detail',
          builder: (context, state) {
            NotificationModel notification = state.extra as NotificationModel;
            return NotificationDetailScreen(
              notification: notification,
            );
          },
        ),
        GoRoute(
          path: '/reminder/add',
          builder: (context, state) {
            print(state.pathParameters);
            print(state.extra);
            Map<String, dynamic>? extra = state.extra as Map<String, dynamic>?;
            return CalendarEventPage(
              extra: extra,
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
  FlyoutController flyController = FlyoutController();

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
          /*IconButton(
            icon: Icon(
              FluentIcons.settings,
              size: 24,
            ),
            onPressed: () {},
          ),*/

          widget.currentIndex == 0
              ? FlyoutTarget(
                  controller: flyController,
                  child: Container(
                      height: 40,
                      width: 40,
                      child: Button(
                        style: ButtonStyle(
                          backgroundColor: ButtonState.all(FluentTheme.of(context).navigationPaneTheme.backgroundColor),
                          elevation: ButtonState.all(4),
                          padding: ButtonState.all(EdgeInsets.all(0)),
                          shape: ButtonState.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                        ),
                        child: const Icon(FluentIcons.contact, size: 24),
                        onPressed: () {
                          flyController.showFlyout(
                            autoModeConfiguration: FlyoutAutoConfiguration(
                              preferredMode: FlyoutPlacementMode.topRight,
                            ),
                            barrierDismissible: true,
                            dismissOnPointerMoveAway: false,
                            dismissWithEsc: true,
                            position: Offset(
                              MediaQuery.of(context).size.width - 10,
                              60,
                            ),
                            builder: (context) {
                              return FlyoutContent(
                                child: Container(
                                  width: 200,
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Card(
                                        padding: const EdgeInsets.all(0),
                                        child: ListTile(
                                          leading: const Icon(FluentIcons.contact),
                                          title: const Text(
                                            'Profile',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12.0),
                                      Card(
                                        padding: const EdgeInsets.all(0),
                                        backgroundColor: AppColor.canceledBackgroundColor,
                                        child: ListTile(
                                          onPressed: () {
                                            context.read<AuthProvider>().logout().then((value) {
                                              context.go('/signin');
                                            });
                                          },
                                          tileColor: ButtonState.all(Colors.transparent),
                                          leading: const Icon(FluentIcons.sign_out, color: AppColor.canceledForegroundColor),
                                          title: const Text(
                                            'Sign out',
                                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColor.canceledForegroundColor),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                /*Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'All items will be removed. Do you want to continue?',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12.0),
                            Button(
                              onPressed: Flyout.of(context).close,
                              child: const Text('Yes, empty my cart'),
                            ),
                          ],
                        ),*/
                              );
                            },
                          );
                        },
                      )))
              : widget.currentIndex == 1
                  ? Button(
                      style: ButtonStyle(
                        backgroundColor: ButtonState.all(FluentTheme.of(context).navigationPaneTheme.backgroundColor),
                        padding: ButtonState.all(EdgeInsets.all(0)),
                      ),
                      child: Container(
                        height: 40,
                        width: 40,
                        child: Icon(
                          FluentIcons.add_event,
                          size: 24,
                        ),
                      ),
                      onPressed: () {
                        context.push('/reminder/add');
                      },
                    )
                  : SizedBox(),
          SizedBox(width: 10),
        ],
      ),
      body: SafeArea(child: widget.child),
      bottomNavigationBar: BottomNavBarWidget(
        currentIndex: widget.currentIndex,
      ),
    );
  }
}
