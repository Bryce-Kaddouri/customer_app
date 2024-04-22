import 'package:customer_app/src/core/helper/date_helper.dart';
import 'package:customer_app/src/feature/notification/presentation/provider/notification_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
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

class _NotificationListScreenState extends State<NotificationListScreen> with SingleTickerProviderStateMixin {
  List<NotificationByDate> notificationByDateListOrder = [];
  List<NotificationByDate> notificationByDateListPromotion = [];
  bool isLoading = false;
  int tabIndex = 0;
  late mat.TabController tabController;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    tabController = mat.TabController(length: 2, vsync: this);
    setState(() {
      isLoading = true;
    });
    context.read<NotificationProvider>().getNotifications().then((value) {
      if (value != null) {
        List<NotificationByDate> notificationByDateListTempOrder = [];
        List<NotificationByDate> notificationByDateListTempPromotion = [];
        List<NotificationModel> orderNotifications = value.where((element) => element.type != "PROMOTION").toList();
        List<NotificationModel> promotionNotification = value.where((element) => element.type == "PROMOTION").toList();

        for (var orderNotification in orderNotifications) {
          bool isExist = false;
          for (NotificationByDate notificationByDate in notificationByDateListTempOrder) {
            if (DateHelper.isSameDay(notificationByDate.date, orderNotification.createdAt)) {
              notificationByDate.notifications.add(orderNotification);
              isExist = true;
              break;
            }
          }
          if (!isExist) {
            notificationByDateListTempOrder.add(NotificationByDate(date: orderNotification.createdAt.copyWith(hour: 0, minute: 0, second: 0), notifications: [orderNotification]));
          }
        }

        for (var promotionNotification in promotionNotification) {
          bool isExist = false;
          for (NotificationByDate notificationByDate in notificationByDateListTempPromotion) {
            if (DateHelper.isSameDay(notificationByDate.date, promotionNotification.createdAt)) {
              notificationByDate.notifications.add(promotionNotification);
              isExist = true;
              break;
            }
          }
          if (!isExist) {
            notificationByDateListTempPromotion.add(NotificationByDate(date: promotionNotification.createdAt.copyWith(hour: 0, minute: 0, second: 0), notifications: [promotionNotification]));
          }
        }

        setState(() {
          notificationByDateListOrder = notificationByDateListTempOrder;
          notificationByDateListPromotion = notificationByDateListTempPromotion;
        });
      }
    }).whenComplete(() {
      setState(() {
        isLoading = false;
      });
      print('NotificationListScreen initState');
      print('notificationByDateList');
      print(notificationByDateListOrder);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          : Container(
              child: Column(
                children: [
                  mat.TabBar(
                    controller: tabController,
                    tabs: [
                      mat.Tab(
                        child: Text("Promotion (${notificationByDateListPromotion.fold(0, (previousValue, element) => previousValue + element.notifications.length)})"),
                      ),
                      mat.Tab(
                        child: Text("Order (${notificationByDateListOrder.fold(0, (previousValue, element) => previousValue + element.notifications.length)})"),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      child: mat.TabBarView(
                        controller: tabController,
                        children: [
                          // promotion
                          Container(
                            child: ListView.builder(
                              controller: scrollController,
                              itemCount: notificationByDateListPromotion.length,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return Container(
                                    alignment: Alignment.centerLeft,
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: Text(
                                      DateHelper.getFormattedDate(notificationByDateListPromotion[index].date),
                                      style: FluentTheme.of(context).typography.subtitle,
                                    ),
                                  );
                                }

                                return ListView.builder(
                                    controller: scrollController,
                                    shrinkWrap: true,
                                    itemCount: notificationByDateListPromotion[index].notifications.length,
                                    itemBuilder: (context, indexNotification) {
                                      NotificationModel notification = notificationByDateListPromotion[index].notifications[indexNotification];
                                      return Card(
                                        padding: EdgeInsets.all(0),
                                        margin: EdgeInsets.only(bottom: 10),
                                        child: ListTile(
                                          onPressed: () {
                                            context.push<NotificationModel>('/notification/detail', extra: notification);
                                          },
                                          leading: Image.network(
                                            notification.photoUrl ?? '',
                                            fit: BoxFit.cover,
                                            height: 50,
                                            width: 50,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                width: 0,
                                              );
                                            },
                                          ),
                                          title: Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              notification.title ?? '',
                                              style: FluentTheme.of(context).typography.subtitle,
                                            ),
                                          ),
                                          subtitle: Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              notification.body ?? '',
                                              style: FluentTheme.of(context).typography.body,
                                            ),
                                          ),
                                        ),
                                      );
                                    });
                              },
                            ),
                          ),
                          Container(
                            child: ListView.builder(
                              itemCount: notificationByDateListOrder.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    for (NotificationByDate notificationByDate in notificationByDateListOrder) ...[
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
                                          padding: EdgeInsets.all(0),
                                          margin: EdgeInsets.only(bottom: 10),
                                          child: ListTile(
                                            onPressed: () {
                                              context.push('/orders/${DateHelper.getFormattedDate(notification.order_date!)}/${notification.orderId}');
                                            },
                                            leading: Container(
                                              height: 50,
                                              width: 50,
                                              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 1)),
                                              child: notification.type == 'INSERT'
                                                  ? Icon(
                                                      FluentIcons.product_list,
                                                      size: 24,
                                                    )
                                                  : Icon(
                                                      FluentIcons.product_release,
                                                      size: 24,
                                                    ),
                                            ),
                                            title: Container(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                notification.title ?? '',
                                                style: FluentTheme.of(context).typography.subtitle,
                                              ),
                                            ),
                                            subtitle: Container(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                notification.body ?? '',
                                                style: FluentTheme.of(context).typography.body,
                                              ),
                                            ),
                                            trailing: Icon(FluentIcons.chevron_right),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ],
                                );
                              },
                            ),
                          ),

                          // orders
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
