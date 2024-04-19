import 'dart:io';

import 'package:device_calendar/device_calendar.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:flutter/services.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';

import 'callendar_event_screen.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  static Future<Calendar?> retrieveCalendar(BuildContext context) async {
    var deviceCalendarPlugin = DeviceCalendarPlugin();
    try {
      var permissionsGranted = await deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && (permissionsGranted.data == null || permissionsGranted.data == false)) {
        permissionsGranted = await deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || permissionsGranted.data == null || permissionsGranted.data == false) {
          showDialog(
            context: context,
            builder: (context) {
              return ContentDialog(
                title: Text('Permission Required'),
                content: Text('Please allow the app to access your calendar'),
                actions: [
                  Button(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  )
                ],
              );
            },
          );
        }
      }

      final calendarsResult = await deviceCalendarPlugin.retrieveCalendars();
      print('calendarsResult: ${calendarsResult.data}');

      List<Calendar> calendarsTemp = calendarsResult.data as List<Calendar>;

      bool calendarExist = false;
      Calendar calendarTemp = Calendar();
      for (var calendar in calendarsTemp) {
        if (calendar.name == "Customer Calendar App") {
          calendarExist = true;
          calendarTemp = calendar;
          break;
        }
      }

      if (calendarExist) {
        return calendarTemp;
      } else {
        // create calendar
        final createCalendarResult = await deviceCalendarPlugin.createCalendar("Customer Calendar App", calendarColor: Colors.yellow, localAccountName: "Customer Calendar App");
        if (createCalendarResult.isSuccess && createCalendarResult.data != null) {
          Calendar calendar = Calendar(
            id: createCalendarResult.data as String,
            name: "Customer Calendar App",
            isReadOnly: false,
            isDefault: false,
            color: Colors.yellow.value,
            accountName: "Customer Calendar App",
          );
          return calendar;
        }
      }
    } on PlatformException catch (e) {
      throw Exception(e);
      print(e);
    }
  }

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  late DeviceCalendarPlugin _deviceCalendarPlugin;
  Calendar? _calendar;
  List<Event> _calendarEvents = [];
  bool _isLoading = true;

  Future<bool> _retrieveCalendars() async {
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && (permissionsGranted.data == null || permissionsGranted.data == false)) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || permissionsGranted.data == null || permissionsGranted.data == false) {
          false;
        }
      }

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      print('calendarsResult: ${calendarsResult.data}');

      List<Calendar> calendarsTemp = calendarsResult.data as List<Calendar>;

      bool calendarExist = false;
      Calendar calendarTemp = Calendar();
      for (var calendar in calendarsTemp) {
        if (calendar.name == "Customer Calendar App") {
          calendarExist = true;
          calendarTemp = calendar;
          break;
        }
      }

      if (calendarExist) {
        setState(() {
          _calendar = calendarTemp;
        });
      } else {
        // create calendar
        final createCalendarResult = await _deviceCalendarPlugin.createCalendar("Customer Calendar App", calendarColor: Colors.yellow, localAccountName: "Customer Calendar App");
        if (createCalendarResult.isSuccess && createCalendarResult.data != null) {
          Calendar calendar = Calendar(
            id: createCalendarResult.data as String,
            name: "Customer Calendar App",
            isReadOnly: false,
            isDefault: false,
            color: Colors.yellow.value,
            accountName: "Customer Calendar App",
          );
          setState(() {
            _calendar = calendar;
          });
        }
      }
      return true;
    } on PlatformException catch (e) {
      print(e);
      return false;
    }
  }

  Future _retrieveCalendarEvents() async {
    print('retrieveCalendarEvents');

    final startDate = DateTime.now().add(const Duration(days: -30));
    final endDate = DateTime.now().add(const Duration(days: 30));
    var calendarEventsResult = await _deviceCalendarPlugin.retrieveEvents(_calendar!.id, RetrieveEventsParams(startDate: startDate, endDate: endDate));
    setState(() {
      _calendarEvents = calendarEventsResult.data ?? <Event>[] as List<Event>;
      _isLoading = false;
    });
  }

  void _onLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  Future _onDeletedFinished(bool deleteSucceeded) async {
    if (deleteSucceeded) {
      await _retrieveCalendarEvents();
    } else {
      mat.ScaffoldMessenger.of(context).showSnackBar(mat.SnackBar(
        content: Text('Oops, we ran into an issue deleting the event'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ));
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future _onTapped(Event event) async {
    final refreshEvents = await Navigator.push(context, mat.MaterialPageRoute(builder: (BuildContext context) {
      return CalendarEventPage(
        event: event,
        recurringEventDialog: RecurringEventDialog(
          _deviceCalendarPlugin,
          event,
          _onLoading,
          _onDeletedFinished,
        ),
      );
    }));
    if (refreshEvents != null && refreshEvents) {
      await _retrieveCalendarEvents();
    }
  }

  @override
  void initState() {
    super.initState();
    _deviceCalendarPlugin = DeviceCalendarPlugin();
    _retrieveCalendars().whenComplete(() {
      _retrieveCalendarEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: (_calendarEvents.isNotEmpty || _isLoading)
          ? Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.all(10.0),
                  itemCount: _calendarEvents.length,
                  itemBuilder: (BuildContext context, int index) {
                    return EventItem(_calendarEvents[index], _deviceCalendarPlugin, _onLoading, _onDeletedFinished, _onTapped, _calendar?.isReadOnly != null && _calendar?.isReadOnly as bool);
                  },
                ),
                if (_isLoading)
                  const Center(
                    child: ProgressRing(),
                  )
              ],
            )
          : Center(
              child: Column(
              children: [
                Text('No events found'),
                Button(
                  child: Text('Add Event'),
                  onPressed: () {
                    String calendarId = _calendar?.id ?? '';
                    print('calendarId: $calendarId');
                    _onTapped(
                      Event(
                        calendarId,
                        start: TZDateTime.now(timeZoneDatabase.locations['Asia/Ho_Chi_Minh']!),
                        end: TZDateTime.now(timeZoneDatabase.locations['Asia/Ho_Chi_Minh']!).add(const Duration(hours: 1)),
                        attendees: [],
                        reminders: [],
                      ),
                    );
                  },
                )
              ],
            )),
    );
  }
}

class EventItem extends StatefulWidget {
  final Event? _calendarEvent;
  final DeviceCalendarPlugin _deviceCalendarPlugin;
  final bool _isReadOnly;

  final Function(Event) _onTapped;
  final VoidCallback _onLoadingStarted;
  final Function(bool) _onDeleteFinished;

  const EventItem(this._calendarEvent, this._deviceCalendarPlugin, this._onLoadingStarted, this._onDeleteFinished, this._onTapped, this._isReadOnly, {Key? key}) : super(key: key);

  @override
  State<EventItem> createState() {
    return _EventItemState();
  }
}

class _EventItemState extends State<EventItem> {
  final double _eventFieldNameWidth = 75.0;
  Location? _currentLocation;

  @override
  void initState() {
    super.initState();
    setCurentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget._calendarEvent != null) {
          widget._onTapped(widget._calendarEvent as Event);
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: FlutterLogo(),
            ),
            ListTile(title: Text(widget._calendarEvent?.title ?? ''), subtitle: Text(widget._calendarEvent?.description ?? '')),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  if (_currentLocation != null)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Row(
                        children: [
                          SizedBox(
                            width: _eventFieldNameWidth,
                            child: const Text('Starts'),
                          ),
                          Text(
                            widget._calendarEvent == null
                                ? ''
                                : _formatDateTime(
                                    dateTime: widget._calendarEvent!.start!,
                                  ),
                          )
                        ],
                      ),
                    ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 5.0),
                  ),
                  if (_currentLocation != null)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Row(
                        children: [
                          SizedBox(
                            width: _eventFieldNameWidth,
                            child: const Text('Ends'),
                          ),
                          Text(
                            widget._calendarEvent?.end == null
                                ? ''
                                : _formatDateTime(
                                    dateTime: widget._calendarEvent!.end!,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        SizedBox(
                          width: _eventFieldNameWidth,
                          child: const Text('All day?'),
                        ),
                        Text(widget._calendarEvent?.allDay != null && widget._calendarEvent?.allDay == true ? 'Yes' : 'No')
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        SizedBox(
                          width: _eventFieldNameWidth,
                          child: const Text('Location'),
                        ),
                        Expanded(
                          child: Text(
                            widget._calendarEvent?.location ?? '',
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        SizedBox(
                          width: _eventFieldNameWidth,
                          child: const Text('URL'),
                        ),
                        Expanded(
                          child: Text(
                            widget._calendarEvent?.url?.data?.contentText ?? '',
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        SizedBox(
                          width: _eventFieldNameWidth,
                          child: const Text('Attendees'),
                        ),
                        Expanded(
                          child: Text(
                            widget._calendarEvent?.attendees?.where((a) => a?.name?.isNotEmpty ?? false).map((a) => a?.name).join(', ') ?? '',
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        SizedBox(
                          width: _eventFieldNameWidth,
                          child: const Text('Availability'),
                        ),
                        Expanded(
                          child: Text(
                            widget._calendarEvent?.availability.enumToString ?? '',
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        SizedBox(
                          width: _eventFieldNameWidth,
                          child: const Text('Status'),
                        ),
                        Expanded(
                          child: Text(
                            widget._calendarEvent?.status?.enumToString ?? '',
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            mat.ButtonBar(
              children: [
                if (!widget._isReadOnly) ...[
                  IconButton(
                    onPressed: () {
                      if (widget._calendarEvent != null) {
                        widget._onTapped(widget._calendarEvent as Event);
                      }
                    },
                    icon: const Icon(mat.Icons.edit),
                  ),
                  IconButton(
                    onPressed: () async {
                      await showDialog<bool>(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          if (widget._calendarEvent?.recurrenceRule == null) {
                            return mat.AlertDialog(
                              title: const Text('Are you sure you want to delete this event?'),
                              actions: [
                                mat.TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                mat.TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    widget._onLoadingStarted();
                                    final deleteResult = await widget._deviceCalendarPlugin.deleteEvent(widget._calendarEvent?.calendarId, widget._calendarEvent?.eventId);
                                    widget._onDeleteFinished(deleteResult.isSuccess && deleteResult.data != null);
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          } else {
                            if (widget._calendarEvent == null) {
                              return const SizedBox();
                            }
                            return RecurringEventDialog(widget._deviceCalendarPlugin, widget._calendarEvent!, widget._onLoadingStarted, widget._onDeleteFinished);
                          }
                        },
                      );
                    },
                    icon: const Icon(mat.Icons.delete),
                  ),
                ] else ...[
                  IconButton(
                    onPressed: () {
                      if (widget._calendarEvent != null) {
                        widget._onTapped(widget._calendarEvent!);
                      }
                    },
                    icon: const Icon(mat.Icons.remove_red_eye),
                  ),
                ]
              ],
            )
          ],
        ),
      ),
    );
  }

  void setCurentLocation() async {
    String? timezone;
    try {
      timezone = await FlutterTimezone.getLocalTimezone();
    } catch (e) {
      print('Could not get the local timezone');
    }
    timezone ??= 'Etc/UTC';
    _currentLocation = timeZoneDatabase.locations[timezone];
    setState(() {});
  }

  /// Formats [dateTime] into a human-readable string.
  /// If [_calendarEvent] is an Android allDay event, then the output will
  /// omit the time.
  String _formatDateTime({DateTime? dateTime}) {
    if (dateTime == null) {
      return 'Error';
    }
    var output = '';
    if (Platform.isAndroid && widget._calendarEvent?.allDay == true) {
      // just the dates, no times
      output = DateFormat.yMd().format(dateTime);
    } else {
      output = DateFormat('yyyy-MM-dd HH:mm:ss').format(TZDateTime.from(dateTime, _currentLocation!));
    }
    return output;
  }
}

class RecurringEventDialog extends StatefulWidget {
  final DeviceCalendarPlugin _deviceCalendarPlugin;
  final Event _calendarEvent;

  final VoidCallback _onLoadingStarted;
  final Function(bool) _onDeleteFinished;

  const RecurringEventDialog(this._deviceCalendarPlugin, this._calendarEvent, this._onLoadingStarted, this._onDeleteFinished, {Key? key}) : super(key: key);

  @override
  _RecurringEventDialogState createState() => _RecurringEventDialogState(_deviceCalendarPlugin, _calendarEvent, onLoadingStarted: _onLoadingStarted, onDeleteFinished: _onDeleteFinished);
}

class _RecurringEventDialogState extends State<RecurringEventDialog> {
  late DeviceCalendarPlugin _deviceCalendarPlugin;
  late Event _calendarEvent;
  VoidCallback? _onLoadingStarted;
  Function(bool)? _onDeleteFinished;

  _RecurringEventDialogState(DeviceCalendarPlugin deviceCalendarPlugin, Event calendarEvent, {VoidCallback? onLoadingStarted, Function(bool)? onDeleteFinished}) {
    _deviceCalendarPlugin = deviceCalendarPlugin;
    _calendarEvent = calendarEvent;
    _onLoadingStarted = onLoadingStarted;
    _onDeleteFinished = onDeleteFinished;
  }

  @override
  Widget build(BuildContext context) {
    return mat.SimpleDialog(
      title: const Text('Are you sure you want to delete this event?'),
      children: <Widget>[
        mat.SimpleDialogOption(
          onPressed: () async {
            Navigator.of(context).pop(true);
            if (_onLoadingStarted != null) _onLoadingStarted!();
            final deleteResult = await _deviceCalendarPlugin.deleteEventInstance(_calendarEvent.calendarId, _calendarEvent.eventId, _calendarEvent.start?.millisecondsSinceEpoch, _calendarEvent.end?.millisecondsSinceEpoch, false);
            if (_onDeleteFinished != null) {
              _onDeleteFinished!(deleteResult.isSuccess && deleteResult.data != null);
            }
          },
          child: const Text('This instance only'),
        ),
        mat.SimpleDialogOption(
          onPressed: () async {
            Navigator.of(context).pop(true);
            if (_onLoadingStarted != null) _onLoadingStarted!();
            final deleteResult = await _deviceCalendarPlugin.deleteEventInstance(_calendarEvent.calendarId, _calendarEvent.eventId, _calendarEvent.start?.millisecondsSinceEpoch, _calendarEvent.end?.millisecondsSinceEpoch, true);
            if (_onDeleteFinished != null) {
              _onDeleteFinished!(deleteResult.isSuccess && deleteResult.data != null);
            }
          },
          child: const Text('This and following instances'),
        ),
        mat.SimpleDialogOption(
          onPressed: () async {
            Navigator.of(context).pop(true);
            if (_onLoadingStarted != null) _onLoadingStarted!();
            final deleteResult = await _deviceCalendarPlugin.deleteEvent(_calendarEvent.calendarId, _calendarEvent.eventId);
            if (_onDeleteFinished != null) {
              _onDeleteFinished!(deleteResult.isSuccess && deleteResult.data != null);
            }
          },
          child: const Text('All instances'),
        ),
        mat.SimpleDialogOption(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancel'),
        )
      ],
    );
  }
}
