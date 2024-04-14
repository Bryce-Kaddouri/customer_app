import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:phone_form_field/phone_form_field.dart';

class PhoneFieldView extends StatefulWidget {
  final PhoneController controller;
  final FocusNode focusNode;

  final bool isCountryButtonPersistent;
  final bool mobileOnly;
  final Locale locale;
  final bool isReadOnly;

  const PhoneFieldView({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isCountryButtonPersistent,
    required this.mobileOnly,
    required this.locale,
    this.isReadOnly = false,
  });

  @override
  State<PhoneFieldView> createState() => _PhoneFieldViewState();

  static bool validPhoneNumber(PhoneController phoneNumber) {
    bool isValid = true;
    if (phoneNumber.value.isValidLength() == false) {
      isValid = false;
    } else if (phoneNumber.value.isValid() == false) {
      isValid = false;
    }

    return isValid;
  }
}

class _PhoneFieldViewState extends State<PhoneFieldView> {
  bool isFocused = false;

  @override
  void initState() {
    super.initState();

    widget.focusNode.addListener(() {
      if (widget.focusNode.hasFocus) {
        setState(() {
          isFocused = true;
        });
      } else {
        setState(() {
          isFocused = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: PhoneFormField(
        validator: (p) {
          if (p!.nsn.length != 9) {
            return 'Invalid phone number';
          } else if (PhoneFieldView.validPhoneNumber(widget.controller) ==
              false) {
            return 'Invalid phone number';
          }
          return null;
        },
        countryButtonStyle: const CountryButtonStyle(
          showDialCode: true,
          showDropdownIcon: true,
          showIsoCode: false,
          showFlag: true,
        ),
        decoration: material.InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: material.UnderlineInputBorder(
            borderSide: BorderSide(
              color: isFocused
                  ? FluentTheme.of(context).accentColor
                  : FluentTheme.of(context).inactiveColor,
            ),
          ),
          hintText: 'Phone Number',
        ),
        enabled: !widget.isReadOnly,
        focusNode: widget.focusNode,
        controller: widget.controller,
        isCountryButtonPersistent: widget.isCountryButtonPersistent,
        autofocus: false,
        textAlignVertical: TextAlignVertical.center,
        autofillHints: const [AutofillHints.telephoneNumber],
        countrySelectorNavigator: CountrySelectorNavigator.page(
          searchBoxIconColor: FluentTheme.of(context).accentColor,
          noResultMessage: 'No result found',
        ),
        /*decoration: material.InputDecoration(
              border: material.InputBorder.none,
              hintText: 'Phone Number',
              filled: true,
              fillColor: Colors.transparent,
            ),*/
        autovalidateMode: AutovalidateMode.disabled,
        onChanged: (p) {
          if (p.nsn.length > 9) {
            PhoneNumber phone =
                PhoneNumber(isoCode: p.isoCode, nsn: p.nsn.substring(0, 9));
            widget.controller.value = phone;
          }
        },
      ),
    );
  }
}
