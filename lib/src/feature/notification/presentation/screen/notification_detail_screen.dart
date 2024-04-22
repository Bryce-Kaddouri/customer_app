import 'package:customer_app/src/core/helper/date_helper.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:go_router/go_router.dart';

import '../../data/model/notification_model.dart';

class NotificationDetailScreen extends StatefulWidget {
  final NotificationModel notification;
  const NotificationDetailScreen({super.key, required this.notification});

  @override
  State<NotificationDetailScreen> createState() => _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  bool isImageError = false;

  @override
  Widget build(BuildContext context) {
    return material.Scaffold(
      backgroundColor: FluentTheme.of(context).navigationPaneTheme.backgroundColor,
      appBar: material.AppBar(
        leading: material.BackButton(
          onPressed: () async {
            context.pop();
          },
        ),
        centerTitle: true,
        shadowColor: FluentTheme.of(context).shadowColor,
        surfaceTintColor: FluentTheme.of(context).navigationPaneTheme.backgroundColor,
        backgroundColor: FluentTheme.of(context).navigationPaneTheme.backgroundColor,
        elevation: 4,
        title: Text('Notification Detail'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateHelper.getFormattedDateTime(widget.notification.createdAt),
              style: FluentTheme.of(context).typography.subtitle!.copyWith(fontWeight: FontWeight.normal, fontSize: 16),
            ),
            Text(
              widget.notification.title ?? '',
              style: FluentTheme.of(context).typography.titleLarge,
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: FluentTheme.of(context).shadowColor.withOpacity(0.2),
                    blurRadius: 2,
                    offset: const Offset(0, 2),
                    spreadRadius: 2,
                  ),
                ],
              ),
              width: double.infinity,
              child: /*Image.network(
                widget.notification.photoUrl ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container();
                },
              ),*/

                  ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.notification.photoUrl ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container();
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.notification.body,
              style: FluentTheme.of(context).typography.body,
            ),
          ],
        ),
      ),
    );
  }
}
