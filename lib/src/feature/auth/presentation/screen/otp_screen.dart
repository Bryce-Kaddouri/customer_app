import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' as material;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';
import '../widget/pinput_widget.dart';

class OtpScreen extends StatelessWidget {
  final String phoneNumber;
  OtpScreen({super.key, required this.phoneNumber});

  // global key for the form
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();

  // key for stream builder
  final StreamController<int> _streamController = StreamController<int>();

  void resetStream() {
    _streamController.add(0);
  }

  Stream<int> startTimer() async* {
    for (int i = 0; i < 60; i++) {
      await Future.delayed(const Duration(seconds: 1));
      _streamController.add(i);
      yield i;
    }
  }

  void displayInfoBarCustom(
    BuildContext context,
    String title,
    String content,
    InfoBarSeverity severity,
  ) {
    displayInfoBar(
      context,
      builder: (context, close) {
        return InfoBar(
          title: Text(title),
          content: Text(content),
          action: IconButton(
            icon: const Icon(FluentIcons.clear),
            onPressed: close,
          ),
          severity: severity,
        );
      },
      alignment: Alignment.topRight,
      duration: const Duration(seconds: 5),
    );
  }

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
          'Confirm OTP',
        ),
        leading: material.BackButton(
          onPressed: () {
            context.go('/signin');
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(height: 20),
              Text(
                'Enter the OTP sent to $phoneNumber',
                style: FluentTheme.of(context).typography.title,
              ),
              FilledRoundedPinPut(
                controller: _otpController,
              ),
              const SizedBox(height: 20),
              StreamBuilder(
                stream: startTimer(),
                builder: (context, snapshot) {
                  print('snapshot: $snapshot');
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return const Text('none');
                    case ConnectionState.waiting:
                      return const Text('waiting');
                    case ConnectionState.done:
                      return RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'Didn\'t receive the OTP?\n\n',
                          style: FluentTheme.of(context).typography.body,
                          children: [
                            TextSpan(
                              text: 'Resend OTP',
                              style: TextStyle(
                                color: FluentTheme.of(context).accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  bool res = await context
                                      .read<AuthProvider>()
                                      .sendOtp(phoneNumber);
                                  if (res) {
                                    displayInfoBarCustom(
                                        context,
                                        'Success!',
                                        'OTP sent successfully.',
                                        InfoBarSeverity.success);
                                  } else {
                                    displayInfoBarCustom(
                                        context,
                                        'Error!',
                                        'Error sending OTP. Please try again.',
                                        InfoBarSeverity.error);
                                  }
                                },
                            )
                          ],
                        ),
                      );
                    case ConnectionState.active:
                      return RichText(
                        text: TextSpan(
                          text: 'Didn\'t receive the OTP?\n\n',
                          style: FluentTheme.of(context).typography.body,
                          children: [
                            TextSpan(
                              text:
                                  'Resend OTP in ${60 - snapshot.data!} seconds',
                              style: TextStyle(
                                color: FluentTheme.of(context).accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      );
                    default:
                      return const Text('default');
                  }
                },
              ),
              Container(
                height: 50,
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      print('OTP: ${_otpController.text}');
                      print('Phone: $phoneNumber');
                      bool res = await context
                          .read<AuthProvider>()
                          .verifyOtp(_otpController.text, phoneNumber);

                      if (res) {
                        displayInfoBarCustom(
                            context,
                            'Success!',
                            'OTP verified successfully.',
                            InfoBarSeverity.success);
                        context.go('/');
                      } else {
                        displayInfoBarCustom(
                            context,
                            'Error!',
                            'Invalid OTP. Please try again.',
                            InfoBarSeverity.error);
                      }
                    }
                  },
                  child: Text('Verify OTP'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
