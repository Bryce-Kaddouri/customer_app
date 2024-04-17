import 'dart:convert';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:customer_app/src/feature/auth/presentation/provider/auth_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../main.dart';
import '../../../../core/helper/date_helper.dart';
import '../../../../core/helper/notification_helper.dart';
import '../../data/model/order_model.dart';
import '../provider/order_provider.dart';
import '../widget/order_item_view_by_status_widget.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

// keep alive mixin
class _OrderScreenState extends State<OrderScreen>
    with AutomaticKeepAliveClientMixin {
  ScrollController _mainScrollController = ScrollController();
  ScrollController _testController = ScrollController();
  List<DateTime> lstWeedDays = [];

  void initNotif(BuildContext context) async {
    const String urlLaunchActionId = 'id_1';

    /// A notification action which triggers a App navigation event
    const String navigationActionId = 'id_3';

    /// Defines a iOS/MacOS notification category for text input actions.
    const String darwinNotificationCategoryText = 'textCategory';

    /// Defines a iOS/MacOS notification category for plain actions.
    const String darwinNotificationCategoryPlain = 'plainCategory';

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final List<DarwinNotificationCategory> darwinNotificationCategories =
        <DarwinNotificationCategory>[
      DarwinNotificationCategory(
        darwinNotificationCategoryText,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.text(
            'text_1',
            'Action 1',
            buttonTitle: 'Send',
            placeholder: 'Placeholder',
          ),
        ],
      ),
      DarwinNotificationCategory(
        darwinNotificationCategoryPlain,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.plain('id_1', 'Action 1'),
          DarwinNotificationAction.plain(
            'id_2',
            'Action 2 (destructive)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.destructive,
            },
          ),
          DarwinNotificationAction.plain(
            navigationActionId,
            'Action 3 (foreground)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.foreground,
            },
          ),
          DarwinNotificationAction.plain(
            'id_4',
            'Action 4 (auth required)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.authenticationRequired,
            },
          ),
        ],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      )
    ];

    /// Note: permissions aren't requested here just to demonstrate that can be
    /// done later
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        /* didReceiveLocalNotificationStream.add(
          ReceivedNotification(
            id: id,
            title: title,
            body: body,
            payload: payload,
          ),
        );*/
      },
      notificationCategories: darwinNotificationCategories,
    );
    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(
      defaultActionName: 'Open notification',
      defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        print('onDidReceiveNotificationResponse');
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            print(notificationResponse.payload);
            if (notificationResponse.payload != null) {
              print(
                  'notificationResponse.payload from on tap: ${notificationResponse.payload}');
              Map<String, dynamic> payload =
                  jsonDecode(notificationResponse.payload!);
              if (payload['order_date'] != null &&
                  payload['order_id'] != null) {
                print(
                    'notificationResponse.payload id: ${payload['order_id']}');
                print(
                    'notificationResponse.payload date: ${payload['order_date']}');
                context.push(
                    '/orders/${payload['order_date']}/${payload['order_id']}');
              }
            }

            selectNotificationStream.add(notificationResponse.payload);

            break;
          case NotificationResponseType.selectedNotificationAction:
            if (notificationResponse.actionId == navigationActionId) {
              print('tap on add calendar');

              print(
                  'notificationResponse.payload from on tap: ${notificationResponse.payload}');

              if (notificationResponse.payload != null) {
                print(
                    'notificationResponse.payload from on tap: ${notificationResponse.payload}');
                Map<String, dynamic> payload =
                    jsonDecode(notificationResponse.payload!);
                if (payload['order_date'] != null &&
                    payload['order_id'] != null &&
                    payload['order_hour'] != null) {
                  print(
                      'notificationResponse.payload id: ${payload['order_id']}');
                  print(
                      'notificationResponse.payload date: ${payload['order_date']}');
                  DateTime orderDate = DateTime.parse(payload['order_date']);
                  List<String> orderHour = payload['order_hour'].split(':');
                  material.TimeOfDay hour = material.TimeOfDay(
                      hour: int.parse(orderHour[0]),
                      minute: int.parse(orderHour[1]));
                  print('Add to calendar');
                  final Event event = Event(
                    title: 'Customer App - Collect Order',
                    description:
                        'Collect Your Order at ${hour.format(context)}',
                    location:
                        '7 Castle View Rd, Clondalkin, Dublin 22, D22 V082, Irlande',
                    /*  recurrence: Recurrence(
                        frequency: Frequency.daily,
                        ocurrences: 2,
                        endDate: hour.hour < 8
                            ? orderDate
                                .copyWith(
                                    hour: hour.hour,
                                    minute: hour.minute,
                                    second: 0)
                                .subtract(Duration(hours: 2))
                            : orderDate.copyWith(hour: 8, minute: 8, second: 8),
                        interval: 1),*/

                    startDate: orderDate.copyWith(
                        hour: hour.hour, minute: hour.minute, second: 0),
                    endDate: orderDate.copyWith(
                        hour: hour.hour, minute: hour.minute, second: 0),
                    iosParams: IOSParams(
                      reminder: Duration(
                          hours:
                              1), // on iOS, you can set alarm notification after your event.
                    ),
                    androidParams: AndroidParams(
                      emailInvites: [], // on Android, you can add invite emails to your event.
                    ),
                  );

                  Add2Calendar.addEvent2Cal(event);
                }
              }

              /*selectNotificationStream.add(notificationResponse.payload);*/
            }
            break;
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  void streamInit() async {
    selectNotificationStream.stream.listen((String? payload) async {
      print('selectNotificationStream: $payload');

      context.push('/second/$payload');
    }); // listen to message when app is in foreground
  }

  void getToken() async {
    String? firebaseToken = await FirebaseMessaging.instance.getToken(
        vapidKey:
            'BIfSAPxXNxdo1Op2i2QY9XY4orb7QclmiGD5fOmKfwB9UbS1MDZXjT1KInp0xuqyu5VK8AtIhWk0A8_yB9s0lyQ');
    print('firebase token');
    print(firebaseToken);
    User? currentUser = context.read<AuthProvider>().getUser();
    String? currentFcmToken = currentUser?.userMetadata?['fcm_token'];

    print('current fcm token');
    print(currentFcmToken);

    if (firebaseToken != null && currentFcmToken != firebaseToken) {
      bool res = await context
          .read<AuthProvider>()
          .updateUserData({'fcm_token': firebaseToken});
    }
    print('res');
  }

  @override
  void initState() {
    super.initState();

    MessagingService().requestPermission();

    getToken();
    streamInit();
    initNotif(context);

    MessagingService().listenMessage(
      context,
    );
    // listen to message when app is in background
    MessagingService().listenMessageBackground(
      context,
    );

    setState(() {
      lstWeedDays =
          DateHelper.getDaysInWeek(context.read<OrderProvider>().selectedDate);
    });
  }

  @override
  void dispose() {
    didReceiveLocalNotificationStream.close();
    selectNotificationStream.close();
    super.dispose();
  }

  Future<DateTime?> selectDate() async {
    // global key for the form
    /*return material.showDatePicker(
        context: context,
        currentDate: context.read<OrderProvider>().selectedDate,
        initialDate: context.read<OrderProvider>().selectedDate,
        // first date of the year
        firstDate: DateTime.now().subtract(Duration(days: 365)),
        lastDate: DateTime.now().add(Duration(days: 365)));*/

    return await showDialog<DateTime?>(
        context: context,
        builder: (context) {
          DateTime selectedDate = context.read<OrderProvider>().selectedDate;
          return ContentDialog(
            title: Container(
              alignment: Alignment.center,
              child: Text(
                'Select Date',
              ),
            ),
            content: material.Card(
              surfaceTintColor: FluentTheme.of(context)
                  .navigationPaneTheme
                  .overlayBackgroundColor,
              elevation: 4,
              margin: EdgeInsets.zero,
              child: material.CalendarDatePicker(
                initialDate: context.read<OrderProvider>().selectedDate,
                firstDate: DateTime.now().subtract(Duration(days: 365)),
                lastDate: DateTime.now().add(Duration(days: 365)),
                onDateChanged: (DateTime value) {
                  selectedDate = value;
                },
              ),
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(context, selectedDate);
                },
                child: Text('Confirm'),
              ),
              Button(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: CustomScrollView(controller: _mainScrollController, slivers: [
      FutureBuilder(
        future: context.read<OrderProvider>().getOrdersByCustomerId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              List<Map<String, dynamic>> lstDayMap = [];

              List<OrderModel> orderList = snapshot.data as List<OrderModel>;
              List<DateTime> lstDayDistinct =
                  orderList.map((e) => e.date).toSet().toList();
              print('order list length');
              print(orderList.length);

              for (var date in lstDayDistinct) {
                List<OrderModel> orderListOfTheDay =
                    orderList.where((element) => element.date == date).toList();

                Map<String, dynamic> map = {
                  'date': date,
                  'order': orderListOfTheDay,
                };
                lstDayMap.add(map);
              }

              if (lstDayMap.isEmpty) {
                return SliverToBoxAdapter(
                  child: Container(
                    height: MediaQuery.of(context).size.height - 200,
                    alignment: Alignment.center,
                    child: Text("No order found"),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    Map<String, dynamic> data = lstDayMap[index];
                    return Container(
                      padding: EdgeInsets.all(8),
                      child: Expander(
                        initiallyExpanded: true,
                        header: Container(
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${DateHelper.getFormattedDate(data['date'])}',
                                style: FluentTheme.of(context)
                                    .typography
                                    .subtitle!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              RichText(
                                  text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${data['order'].length}',
                                    style: FluentTheme.of(context)
                                        .typography
                                        .subtitle!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  TextSpan(
                                    text: ' orders',
                                    style: FluentTheme.of(context)
                                        .typography
                                        .subtitle!
                                        .copyWith(
                                          fontWeight: FontWeight.normal,
                                        ),
                                  ),
                                ],
                              ))
                            ],
                          ),
                        ),
                        content: Column(
                          children: List.generate(
                            data['order'].length,
                            (index) => OrdersItemViewByStatus(
                              status: data['order'][index].status.name,
                              order: data['order'][index],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: lstDayMap.length,
                ),
              );
            } else {
              return SliverToBoxAdapter(
                child: Container(
                  alignment: Alignment.center,
                  child: Text("No order"),
                ),
              );
            }
          } else {
            return SliverToBoxAdapter(
              child: Container(
                height: MediaQuery.of(context).size.height - 200,
                width: double.infinity,
                alignment: Alignment.center,
                child: ProgressRing(),
              ),
            );
          }
        },
      ),
    ]));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => false;
}

class HorizontalSliverList extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets listPadding;
  final Widget? divider;

  const HorizontalSliverList({
    required this.children,
    this.listPadding = const EdgeInsets.all(8),
    this.divider,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: listPadding,
          child: Row(children: [
            for (var i = 0; i < children.length; i++) ...[
              children[i],
              if (i != children.length - 1) addDivider(),
            ],
          ]),
        ),
      ),
    );
  }

  Widget addDivider() =>
      divider ?? Padding(padding: const EdgeInsets.symmetric(horizontal: 8));
}
