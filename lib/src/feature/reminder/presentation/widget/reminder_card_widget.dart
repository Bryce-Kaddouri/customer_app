import 'package:customer_app/src/core/helper/date_helper.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:fluent_ui/fluent_ui.dart';

class ReminderCardWidget extends StatefulWidget {
  final Event? _calendarEvent;
  final DeviceCalendarPlugin _deviceCalendarPlugin;
  final bool _isReadOnly;

  final Function(Event) _onTapped;
  final VoidCallback _onLoadingStarted;
  final Function(bool) _onDeleteFinished;

  const ReminderCardWidget(this._calendarEvent, this._deviceCalendarPlugin, this._onLoadingStarted, this._onDeleteFinished, this._onTapped, this._isReadOnly, {Key? key}) : super(key: key);

  @override
  State<ReminderCardWidget> createState() {
    return _ReminderCardWidgetState();
  }
}

class _ReminderCardWidgetState extends State<ReminderCardWidget> {
  final double _eventFieldNameWidth = 75.0;
  Location? _currentLocation;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      padding: const EdgeInsets.all(0.0),
      margin: const EdgeInsets.only(bottom: 10.0),
      child: ListTile(
        trailing: Icon(FluentIcons.chevron_right),
        onPressed: () {
          if (widget._calendarEvent != null) {
            widget._onTapped(widget._calendarEvent as Event);
          }
        },
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget._calendarEvent?.title ?? ''),
            Text(widget._calendarEvent?.description ?? ''),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        SizedBox(
                          width: _eventFieldNameWidth,
                          child: const Text('From'),
                        ),
                        Text(
                          widget._calendarEvent == null ? '' : DateHelper.getFormattedDateWithTime(DateTime.parse(widget._calendarEvent!.start!.toIso8601String())),
                        )
                      ],
                    ),
                  ),
                  /*const Padding(
                    padding: EdgeInsets.symmetric(vertical: 5.0),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        SizedBox(
                          width: _eventFieldNameWidth,
                          child: const Text('To'),
                        ),
                        Text(
                          widget._calendarEvent?.end == null ? 'test' : DateHelper.getFormattedDateWithTime(DateTime.parse(widget._calendarEvent!.end!.toIso8601String())),
                          style: FluentTheme.of(context).typography.body,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),*/
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
