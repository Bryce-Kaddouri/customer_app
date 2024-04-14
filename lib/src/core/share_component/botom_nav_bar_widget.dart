import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';

class BottomNavBarWidget extends StatefulWidget {
  const BottomNavBarWidget({super.key});

  @override
  State<BottomNavBarWidget> createState() => _BottomNavBarWidgetState();
}

class _BottomNavBarWidgetState extends State<BottomNavBarWidget> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: (int index) {
        setState(() {
          this.index = index;
        });
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
      currentIndex: index,
    );
  }
}
