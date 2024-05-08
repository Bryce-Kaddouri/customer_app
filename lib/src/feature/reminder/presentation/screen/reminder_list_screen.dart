import 'package:device_calendar/device_calendar.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../widget/reminder_card_widget.dart';

class RemindersListScreen extends StatefulWidget {
  const RemindersListScreen({super.key});

  @override
  State<RemindersListScreen> createState() => _RemindersListScreenState();
}

class _RemindersListScreenState extends State<RemindersListScreen> {
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
      /* mat.ScaffoldMessenger.of(context).showSnackBar(mat.SnackBar(
        content: Text('Oops, we ran into an issue deleting the event'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ));*/
      print('Oops, we ran into an issue deleting the event');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future _onTapped(Event event) async {
    context.push('/reminder/detail/${event.eventId}', extra: event.toJson());
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
                    return ReminderCardWidget(_calendarEvents[index], _deviceCalendarPlugin, _onLoading, _onDeletedFinished, _onTapped, _calendar?.isReadOnly != null && _calendar?.isReadOnly as bool);
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
              ],
            )),
    );
  }
}
