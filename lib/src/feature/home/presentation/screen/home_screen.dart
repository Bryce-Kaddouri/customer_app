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
        elevation: 4,
        shadowColor: FluentTheme.of(context).shadowColor,
        surfaceTintColor:
            FluentTheme.of(context).navigationPaneTheme.backgroundColor,
        backgroundColor:
            FluentTheme.of(context).navigationPaneTheme.backgroundColor,
        centerTitle: true,
        title: Text(
          'Home',
        ),
      ),
      body: Container(),
    );
  }
}
