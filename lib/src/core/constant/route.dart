import 'package:customer_app/src/feature/auth/presentation/screen/otp_screen.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../feature/auth/presentation/provider/auth_provider.dart';
import '../../feature/auth/presentation/screen/signin_screen.dart';
import '../../feature/home/presentation/screen/home_screen.dart';
import '../../feature/order/presentation/screen/order_detail_screen.dart';

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
      initialLocation:
          context.read<AuthProvider>().checkIsLoggedIn() ? '/' : '/signin',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => HomeScreen(),
        ),
        GoRoute(
          path: '/orders/:date/:id',
          builder: (context, state) {
            print(state.pathParameters);
            if (state.pathParameters.isEmpty ||
                state.pathParameters['id'] == null ||
                state.pathParameters['date'] == null) {
              return ScaffoldPage(
                  content: Center(
                child: Text('Loading...'),
              ));
            } else {
              int orderId = int.parse(state.pathParameters['id']!);
              DateTime orderDate =
                  DateTime.parse(state.pathParameters['date']!);
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
