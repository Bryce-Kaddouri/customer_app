import 'package:customer_app/src/core/helper/date_helper.dart';
import 'package:customer_app/src/feature/notification/presentation/provider/notification_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/model/notification_model.dart';

class NotificationByDate {
  final DateTime date;
  final List<NotificationModel> notifications;

  NotificationByDate({required this.date, required this.notifications});
}

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  List<NotificationByDate>? notificationByDateList;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    context.read<NotificationProvider>().getNotifications().then((value) {
      if (value != null) {
        List<NotificationByDate> notificationByDateListTemp = [];
        for (NotificationModel notification in value) {
          bool isExist = false;
          for (NotificationByDate notificationByDate in notificationByDateListTemp!) {
            if (DateHelper.isSameDay(notificationByDate.date, notification.createdAt)) {
              notificationByDate.notifications.add(notification);
              isExist = true;
              break;
            }
          }
          if (!isExist) {
            notificationByDateListTemp!.add(NotificationByDate(date: notification.createdAt.copyWith(hour: 0, minute: 0, second: 0), notifications: [notification]));
          }
        }
        print('notificationByDateListTemp');
        print(notificationByDateListTemp);
        setState(() {
          notificationByDateList = notificationByDateListTemp;
        });
      }
    }).whenComplete(() {
      setState(() {
        isLoading = false;
      });
      print('NotificationListScreen initState');
      print('notificationByDateList');
      print(notificationByDateList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          minHeight: MediaQuery.of(context).size.height - 60,
        ),
        color: FluentTheme.of(context).navigationPaneTheme.overlayBackgroundColor,
        child: isLoading
            ? Center(
                child: ProgressRing(),
              )
            : Column(
                children: [
                  Button(
                    onPressed: () async {
                      context.go('/test');
                    },
                    child: Text('Refresh'),
                  ),
                  for (NotificationByDate notificationByDate in notificationByDateList!) ...[
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(bottom: 10),
                      child: Text(
                        DateHelper.getFormattedDate(notificationByDate.date),
                        style: FluentTheme.of(context).typography.subtitle,
                      ),
                    ),
                    for (NotificationModel notification in notificationByDate.notifications) ...[
                      Card(
                        margin: EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  notification.title ?? '',
                                  style: FluentTheme.of(context).typography.subtitle,
                                ),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  notification.body ?? '',
                                  style: FluentTheme.of(context).typography.body,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
      ),
    );
  }
}
