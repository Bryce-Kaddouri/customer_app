import 'package:customer_app/src/core/share_component/botom_nav_bar_widget.dart';
import 'package:customer_app/src/feature/order/presentation/screen/order_screen.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return material.Scaffold(
      backgroundColor:
          FluentTheme.of(context).navigationPaneTheme.backgroundColor,
      appBar: material.AppBar(
        elevation: 2,
        shadowColor: FluentTheme.of(context).shadowColor,
        surfaceTintColor:
            FluentTheme.of(context).navigationPaneTheme.overlayBackgroundColor,
        backgroundColor:
            FluentTheme.of(context).navigationPaneTheme.overlayBackgroundColor,
        centerTitle: true,
        title: Text(
          'Home',
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
      body: OrderScreen(),
      bottomNavigationBar: BottomNavBarWidget(),
    );
  }
}
