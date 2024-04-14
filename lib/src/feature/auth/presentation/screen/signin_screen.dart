import 'package:customer_app/src/feature/auth/presentation/widget/phone_field_widget.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:go_router/go_router.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:provider/provider.dart';

import '../../../../core/share_component/dismiss_keyboard.dart';
import '../provider/auth_provider.dart';

class SignInScreen extends StatelessWidget {
  SignInScreen({super.key});

  // global key for the form
  final _formKey = GlobalKey<FormState>();
  PhoneController phoneController = PhoneController();
  final FocusNode focusNode = FocusNode();

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
        title: Text('Sign In', style: FluentTheme.of(context).typography.title),
      ),
      body: DismissKeyboard(
        child: Container(
          padding: const EdgeInsets.all(20),
          alignment: Alignment.center,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  child: Column(children: [
                    InfoLabel(
                      label: 'phone number:',
                      child: PhoneFieldView(
                        controller: phoneController,
                        focusNode: focusNode,
                        isCountryButtonPersistent: true,
                        mobileOnly: true,
                        locale: Locale('IE'),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ]),
                ),
                Container(
                  height: 50,
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      // Validate and save the form values
                      if (_formKey.currentState!.validate()) {
                        /*debugPrint(_formKey.currentState?.value.toString());*/
                        String phone =
                            '+${phoneController.value.countryCode}${phoneController.value.nsn}';
                        String phoneUri = Uri.encodeQueryComponent(phone);

                        context
                            .read<AuthProvider>()
                            .sendOtp(
                              phone,
                            )
                            .then((value) {
                          if (value) {
                            context.go('/otp/$phoneUri');
                          } else {
                            displayInfoBar(
                              context,
                              builder: (context, close) {
                                return InfoBar(
                                  title: const Text('Error!'),
                                  content: const Text(
                                      'Invalid email or password. Please try again.'),
                                  action: IconButton(
                                    icon: const Icon(FluentIcons.clear),
                                    onPressed: close,
                                  ),
                                  severity: InfoBarSeverity.error,
                                );
                              },
                              alignment: Alignment.topRight,
                              duration: const Duration(seconds: 5),
                            );
                          }
                        });
                      }
                    },
                    child: context.watch<AuthProvider>().isLoading
                        ? ProgressRing()
                        : const Text(
                            'Sign In',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
