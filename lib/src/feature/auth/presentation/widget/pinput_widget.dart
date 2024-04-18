import 'package:fluent_ui/fluent_ui.dart';
import 'package:pinput/pinput.dart';

class FilledRoundedPinPut extends StatefulWidget {
  final TextEditingController controller;

  const FilledRoundedPinPut({Key? key, required this.controller}) : super(key: key);

  @override
  _FilledRoundedPinPutState createState() => _FilledRoundedPinPutState();

  @override
  String toStringShort() => 'Rounded Filled';
}

class _FilledRoundedPinPutState extends State<FilledRoundedPinPut> {
  final focusNode = FocusNode();

  @override
  void dispose() {
    widget.controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  bool showError = false;

  @override
  Widget build(BuildContext context) {
    const length = 6;
    const borderColor = Color.fromRGBO(114, 178, 238, 1);
    const errorColor = Color.fromRGBO(255, 234, 238, 1);
    const fillColor = Color.fromRGBO(222, 231, 240, .57);
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: FluentTheme.of(context).typography.subtitle!.copyWith(
            fontSize: 22,
            color: const Color.fromRGBO(30, 60, 87, 1),
          ),
      decoration: BoxDecoration(color: fillColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.transparent)),
    );

    return SizedBox(
      height: 68,
      child: Pinput(
        listenForMultipleSmsOnAndroid: true,
        androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsRetrieverApi,
        onAppPrivateCommand: (str, map) {
          print(str);
          print(map);
        },
        onClipboardFound: (value) {
          if (value.length == 6 && int.tryParse(value) != null) {
            widget.controller.text = value;
          }
        },
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a valid OTP';
          } else if (value.length < length) {
            return 'Please enter a valid OTP';
          }
          return null;
        },
        length: length,
        controller: widget.controller,
        focusNode: focusNode,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: defaultPinTheme.copyWith(
          height: 68,
          width: 64,
          decoration: defaultPinTheme.decoration!.copyWith(
            border: Border.all(color: borderColor),
          ),
        ),
        errorPinTheme: defaultPinTheme.copyWith(
          decoration: BoxDecoration(
            color: errorColor,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
