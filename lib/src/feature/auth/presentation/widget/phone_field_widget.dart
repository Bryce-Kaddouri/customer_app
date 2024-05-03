import 'package:country_calling_code_picker/country.dart';
import 'package:country_calling_code_picker/country_code_picker.dart';
import 'package:country_calling_code_picker/functions.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' hide IconButton;
import 'package:phonenumbers/phonenumbers.dart' as phone;

class PhoneFieldView extends StatefulWidget {
  final phone.PhoneNumberEditingController controller;
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
}

class _PhoneFieldViewState extends State<PhoneFieldView> {
  bool isFocused = false;
  Country? _selectedCountry;
  void initCountry() async {
    final country = await getCountryByCountryCode(context, 'IE');
    setState(() {
      _selectedCountry = country;
      widget.controller.value = phone.PhoneNumber(
        phone.Country(country!.name, country!.countryCode, int.parse(country!.callingCode), phone.LengthRule.exact(9)),
        '',
      );
    });
  }

  void _showCountryPicker() async {
    Country? countrySelect = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PickerPage(),
      ),
    );
    if (countrySelect != null) {
      setState(() {
        _selectedCountry = countrySelect;
        widget.controller.value = phone.PhoneNumber(
          phone.Country(countrySelect.name, countrySelect.countryCode, int.parse(countrySelect.callingCode), phone.LengthRule.exact(9)),
          widget.controller.value!.nationalNumber,
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initCountry();

    widget.controller.nationalNumberController.addListener(() {
      widget.controller.value;
      if (widget.controller.nationalNumberController.text.length > 9) {
        widget.controller.nationalNumberController.text = widget.controller.nationalNumberController.text.substring(0, 9);
      }
    });

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
      child: /*PhoneFormField(
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
        */ /*decoration: material.InputDecoration(
              border: material.InputBorder.none,
              hintText: 'Phone Number',
              filled: true,
              fillColor: Colors.transparent,
            ),*/ /*
        autovalidateMode: AutovalidateMode.disabled,
        onChanged: (p) {
          if (p.nsn.length > 9) {
            PhoneNumber phone =
                PhoneNumber(isoCode: p.isoCode, nsn: p.nsn.substring(0, 9));
            widget.controller.value = phone;
          }
        },
      ),*/
          Column(
        children: [
          SizedBox(height: 24),
          TextFormBox(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (p) {
              if (!widget.controller.value!.isValid) {
                print('valid');
                print(widget.controller.value);
                return 'Invalid phone number';
              }
              return null;
            },
            onChanged: (p) {
              setState(() {
                widget.controller.value = phone.PhoneNumber(
                  phone.Country(_selectedCountry!.name, _selectedCountry!.countryCode, int.parse(_selectedCountry!.callingCode), phone.LengthRule.exact(9)),
                  p.substring(0, 9),
                );
              });
            },
            controller: widget.controller.nationalNumberController,
            prefix: Container(
              padding: const EdgeInsets.all(8),
              child: InkWell(
                onTap: _showCountryPicker,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 32,
                      child: Center(
                        child: Image.asset(
                          _selectedCountry!.flag,
                          package: countryCodePackageName,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      _selectedCountry?.callingCode ?? '',
                      style: FluentTheme.of(context).typography.body,
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      FluentIcons.chevron_down,
                      size: 16,
                      color: FluentTheme.of(context).accentColor,
                    ),
                  ],
                ),
              ),
            ),
          ),

          /*PhoneNumberFormField(
            style: FluentTheme.of(context).typography.body,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: widget.controller,
            dialogTitle: 'Select your country',
            decoration: InputDecoration(
                border: OutlineInputBorder(
              borderSide: BorderSide(
                color: isFocused ? FluentTheme.of(context).accentColor : FluentTheme.of(context).inactiveColor,
              ),
            )),
          ),*/
        ],
      ),
    );
  }
}

class PickerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FluentTheme.of(context).navigationPaneTheme.backgroundColor,
      appBar: AppBar(
        leading: BackButton(
          color: FluentTheme.of(context).typography.subtitle!.color,
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 4,
        shadowColor: FluentTheme.of(context).shadowColor,
        surfaceTintColor: FluentTheme.of(context).navigationPaneTheme.backgroundColor,
        backgroundColor: FluentTheme.of(context).navigationPaneTheme.backgroundColor,
        centerTitle: true,
        title: Text('select country code', style: FluentTheme.of(context).typography.subtitle),
      ),
      body: Container(
        child: CountryPickerWidget(
          onSelected: (country) => Navigator.pop(context, country),
          itemTextStyle: FluentTheme.of(context).typography.body!,
          searchInputStyle: FluentTheme.of(context).typography.body!,
          searchHintText: 'Search country code',
          searchInputDecoration: InputDecoration(
            hintText: 'Search country code',
            hintStyle: FluentTheme.of(context).typography.body!,
            suffix: IconButton(
              icon: Icon(FluentIcons.clear),
              onPressed: () {
                // Clear the text field
              },
            ),
            contentPadding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
          ),
        ),
      ),
    );
  }
}
