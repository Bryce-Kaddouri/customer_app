import 'package:fluent_ui/fluent_ui.dart' as fluent;
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
    return fluent.Container(
      padding: const fluent.EdgeInsets.symmetric(horizontal: 16),
      decoration: fluent.BoxDecoration(
        color: fluent.FluentTheme.of(context)
            .navigationPaneTheme
            .overlayBackgroundColor,
        boxShadow: [
          fluent.BoxShadow(
            color: fluent.FluentTheme.of(context).shadowColor.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(0, -2),
            spreadRadius: 2,
          ),
        ],
      ),
      height: 70,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: fluent.MainAxisAlignment.spaceEvenly,
        children: [
          fluent.Expanded(
            child: Container(
              width: double.infinity,
              height: 50,
              child: InkWell(
                onTap: () {
                  context.go('/');
                },
                child: fluent.Column(
                  children: [
                    fluent.Icon(fluent.FluentIcons.product_list,
                        size: 20,
                        color: widget.currentIndex == 0
                            ? Colors.red
                            : fluent.FluentTheme.of(context).inactiveColor),
                    fluent.Text(
                      'Orders',
                      style: fluent.TextStyle(
                          color: widget.currentIndex == 0
                              ? Colors.red
                              : fluent.FluentTheme.of(context).inactiveColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
          fluent.Expanded(
            child: Container(
              width: double.infinity,
              height: 50,
              child: InkWell(
                onTap: () {
                  context.go('/reminder');
                },
                child: fluent.Column(
                  children: [
                    fluent.Icon(fluent.FluentIcons.schedule_event_action,
                        size: 20,
                        color: widget.currentIndex == 1
                            ? Colors.red
                            : fluent.FluentTheme.of(context).inactiveColor),
                    fluent.Text(
                      'Reminders',
                      style: fluent.TextStyle(
                          color: widget.currentIndex == 1
                              ? Colors.red
                              : fluent.FluentTheme.of(context).inactiveColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
          fluent.Expanded(
            child: Container(
              width: double.infinity,
              height: 50,
              child: InkWell(
                onTap: () {
                  context.go('/notifications');
                },
                child: fluent.Column(
                  children: [
                    fluent.Icon(fluent.FluentIcons.ringer_active,
                        size: 20,
                        color: widget.currentIndex == 2
                            ? Colors.red
                            : fluent.FluentTheme.of(context).inactiveColor),
                    fluent.Text('Notifications',
                        style: fluent.TextStyle(
                            color: widget.currentIndex == 2
                                ? Colors.red
                                : fluent.FluentTheme.of(context)
                                    .inactiveColor)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
    /*BottomNavigationBar(
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
      fixedColor: Colors.red,
      */ /*shadowColor: FluentTheme.of(context).shadowColor,
      surfaceTintColor: FluentTheme.of(context).navigationPaneTheme.overlayBackgroundColor,*/ /*
      */ /*backgroundColor: fluent.FluentTheme.of(context).navigationPaneTheme.backgroundColor,*/ /*
      items: const [
        BottomNavigationBarItem(
          icon: Icon(fluent.FluentIcons.product_list),
          label: 'Orders',
          backgroundColor: Colors.blue,
        ),
        BottomNavigationBarItem(
          icon: Icon(fluent.FluentIcons.schedule_event_action),
          label: 'Reminder',
        ),
        BottomNavigationBarItem(
          icon: Icon(fluent.FluentIcons.ringer_active),
          label: 'Notification',
        ),
      ],
      currentIndex: widget.currentIndex,
    );*/
  }
}
