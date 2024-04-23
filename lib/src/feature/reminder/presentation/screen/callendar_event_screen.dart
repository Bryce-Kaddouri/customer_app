import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:customer_app/src/core/helper/date_helper.dart';
import 'package:customer_app/src/feature/reminder/presentation/screen/reminder_screen.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class EventRemindersPage extends StatefulWidget {
  const EventRemindersPage({super.key});

  @override
  _EventRemindersPageState createState() => _EventRemindersPageState();
}

class _EventRemindersPageState extends State<EventRemindersPage> {
  List<Reminder> _reminders = [];
  final _formKey = GlobalKey<FormState>();
  final _minutesController = TextEditingController();

  @override
  void dispose() {
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
      ),
      body: Column(
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minutesController,
                      validator: (value) {
                        if (value == null || value.isEmpty || int.tryParse(value) == null) {
                          return 'Please enter a reminder time in minutes';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(labelText: 'Minutes before start'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _reminders.add(Reminder(minutes: int.parse(_minutesController.text)));
                          _minutesController.clear();
                        });
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${_reminders[index].minutes} minutes'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _reminders.removeWhere((a) => a.minutes == _reminders[index].minutes);
                      });
                    },
                    child: const Text('Delete'),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, _reminders);
            },
            child: const Text('Done'),
          )
        ],
      ),
    );
  }
}

late DeviceCalendarPlugin _deviceCalendarPlugin;

class EventAttendeePage extends StatefulWidget {
  final Attendee? attendee;
  final String? eventId;
  const EventAttendeePage({Key? key, this.attendee, this.eventId}) : super(key: key);

  @override
  _EventAttendeePageState createState() => _EventAttendeePageState(attendee, eventId);
}

class _EventAttendeePageState extends State<EventAttendeePage> {
  Attendee? _attendee;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailAddressController = TextEditingController();
  var _role = AttendeeRole.None;
  var _status = AndroidAttendanceStatus.None;
  String _eventId = '';

  _EventAttendeePageState(Attendee? attendee, eventId) {
    if (attendee != null) {
      _attendee = attendee;
      _nameController.text = _attendee!.name!;
      _emailAddressController.text = _attendee!.emailAddress!;
      _role = _attendee!.role!;
      _status = _attendee!.androidAttendeeDetails?.attendanceStatus ?? AndroidAttendanceStatus.None;
    }
    _eventId = eventId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_attendee != null ? 'Edit attendee ${_attendee!.name}' : 'Add an Attendee'),
      ),
      body: Column(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: _nameController,
                    validator: (value) {
                      if (_attendee?.isCurrentUser == false && (value == null || value.isEmpty)) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: _emailAddressController,
                    validator: (value) {
                      if (value == null || value.isEmpty || !value.contains('@')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(labelText: 'Email Address'),
                  ),
                ),
                ListTile(
                  leading: const Text('Role'),
                  trailing: DropdownButton<AttendeeRole>(
                    onChanged: (value) {
                      setState(() {
                        _role = value as AttendeeRole;
                      });
                    },
                    value: _role,
                    items: AttendeeRole.values
                        .map((role) => DropdownMenuItem(
                              value: role,
                              child: Text(role.enumToString),
                            ))
                        .toList(),
                  ),
                ),
                Visibility(
                  visible: Platform.isIOS,
                  child: ListTile(
                    onTap: () async {
                      _deviceCalendarPlugin = DeviceCalendarPlugin();

                      var result = await _deviceCalendarPlugin.showiOSEventModal(_eventId);
                      Navigator.popUntil(context, ModalRoute.withName('/'));
                      //TODO: finish calling and getting attendee details from iOS
                    },
                    leading: const Icon(Icons.edit),
                    title: const Text('View / edit iOS attendance details'),
                  ),
                ),
                Visibility(
                  visible: Platform.isAndroid,
                  child: ListTile(
                    leading: const Text('Android attendee status'),
                    trailing: DropdownButton<AndroidAttendanceStatus>(
                      onChanged: (value) {
                        setState(() {
                          _status = value as AndroidAttendanceStatus;
                        });
                      },
                      value: _status,
                      items: AndroidAttendanceStatus.values
                          .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status.enumToString),
                              ))
                          .toList(),
                    ),
                  ),
                )
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  _attendee = Attendee(name: _nameController.text, emailAddress: _emailAddressController.text, role: _role, isOrganiser: _attendee?.isOrganiser ?? false, isCurrentUser: _attendee?.isCurrentUser ?? false, iosAttendeeDetails: _attendee?.iosAttendeeDetails, androidAttendeeDetails: AndroidAttendeeDetails.fromJson({'attendanceStatus': _status.index}));

                  _emailAddressController.clear();
                });

                Navigator.pop(context, _attendee);
              }
            },
            child: Text(_attendee != null ? 'Update' : 'Add'),
          )
        ],
      ),
    );
  }
}

class InputDropdown extends StatelessWidget {
  const InputDropdown({Key? key, this.child, this.labelText, this.valueText, this.valueStyle, this.onPressed}) : super(key: key);

  final String? labelText;
  final String? valueText;
  final TextStyle? valueStyle;
  final VoidCallback? onPressed;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
        ),
        baseStyle: valueStyle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (valueText != null) Text(valueText!, style: valueStyle),
            Icon(Icons.arrow_drop_down, color: Theme.of(context).brightness == Brightness.light ? Colors.grey.shade700 : Colors.white70),
          ],
        ),
      ),
    );
  }
}

class DateTimePicker extends StatelessWidget {
  const DateTimePicker({Key? key, this.labelText, this.selectedDate, this.selectedTime, this.selectDate, this.selectTime, this.enableTime = true}) : super(key: key);

  final String? labelText;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final ValueChanged<DateTime>? selectDate;
  final ValueChanged<TimeOfDay>? selectTime;
  final bool enableTime;

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(context: context, initialDate: selectedDate != null ? DateTime.parse(selectedDate.toString()) : DateTime.now(), firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate && selectDate != null) {
      selectDate!(picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    if (selectedTime == null) return;
    final picked = await showTimePicker(context: context, initialTime: selectedTime!);
    if (picked != null && picked != selectedTime) selectTime!(picked);
  }

  @override
  Widget build(BuildContext context) {
    final valueStyle = Theme.of(context).textTheme.headline6;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 4,
          child: InputDropdown(
            labelText: labelText,
            valueText: selectedDate == null ? '' : DateFormat.yMMMd().format(selectedDate as DateTime),
            valueStyle: valueStyle,
            onPressed: () {
              _selectDate(context);
            },
          ),
        ),
        if (enableTime) ...[
          const SizedBox(width: 12.0),
          Expanded(
            flex: 3,
            child: InputDropdown(
              valueText: selectedTime?.format(context) ?? '',
              valueStyle: valueStyle,
              onPressed: () {
                _selectTime(context);
              },
            ),
          ),
        ]
      ],
    );
  }
}

enum RecurrenceRuleEndType { Indefinite, MaxOccurrences, SpecifiedEndDate }

class CalendarEventPage extends StatefulWidget {
  final Map<String, dynamic>? extra;
  final Event? event;
  final Widget? recurringEventDialog;
  final bool isAdd;

  const CalendarEventPage({super.key, this.event, this.recurringEventDialog, this.isAdd = true, this.extra});

  State<CalendarEventPage> createState() => _CalendarEventPageState();
}

class _CalendarEventPageState extends State<CalendarEventPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Calendar? _calendar;

  bool _isLoading = false;

  Event? _event;
  late DeviceCalendarPlugin _deviceCalendarPlugin;
  RecurringEventDialog? _recurringEventDialog;

  TZDateTime? _startDate;
  TimeOfDay? _startTime;

  TZDateTime? _endDate;
  TimeOfDay? _endTime;

  AutovalidateMode _autovalidate = AutovalidateMode.disabled;
  DayOfWeekGroup? _dayOfWeekGroup = DayOfWeekGroup.None;

  bool _isRecurringEvent = false;
  bool _isByDayOfMonth = false;
  RecurrenceRuleEndType? _recurrenceRuleEndType;
  int? _totalOccurrences;
  int? _interval;
  late DateTime _recurrenceEndDate;
  RecurrenceFrequency? _recurrenceFrequency = RecurrenceFrequency.Daily;
  List<DayOfWeek> _daysOfWeek = [];
  int? _dayOfMonth;
  final List<int> _validDaysOfMonth = [];
  MonthOfYear? _monthOfYear;
  WeekNumber? _weekOfMonth;
  DayOfWeek? _selectedDayOfWeek = DayOfWeek.Monday;
  Availability _availability = Availability.Busy;
  EventStatus? _eventStatus;

  List<Attendee> _attendees = [];
  List<Reminder> _reminders = [];
  String _timezone = 'Etc/UTC';

  void getCurentLocation() async {
    try {
      _timezone = await FlutterTimezone.getLocalTimezone();
    } catch (e) {
      print('Could not get the local timezone');
    }

    _deviceCalendarPlugin = DeviceCalendarPlugin();

    _attendees = <Attendee>[];
    _reminders = <Reminder>[];
    _recurrenceRuleEndType = RecurrenceRuleEndType.Indefinite;

    if (_event == null) {
      print('calendar_event _timezone ------------------------- $_timezone');
      var currentLocation = timeZoneDatabase.locations[_timezone];
      List<Reminder> lstReminders = [];

      if (currentLocation != null) {
        if (widget.extra == null) {
          _startDate = TZDateTime.now(currentLocation);
          _endDate = TZDateTime.now(currentLocation).add(const Duration(hours: 1));
        } else {
          DateTime? startDate = DateTime.parse(widget.extra!['order_date']);
          List<String> time = widget.extra!['order_time'].split(':');
          TimeOfDay orderTime = TimeOfDay(hour: int.parse(time[0]), minute: int.parse(time[1]));
          startDate = startDate.copyWith(hour: orderTime.hour, minute: orderTime.minute);
          _startDate = TZDateTime.from(startDate, currentLocation);
          _endDate = _startDate!;

          DateTime firstReminer = _startDate!.subtract(const Duration(days: 1));
          int minutesFirst = firstReminer.difference(_startDate!.toLocal()).inMinutes;
          if (minutesFirst < 0) {
            minutesFirst = minutesFirst * -1;
          }
          print('minutesFirst: $minutesFirst');
          lstReminders.add(Reminder(minutes: minutesFirst));

          if (startDate.isBefore(startDate.copyWith(hour: 8, minute: 0, second: 0, millisecond: 0, microsecond: 0))) {
            DateTime secondDate = startDate.subtract(const Duration(hours: 2));
            int minutesSecond = secondDate.difference(_startDate!.toLocal()).inMinutes;
            if (minutesSecond < 0) {
              minutesSecond = minutesSecond * -1;
            }
            print('minutesSecond: $minutesSecond');
            lstReminders.add(Reminder(minutes: minutesSecond));
          } else {
            DateTime secondDate = startDate.subtract(const Duration(hours: 1));
            int minutesSecond = secondDate.difference(_startDate!.toLocal()).inMinutes;
            if (minutesSecond < 0) {
              minutesSecond = minutesSecond * -1;
            }
            print('minutesSecond: $minutesSecond');
            lstReminders.add(Reminder(minutes: minutesSecond));
          }
        }
      } else {
        var fallbackLocation = timeZoneDatabase.locations['Etc/UTC'];
        _startDate = TZDateTime.now(fallbackLocation!);
        _endDate = TZDateTime.now(fallbackLocation).add(const Duration(hours: 1));
      }

      _event = Event(_calendar!.id, start: _startDate, end: _endDate, title: 'Customer App - Collect order', reminders: lstReminders);

      _recurrenceEndDate = _endDate as DateTime;
      _dayOfMonth = 1;
      _monthOfYear = MonthOfYear.January;
      _weekOfMonth = WeekNumber.First;
      _availability = Availability.Busy;
      _eventStatus = EventStatus.None;
    } else {
      _startDate = _event!.start!;
      _endDate = _event!.end!;
      _isRecurringEvent = _event!.recurrenceRule != null;

      if (_event!.attendees!.isNotEmpty) {
        _attendees.addAll(_event!.attendees! as Iterable<Attendee>);
      }

      if (_event!.reminders!.isNotEmpty) {
        _reminders.addAll(_event!.reminders!);
      }

      if (_isRecurringEvent) {
        _interval = _event!.recurrenceRule!.interval!;
        _totalOccurrences = _event!.recurrenceRule!.totalOccurrences;
        _recurrenceFrequency = _event!.recurrenceRule!.recurrenceFrequency;

        if (_totalOccurrences != null) {
          _recurrenceRuleEndType = RecurrenceRuleEndType.MaxOccurrences;
        }

        if (_event!.recurrenceRule!.endDate != null) {
          _recurrenceRuleEndType = RecurrenceRuleEndType.SpecifiedEndDate;
          _recurrenceEndDate = _event!.recurrenceRule!.endDate!;
        }

        _isByDayOfMonth = _event?.recurrenceRule?.weekOfMonth == null;
        _daysOfWeek = _event?.recurrenceRule?.daysOfWeek ?? <DayOfWeek>[];
        _monthOfYear = _event?.recurrenceRule?.monthOfYear ?? MonthOfYear.January;
        _weekOfMonth = _event?.recurrenceRule?.weekOfMonth ?? WeekNumber.First;
        _selectedDayOfWeek = _daysOfWeek.isNotEmpty ? _daysOfWeek.first : DayOfWeek.Monday;
        _dayOfMonth = _event?.recurrenceRule?.dayOfMonth ?? 1;

        if (_daysOfWeek.isNotEmpty) {
          _updateDaysOfWeekGroup();
        }
      }

      _availability = _event!.availability;
      _eventStatus = _event!.status;
    }

    _startTime = TimeOfDay(hour: _startDate!.hour, minute: _startDate!.minute);
    _endTime = TimeOfDay(hour: _endDate!.hour, minute: _endDate!.minute);

    // Getting days of the current month (or a selected month for the yearly recurrence) as a default
    _getValidDaysOfMonth(_recurrenceFrequency);
    setState(() {});
  }

  void printAttendeeDetails(Attendee attendee) {
    print('attendee name: ${attendee.name}, email address: ${attendee.emailAddress}, type: ${attendee.role?.enumToString}');
    print('ios specifics - status: ${attendee.iosAttendeeDetails?.attendanceStatus}, type: ${attendee.iosAttendeeDetails?.attendanceStatus?.enumToString}');
    print('android specifics - status ${attendee.androidAttendeeDetails?.attendanceStatus}, type: ${attendee.androidAttendeeDetails?.attendanceStatus?.enumToString}');
  }

  void initCalendar() async {
    setState(() {
      _isLoading = false;
    });
    Calendar? cal = await ReminderScreen.retrieveCalendar(context);
    if (cal != null) {
      setState(() {
        _calendar = cal;
        if (widget.event != null) {
          _event = widget.event;
        }
        _isLoading = false;
      });
      getCurentLocation();
    }
  }

  @override
  void initState() {
    super.initState();
    initCalendar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fluent.FluentTheme.of(context).navigationPaneTheme.backgroundColor,
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 2,
        shadowColor: fluent.FluentTheme.of(context).shadowColor,
        surfaceTintColor: fluent.FluentTheme.of(context).navigationPaneTheme.overlayBackgroundColor,
        backgroundColor: fluent.FluentTheme.of(context).navigationPaneTheme.overlayBackgroundColor,
        centerTitle: true,
        leading: BackButton(
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(_event?.eventId?.isEmpty ?? true
            ? 'Create event'
            : _calendar!.isReadOnly == true
                ? 'View event ${_event?.title}'
                : 'Edit event ${_event?.title}'),
      ),
      body: SafeArea(
        child: _isLoading || _calendar == null
            ? const Center(child: fluent.ProgressRing())
            : SingleChildScrollView(
                child: AbsorbPointer(
                  absorbing: _calendar!.isReadOnly ?? false,
                  child: Column(
                    children: [
                      Form(
                        autovalidateMode: _autovalidate,
                        key: _formKey,
                        child: Column(
                          children: [
                            Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: fluent.InfoLabel(
                                  label: 'Title:',
                                  child: fluent.TextFormBox(
                                    key: const Key('titleField'),
                                    initialValue: _event?.title,
                                    validator: _validateTitle,
                                    onSaved: (String? value) {
                                      _event?.title = value;
                                    },
                                  ),
                                )),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: fluent.InfoLabel(
                                label: 'Description:',
                                child: fluent.TextFormBox(
                                  key: const Key('descriptionField'),
                                  initialValue: _event?.description,
                                  onSaved: (String? value) {
                                    _event?.description = value;
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: fluent.InfoLabel(
                                label: 'Location:',
                                child: fluent.TextFormBox(
                                  key: const Key('locationField'),
                                  initialValue: _event?.location,
                                  onSaved: (String? value) {
                                    _event?.location = value;
                                  },
                                ),
                              ),
                            ),

                            if (_startDate != null)
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: fluent.InfoLabel(
                                  label: 'From:',
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: fluent.DatePicker(
                                          key: const Key('fromDatePicker'),
                                          selected: _startDate!.toLocal(),
                                          fieldFlex: const [2, 3, 2],
                                          onChanged: (DateTime date) {
                                            setState(() {
                                              var currentLocation = timeZoneDatabase.locations[_timezone];
                                              if (currentLocation != null) {
                                                _startDate = TZDateTime.from(date, currentLocation);
                                                _event?.start = _combineDateWithTime(_startDate, _startTime);
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        flex: 1,
                                        child: fluent.TimePicker(
                                          hourFormat: HourFormat.HH,
                                          key: const Key('fromTimePicker'),
                                          selected: _startDate!.copyWith(hour: _startTime!.hour, minute: _startTime!.minute).toLocal(),
                                          onChanged: (DateTime time) {
                                            setState(() {
                                              _startTime = TimeOfDay(hour: time.hour, minute: time.minute);
                                              _event?.start = _combineDateWithTime(_startDate, _startTime);
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if ((_event?.allDay == false) && Platform.isAndroid)
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: fluent.InfoLabel(
                                  label: 'Start date time zone:',
                                  child: fluent.TextFormBox(
                                    key: const Key('startDateTimeZoneField'),
                                    initialValue: _event?.start?.location.name,
                                    onSaved: (String? value) {
                                      _event?.updateStartLocation(value);
                                    },
                                  ),
                                ),
                              ),
                            // Only add the 'To' Date for non-allDay events on all
                            // platforms except Android (which allows multiple-day allDay events)
                            if (_event?.allDay == false || Platform.isAndroid)
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: fluent.InfoLabel(
                                  label: 'To:',
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: fluent.DatePicker(
                                          key: const Key('toDatePicker'),
                                          selected: _endDate!.toLocal(),
                                          fieldFlex: const [2, 3, 2],
                                          onChanged: (DateTime date) {
                                            setState(() {
                                              var currentLocation = timeZoneDatabase.locations[_timezone];
                                              if (currentLocation != null) {
                                                _endDate = TZDateTime.from(date, currentLocation);
                                                _event?.end = _combineDateWithTime(_endDate, _endTime);
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        flex: 1,
                                        child: fluent.TimePicker(
                                          hourFormat: HourFormat.HH,
                                          key: const Key('toTimePicker'),
                                          selected: _endDate!.copyWith(hour: _endTime!.hour, minute: _endTime!.minute).toLocal(),
                                          onChanged: (DateTime time) {
                                            setState(() {
                                              _endTime = TimeOfDay(hour: time.hour, minute: time.minute);
                                              _event?.end = _combineDateWithTime(_endDate, _endTime);
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (_event?.allDay == false && Platform.isAndroid)
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: fluent.InfoLabel(
                                  label: 'End date time zone:',
                                  child: fluent.TextFormBox(
                                    key: const Key('endDateTimeZoneField'),
                                    initialValue: _event?.end?.location.name,
                                    onSaved: (String? value) => _event?.updateEndLocation(value),
                                  ),
                                ),
                              ),

                            GestureDetector(
                              onTap: () async {
                                var result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EventRemindersPage()));
                                if (result == null) {
                                  return;
                                }
                                _reminders = result;
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 10.0,
                                    children: [const Icon(Icons.alarm), if (_reminders.isEmpty) Text(_calendar!.isReadOnly == false ? 'Add reminders' : 'Reminders'), for (var reminder in _reminders) Text('${reminder.minutes} minutes before; ')],
                                  ),
                                ),
                              ),
                            ),

                            if (_event != null && _event!.reminders != null && _event!.reminders!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: fluent.Column(
                                  children: [
                                    fluent.Text('Reminders'),
                                    fluent.ListView.builder(
                                      padding: const EdgeInsets.only(top: 10, bottom: 80),
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: _event!.reminders!.length,
                                      itemBuilder: (context, index) {
                                        DateTime reminderTime = _event!.start!.subtract(Duration(minutes: _event!.reminders![index].minutes!));
                                        return fluent.Card(
                                          padding: const EdgeInsets.all(0),
                                          margin: const EdgeInsets.only(bottom: 10),
                                          child: fluent.ListTile(
                                            title: Text(DateHelper.getFormattedDateTime(reminderTime)),
                                            trailing: fluent.IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () {
                                                setState(() {
                                                  _event!.reminders!.removeAt(index);
                                                });
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (_calendar!.isReadOnly == false && (_event?.eventId?.isNotEmpty ?? false)) ...[
                        ElevatedButton(
                          key: const Key('deleteEventButton'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () async {
                            bool? result = true;
                            if (!_isRecurringEvent) {
                              await _deviceCalendarPlugin.deleteEvent(_calendar!.id, _event?.eventId);
                            } else {
                              result = await showDialog<bool>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return _recurringEventDialog != null ? _recurringEventDialog as Widget : const SizedBox();
                                  });
                            }

                            if (result == true) {
                              Navigator.pop(context, true);
                            }
                          },
                          child: const Text('Delete'),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
      ),
      /*floatingActionButton: Visibility(
        visible: _calendar?.isReadOnly == false,
        child: FloatingActionButton(
          key: const Key('saveEventButton'),
          onPressed: () async {
            final form = _formKey.currentState;
            if (form?.validate() == false) {
              _autovalidate = AutovalidateMode.always; // Start validating on every change.
              */ /*showInSnackBar('Please fix the errors in red before submitting.');*/ /*
              showDialog(context: context, builder: (BuildContext context) => AlertDialog(title: const Text('Error'), content: const Text('Please fix the errors in red before submitting.'), actions: <Widget>[TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]));
            } else {
              form?.save();
              if (_isRecurringEvent) {
                if (!_isByDayOfMonth && (_recurrenceFrequency == RecurrenceFrequency.Monthly || _recurrenceFrequency == RecurrenceFrequency.Yearly)) {
                  // Setting day of the week parameters for WeekNumber to avoid clashing with the weekly recurrence values
                  _daysOfWeek.clear();
                  if (_selectedDayOfWeek != null) {
                    _daysOfWeek.add(_selectedDayOfWeek as DayOfWeek);
                  }
                } else {
                  _weekOfMonth = null;
                }

                _event?.recurrenceRule = RecurrenceRule(_recurrenceFrequency, interval: _interval, totalOccurrences: (_recurrenceRuleEndType == RecurrenceRuleEndType.MaxOccurrences) ? _totalOccurrences : null, endDate: _recurrenceRuleEndType == RecurrenceRuleEndType.SpecifiedEndDate ? _recurrenceEndDate : null, daysOfWeek: _daysOfWeek, dayOfMonth: _dayOfMonth, monthOfYear: _monthOfYear, weekOfMonth: _weekOfMonth);
              }
              _event?.attendees = _attendees;
              _event?.reminders = _reminders;
              _event?.availability = _availability;
              _event?.status = _eventStatus;
              var createEventResult = await _deviceCalendarPlugin.createOrUpdateEvent(_event);
              if (createEventResult?.isSuccess == true) {
                Navigator.pop(context, true);
              } else {
                showDialog(context: context, builder: (BuildContext context) => AlertDialog(title: const Text('Error'), content: Text(createEventResult?.errors.map((err) => '[${err.errorCode}] ${err.errorMessage}').join(' | ') as String), actions: <Widget>[TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]));
                */ /*showInSnackBar(createEventResult?.errors.map((err) => '[${err.errorCode}] ${err.errorMessage}').join(' | ') as String);*/ /*
              }
            }
          },
          child: const Icon(Icons.check),
        ),
      ),*/
      persistentFooterButtons: [
        if (_calendar!.isReadOnly == false)
          Container(
            height: 40,
            width: double.infinity,
            child: fluent.FilledButton(
              key: const Key('saveEventButton'),
              onPressed: () async {
                final form = _formKey.currentState;
                if (form?.validate() == false) {
                  _autovalidate = AutovalidateMode.always; // Start validating on every change.
                  /*showInSnackBar('Please fix the errors in red before submitting.');*/
                  showDialog(context: context, builder: (BuildContext context) => AlertDialog(title: const Text('Error'), content: const Text('Please fix the errors in red before submitting.'), actions: <Widget>[TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]));
                } else {
                  form?.save();
                  if (_isRecurringEvent) {
                    if (!_isByDayOfMonth && (_recurrenceFrequency == RecurrenceFrequency.Monthly || _recurrenceFrequency == RecurrenceFrequency.Yearly)) {
                      // Setting day of the week parameters for WeekNumber to avoid clashing with the weekly recurrence values
                      _daysOfWeek.clear();
                      if (_selectedDayOfWeek != null) {
                        _daysOfWeek.add(_selectedDayOfWeek as DayOfWeek);
                      }
                    } else {
                      _weekOfMonth = null;
                    }

                    _event?.recurrenceRule = RecurrenceRule(_recurrenceFrequency, interval: _interval, totalOccurrences: (_recurrenceRuleEndType == RecurrenceRuleEndType.MaxOccurrences) ? _totalOccurrences : null, endDate: _recurrenceRuleEndType == RecurrenceRuleEndType.SpecifiedEndDate ? _recurrenceEndDate : null, daysOfWeek: _daysOfWeek, dayOfMonth: _dayOfMonth, monthOfYear: _monthOfYear, weekOfMonth: _weekOfMonth);
                  }
                  _event?.attendees = _attendees;
                  _event?.reminders = _reminders;
                  _event?.availability = _availability;
                  _event?.status = _eventStatus;
                  var createEventResult = await _deviceCalendarPlugin.createOrUpdateEvent(_event);
                  if (createEventResult?.isSuccess == true) {
                    if (context.canPop()) {
                      fluent.displayInfoBar(
                        context,
                        builder: (BuildContext context, void Function() close) {
                          return fluent.InfoBar(
                            title: Text('Success'),
                            content: Text('Event saved successfully'),
                            action: fluent.IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: close,
                            ),
                            severity: fluent.InfoBarSeverity.success,
                          );
                        },
                        alignment: Alignment.topRight,
                      );
                      context.pop(true);
                    } else {
                      fluent.displayInfoBar(
                        context,
                        builder: (BuildContext context, void Function() close) {
                          return fluent.InfoBar(
                            title: Text('Success'),
                            content: Text('Event saved successfully'),
                            action: fluent.IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: close,
                            ),
                            severity: fluent.InfoBarSeverity.success,
                          );
                        },
                        alignment: Alignment.topRight,
                      );
                      context.go('/reminder');
                    }
                  } else {
                    showDialog(context: context, builder: (BuildContext context) => AlertDialog(title: const Text('Error'), content: Text(createEventResult?.errors.map((err) => '[${err.errorCode}] ${err.errorMessage}').join(' | ') as String), actions: <Widget>[TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]));
                    /*showInSnackBar(createEventResult?.errors.map((err) => '[${err.errorCode}] ${err.errorMessage}').join(' | ') as String);*/
                  }
                }
              },
              child: const Text('Save'),
            ),
          ),
      ],
    );
  }

  Text _recurrenceFrequencyToText(RecurrenceFrequency? recurrenceFrequency) {
    switch (recurrenceFrequency) {
      case RecurrenceFrequency.Daily:
        return const Text('Daily');
      case RecurrenceFrequency.Weekly:
        return const Text('Weekly');
      case RecurrenceFrequency.Monthly:
        return const Text('Monthly');
      case RecurrenceFrequency.Yearly:
        return const Text('Yearly');
      default:
        return const Text('');
    }
  }

  Text _recurrenceFrequencyToIntervalText(RecurrenceFrequency? recurrenceFrequency) {
    switch (recurrenceFrequency) {
      case RecurrenceFrequency.Daily:
        return const Text(' Day(s)');
      case RecurrenceFrequency.Weekly:
        return const Text(' Week(s) on');
      case RecurrenceFrequency.Monthly:
        return const Text(' Month(s)');
      case RecurrenceFrequency.Yearly:
        return const Text(' Year(s)');
      default:
        return const Text('');
    }
  }

  Text _recurrenceRuleEndTypeToText(RecurrenceRuleEndType endType) {
    switch (endType) {
      case RecurrenceRuleEndType.Indefinite:
        return const Text('Indefinitely');
      case RecurrenceRuleEndType.MaxOccurrences:
        return const Text('After a set number of times');
      case RecurrenceRuleEndType.SpecifiedEndDate:
        return const Text('Continues until a specified date');
      default:
        return const Text('');
    }
  }

  // Get total days of a month
  void _getValidDaysOfMonth(RecurrenceFrequency? frequency) {
    _validDaysOfMonth.clear();
    var totalDays = 0;

    // Year frequency: Get total days of the selected month
    if (frequency == RecurrenceFrequency.Yearly) {
      totalDays = DateTime(DateTime.now().year, _monthOfYear?.value != null ? _monthOfYear!.value + 1 : 1, 0).day;
    } else {
      // Otherwise, get total days of the current month
      var now = DateTime.now();
      totalDays = DateTime(now.year, now.month + 1, 0).day;
    }

    for (var i = 1; i <= totalDays; i++) {
      _validDaysOfMonth.add(i);
    }
  }

  void _updateDaysOfWeek() {
    if (_dayOfWeekGroup == null) return;
    var days = _dayOfWeekGroup!.getDays;

    switch (_dayOfWeekGroup) {
      case DayOfWeekGroup.Weekday:
      case DayOfWeekGroup.Weekend:
      case DayOfWeekGroup.AllDays:
        _daysOfWeek.clear();
        _daysOfWeek.addAll(days.where((a) => _daysOfWeek.every((b) => a != b)));
        break;
      case DayOfWeekGroup.None:
        _daysOfWeek.clear();
        break;
      default:
        _daysOfWeek.clear();
    }
  }

  void _updateDaysOfWeekGroup({DayOfWeek? selectedDay}) {
    var deepEquality = const DeepCollectionEquality.unordered().equals;

    // If _daysOfWeek contains nothing
    if (_daysOfWeek.isEmpty && _dayOfWeekGroup != DayOfWeekGroup.None) {
      _dayOfWeekGroup = DayOfWeekGroup.None;
    }
    // If _daysOfWeek contains Monday to Friday
    else if (deepEquality(_daysOfWeek, DayOfWeekGroup.Weekday.getDays) && _dayOfWeekGroup != DayOfWeekGroup.Weekday) {
      _dayOfWeekGroup = DayOfWeekGroup.Weekday;
    }
    // If _daysOfWeek contains Saturday and Sunday
    else if (deepEquality(_daysOfWeek, DayOfWeekGroup.Weekend.getDays) && _dayOfWeekGroup != DayOfWeekGroup.Weekend) {
      _dayOfWeekGroup = DayOfWeekGroup.Weekend;
    }
    // If _daysOfWeek contains all days
    else if (deepEquality(_daysOfWeek, DayOfWeekGroup.AllDays.getDays) && _dayOfWeekGroup != DayOfWeekGroup.AllDays) {
      _dayOfWeekGroup = DayOfWeekGroup.AllDays;
    }
    // Otherwise null
    else {
      _dayOfWeekGroup = null;
    }
  }

  String? _validateTotalOccurrences(String? value) {
    if (value == null) return null;
    if (value.isNotEmpty && int.tryParse(value) == null) {
      return 'Total occurrences needs to be a valid number';
    }
    return null;
  }

  String? _validateInterval(String? value) {
    if (value == null) return null;
    if (value.isNotEmpty && int.tryParse(value) == null) {
      return 'Interval needs to be a valid number';
    }
    return null;
  }

  String? _validateTitle(String? value) {
    if (value == null) return null;
    if (value.isEmpty) {
      return 'Name is required.';
    }

    return null;
  }

  TZDateTime? _combineDateWithTime(TZDateTime? date, TimeOfDay? time) {
    if (date == null) return null;
    var currentLocation = timeZoneDatabase.locations[_timezone];

    final dateWithoutTime = TZDateTime.from(DateTime.parse(DateFormat('y-MM-dd 00:00:00').format(date)), currentLocation!);

    if (time == null) return dateWithoutTime;
    if (Platform.isAndroid && _event?.allDay == true) return dateWithoutTime;

    return dateWithoutTime.add(Duration(hours: time.hour, minutes: time.minute));
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}
