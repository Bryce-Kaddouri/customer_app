import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBarWidget extends StatefulWidget {
  final int currentIndex;
  const BottomNavBarWidget({super.key, required this.currentIndex});

  @override
  State<BottomNavBarWidget> createState() => _BottomNavBarWidgetState();
}

class _BottomNavBarWidgetState extends State<BottomNavBarWidget> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: (int index) {
        if (index == 0) {
          context.go('/');
        } else if (index == 1) {
          context.go('/reminder');
        } else if (index == 2) {
          context.go('/notifications');
        }
      },
      elevation: 0,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(FluentIcons.product_list),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(FluentIcons.schedule_event_action),
          label: 'Reminder',
        ),
        BottomNavigationBarItem(
          icon: Icon(FluentIcons.ringer_active),
          label: 'Notification',
        ),
      ],
      currentIndex: widget.currentIndex,
    );
  }
}
