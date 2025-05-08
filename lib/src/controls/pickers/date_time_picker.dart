import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluent_ui/src/controls/pickers/pickers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

/// The duration of a complete year
const _kYearDuration = Duration(days: 365);

String _formatHour(int hour, String locale) {
  return DateFormat.H(locale).format(DateTime(
    0, // year
    0, // month
    0, // day
    hour,
  ));
}

String _formatMinute(int minute, String locale) {
  if (minute < 10) {
    return '0$minute';
  }
  return DateFormat.m(locale).format(DateTime(
    0, // year
    0, // month
    0, // day
    0, // hour,
    minute,
  ));
}

/// Returns the amount of months in the desired year
Iterable<int> _monthsInYear(
  DateTime localDate,
  DateTime startDate,
  DateTime endDate,
) sync* {
  if (localDate.year == startDate.year) {
    for (var current = startDate.month; current <= 12; current++) {
      yield current;
    }
  } else if (localDate.year == endDate.year) {
    for (var current = endDate.month; current <= 12; current++) {
      yield current;
    }
  } else {
    yield* List.generate(DateTime.monthsPerYear, (index) => index + 1);
  }
}

/// The fields used on date picker.
enum DateTimePickerField {
  /// The hour field
  hour,

  /// The minute field
  minute,

  /// The minute field
  amPm,

  /// The month field
  month,

  /// The day field
  day,

  /// The year field
  year,
}

/// The date picker gives you a standardized way to let users pick a localized
/// date value using touch, mouse, or keyboard input.
///
/// ![DatePicker Preview](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/controls-datepicker-expand.gif)
///
/// See also:
///
///  * [TimePicker], which gives you a standardized way to let users pick a time
///    value
///  * <https://docs.microsoft.com/en-us/windows/apps/design/controls/date-picker>
class DateTimePicker extends StatefulWidget {
  /// Creates a date picker.
  DateTimePicker({
    super.key,
    required this.selected,
    this.onChanged,
    this.onCancel,
    this.header,
    this.headerStyle,
    this.showDay = true,
    this.showMonth = true,
    this.showYear = true,
    this.showHour = true,
    this.showMinute = true,
    this.minuteIncrement = 1,
    this.hourFormat = HourFormat.h,
    DateTime? startDate,
    DateTime? endDate,
    this.contentPadding = kPickerContentPadding,
    this.popupHeight = kPickerPopupHeight,
    this.focusNode,
    this.autofocus = false,
    this.locale,
    this.fieldOrder,
    this.fieldFlex,
    this.isExpanded = false,
    this.enabled = true,
  })  : startDate = startDate ?? DateTime.now().subtract(_kYearDuration * 100),
        endDate = endDate ?? DateTime.now().add(_kYearDuration * 25),
        assert(
          (showMinute == true && showHour == true) || (showMinute == false),
          'if showMinute = true then showHour must be true',
        ),
        assert(
          fieldFlex == null || fieldFlex.length == 3,
          'fieldFlex must be null or have a length of 3',
        );

  final bool enabled;

  /// The current date selected date.
  ///
  /// If null, no date is going to be shown.
  final DateTime? selected;

  /// Whenever the current selected date is changed by the user.
  ///
  /// If null, the picker is considered disabled
  final ValueChanged<DateTime>? onChanged;

  /// Whenever the user cancels the date change.
  final VoidCallback? onCancel;

  /// The clock system to use
  final HourFormat hourFormat;

  /// The content of the header
  final String? header;

  /// The style of the [header]
  final TextStyle? headerStyle;

  /// Whenever to show the hour
  ///
  /// See also:
  ///
  ///  * [showDay], which configures whether to show the day field
  ///  * [showYear], which configures whether to show the year field
  final bool showHour;

  /// Whenever to show the minute
  ///
  /// See also:
  ///
  ///  * [showDay], which configures whether to show the day field
  ///  * [showYear], which configures whether to show the year field
  final bool showMinute;

  /// Whenever to show the month field
  ///
  /// See also:
  ///
  ///  * [showDay], which configures whether to show the day field
  ///  * [showYear], which configures whether to show the year field
  final bool showMonth;

  /// Whenever to show the day field
  ///
  /// See also:
  ///
  ///  * [showMonth], which configures whether to show the month field
  ///  * [showYear], which configures whether to show the year field
  final bool showDay;

  /// Whenever to show the year field
  ///
  /// See also:
  ///
  ///  * [showDay], which configures whether to show the day field
  ///  * [showMonth], which configures whether to show the month field
  final bool showYear;

  /// The date displayed at the beggining
  ///
  /// Defaults to 100 to today
  final DateTime startDate;

  /// The date displayed at the end of the list
  ///
  /// Defaults to 25 years from today
  final DateTime endDate;

  /// The padding of the picker fields. Defaults to [kPickerContentPadding]
  final EdgeInsetsGeometry contentPadding;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// Is the maximum width of picker fields.
  ///
  /// Defaults is false
  final bool isExpanded;

  /// The value that indicates the time increments shown in the minute picker.
  /// For example, 15 specifies that the TimePicker minute control displays
  /// only the choices 00, 15, 30, 45.
  ///
  /// ![15 minute increment preview](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/date-time/time-picker-minute-increment.png)
  ///
  /// Defaults to 1
  final int minuteIncrement;

  /// The height of the popup.
  ///
  /// Defaults to [kPickerPopupHeight]
  final double popupHeight;

  /// The locale used to format the month name.
  ///
  /// If null, the system locale will be used.
  final Locale? locale;

  /// The order of the fields.
  ///
  /// If null, the order is based on the current locale.
  ///
  /// See also:
  ///
  ///  * [_getDateOrderFromLocale], which returns the order of the fields based
  ///    on the current locale
  final List<DateTimePickerField>? fieldOrder;

  /// The flex of the fields.
  ///
  /// if null, the flex is base on the current locale.
  ///
  /// See also:
  ///
  /// * [_getDateFlexFromLocale], which returns the flex of the fields based
  ///   on the current locale
  final List<int>? fieldFlex;

  bool get use24Format =>
      [HourFormat.HH, HourFormat.H].contains(hourFormat) || !showHour;

  @override
  State<DateTimePicker> createState() => _DateTimePickerState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<DateTime>('selected', selected, ifNull: 'now'))
      ..add(FlagProperty(
        'showMonth',
        value: showMonth,
        ifFalse: 'not displaying month',
      ))
      ..add(FlagProperty(
        'showDay',
        value: showDay,
        ifFalse: 'not displaying day',
      ))
      ..add(FlagProperty(
        'showHour',
        value: showHour,
        ifFalse: 'not displaying hour',
      ))
      ..add(FlagProperty(
        'showMinute',
        value: showMinute,
        ifFalse: 'not displaying minute',
      ))
      ..add(FlagProperty(
        'showYear',
        value: showYear,
        ifFalse: 'not displaying year',
      ))
      ..add(EnumProperty<HourFormat>(
        'hourFormat',
        hourFormat,
        defaultValue: HourFormat.h,
      ))
      ..add(DiagnosticsProperty<DateTime>('startDate', startDate))
      ..add(DiagnosticsProperty<DateTime>('endDate', endDate))
      ..add(DiagnosticsProperty('contentPadding', contentPadding))
      ..add(ObjectFlagProperty.has('focusNode', focusNode))
      ..add(FlagProperty(
        'autofocus',
        value: autofocus,
        ifFalse: 'manual focus',
      ))
      ..add(DoubleProperty(
        'popupHeight',
        popupHeight,
        defaultValue: kPickerPopupHeight,
      ))
      ..add(DiagnosticsProperty<Locale>('locale', locale))
      ..add(IterableProperty<DateTimePickerField>('fieldOrder', fieldOrder));
  }
}

class _DateTimePickerState extends State<DateTimePicker> {
  late DateTime time;

  final GlobalKey _buttonKey =
      GlobalKey(debugLabel: 'Date Time Picker button key');

  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _amPmController;

  bool am = true;
  bool get _isPm => time.hour >= 12;

  int get startYear => widget.startDate.year;
  int get endYear => widget.endDate.year;

  int get currentYear {
    return List.generate(endYear - startYear + 1, (index) {
      return startYear + index;
    }).firstWhere((v) => v == time.year, orElse: () => 0);
  }

  @override
  void initState() {
    super.initState();
    time = widget.selected ?? DateTime.now();
    initControllers();
  }

  void initControllers() {
    if (widget.selected == null && mounted) {
      setState(() => time = DateTime.now());
    }
    _monthController = FixedExtentScrollController(
      initialItem: _monthsInYear(time, widget.startDate, widget.endDate)
          .toList()
          .indexOf(time.month),
    );
    _dayController = FixedExtentScrollController(
      initialItem: time.day - 1,
    );
    _yearController = FixedExtentScrollController(
      initialItem: currentYear - startYear,
    );

    _hourController = FixedExtentScrollController(
      initialItem: () {
        var hour = time.hour - 1;
        if (!widget.use24Format) {
          hour -= 12;
        }
        return hour;
      }(),
    );
    _minuteController = FixedExtentScrollController(initialItem: time.minute);

    _amPmController = FixedExtentScrollController(initialItem: _isPm ? 1 : 0);
  }

  @override
  void dispose() {
    _monthController.dispose();
    _dayController.dispose();
    _yearController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    _amPmController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DateTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != time) {
      time = widget.selected ?? DateTime.now();
      _monthController.jumpToItem(time.month - 1);
      _dayController.jumpToItem(time.day - 1);
      _yearController.jumpToItem(currentYear - startYear - 1);
      _hourController.jumpToItem(() {
        var hour = time.hour - 1;
        if (!widget.use24Format) {
          hour -= 12;
        }
        return hour;
      }());
      _minuteController.jumpToItem(time.minute);
      _amPmController.jumpToItem(_isPm ? 1 : 0);
    }
  }

  void handleDateChanged(DateTime newDate) {
    if (mounted) setState(() => time = newDate);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentLocalizations(context));
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final localizations = FluentLocalizations.of(context);

    final locale = widget.locale ?? Localizations.maybeLocaleOf(context);

    final fieldOrder = widget.fieldOrder ?? _getDateOrderFromLocale(locale);
    final fieldFlex = widget.fieldFlex ?? _getDateFlexFromLocale(locale);
    assert(fieldOrder.isNotEmpty);
    assert(
      fieldOrder.where((f) => f == DateTimePickerField.month).length <= 1,
      'There can be only one month field',
    );
    assert(
      fieldOrder.where((f) => f == DateTimePickerField.day).length <= 1,
      'There can be only one day field',
    );
    assert(
      fieldOrder.where((f) => f == DateTimePickerField.year).length <= 1,
      'There can be only one year field',
    );
    assert(
      fieldOrder.where((f) => f == DateTimePickerField.hour).length <= 1,
      'There can be only one hour field',
    );
    assert(
      fieldOrder.where((f) => f == DateTimePickerField.minute).length <= 1,
      'There can be only one minute field',
    );

    Widget picker = Picker(
      isExpanded: widget.isExpanded,
      pickerContent: (context) {
        return _DateTimePickerContentPopUp(
          date: time,
          dayController: _dayController,
          monthController: _monthController,
          yearController: _yearController,
          hourController: _hourController,
          minuteController: _minuteController,
          amPmController: _amPmController,
          onCancel: () => widget.onCancel?.call(),
          onChanged: (date) => widget.onChanged?.call(date),
          showDay: widget.showDay,
          showMonth: widget.showMonth,
          showYear: widget.showYear,
          showHour: widget.showHour,
          showMinute: widget.showMinute,
          startDate: widget.startDate,
          endDate: widget.endDate,
          locale: locale,
          fieldOrder: fieldOrder,
          fieldFlex: fieldFlex,
          use24Format: widget.use24Format,
          minuteIncrement: widget.minuteIncrement,
        );
      },
      pickerHeight: widget.popupHeight,
      child: (context, open) => HoverButton(
        autofocus: widget.autofocus,
        focusNode: widget.focusNode,
        onPressed: () async {
          _monthController.dispose();
          // _monthController = null;
          _dayController.dispose();
          // _dayController = null;
          _yearController.dispose();
          // _yearController = null;
          _hourController.dispose();
          // _hourController = null;
          _minuteController.dispose();
          // _minuteController = null;
          _amPmController.dispose();
          // _amPmController = null;
          initControllers();
          await open();
        },
        builder: (context, states) {
          if (states.isDisabled) states = <WidgetState>{};
          const divider = Divider(
            direction: Axis.vertical,
            style: DividerThemeData(
              verticalMargin: EdgeInsets.zero,
              horizontalMargin: EdgeInsets.zero,
            ),
          );

          final monthWidgets = [
            Expanded(
              flex: fieldFlex[fieldOrder.indexOf(DateTimePickerField.month)],
              child: Padding(
                padding: widget.contentPadding,
                child: Text(
                  widget.selected == null
                      ? localizations.month
                      : DateFormat(DateFormat.STANDALONE_MONTH, '$locale')
                          .format(widget.selected!)
                          .uppercaseFirst(),
                  locale: locale,
                  textAlign: TextAlign.center,
                  style: kPickerTextStyle(context, widget.enabled),
                ),
              ),
            )
          ];

          final dayWidget = [
            Expanded(
              flex: fieldFlex[fieldOrder.indexOf(DateTimePickerField.day)],
              child: Text(
                widget.selected == null
                    ? localizations.day
                    : DateFormat.d('$locale').format(DateTime(
                        0,
                        0,
                        widget.selected!.day,
                      )),
                textAlign: TextAlign.center,
                style: kPickerTextStyle(context, widget.enabled),
              ),
            ),
          ];

          final yearWidgets = [
            Expanded(
              flex: fieldFlex[fieldOrder.indexOf(DateTimePickerField.year)],
              child: Text(
                widget.selected == null
                    ? localizations.year
                    : DateFormat.y('$locale').format(DateTime(
                        widget.selected!.year,
                      )),
                textAlign: TextAlign.center,
                style: kPickerTextStyle(context, widget.enabled),
              ),
            ),
          ];
          final hourWidgets = [
            Expanded(
              flex: fieldFlex[fieldOrder.indexOf(DateTimePickerField.hour)],
              child: Padding(
                padding: widget.contentPadding,
                child: Text(
                  () {
                    if (widget.selected == null) {
                      return localizations.hour;
                    }
                    late int finalHour;
                    var hour = time.hour;
                    if (!widget.use24Format && hour > 12) {
                      finalHour = hour - 12;
                    } else {
                      finalHour = hour;
                    }

                    return _formatHour(finalHour, locale!.toString());
                  }(),
                  textAlign: TextAlign.center,
                  style: kPickerTextStyle(context, widget.enabled),
                ),
              ),
            ),
          ];
          final minuteWidgets = [
            Expanded(
              flex: fieldFlex[fieldOrder.indexOf(DateTimePickerField.minute)],
              child: Padding(
                padding: widget.contentPadding,
                child: Text(
                  widget.selected == null
                      ? localizations.minute
                      : _formatMinute(time.minute, '$locale'),
                  textAlign: TextAlign.center,
                  style: kPickerTextStyle(context, widget.enabled),
                ),
              ),
            ),
          ];

          final amPmWidgets = [
            Expanded(
              flex: fieldFlex[fieldOrder.indexOf(DateTimePickerField.amPm)],
              child: Padding(
                padding: widget.contentPadding,
                child: Text(
                  () {
                    if (_isPm) return localizations.pm;
                    return localizations.am;
                  }(),
                  textAlign: TextAlign.center,
                  style: kPickerTextStyle(context, widget.enabled),
                ),
              ),
            ),
          ];
          final fields = <DateTimePickerField, List<Widget>>{
            if (widget.showYear) DateTimePickerField.year: yearWidgets,
            if (widget.showMonth) DateTimePickerField.month: monthWidgets,
            if (widget.showDay) DateTimePickerField.day: dayWidget,
            if (widget.showHour) DateTimePickerField.hour: hourWidgets,
            if (widget.showMinute) DateTimePickerField.minute: minuteWidgets,
            if (!widget.use24Format) DateTimePickerField.amPm: amPmWidgets,
          };

          final fieldMap = fieldOrder.map((e) => fields[e]);

          return FocusBorder(
            focused: states.isFocused,
            child: AnimatedContainer(
              duration: theme.fastAnimationDuration,
              curve: theme.animationCurve,
              height: kPickerHeight,
              decoration: kPickerDecorationBuilder(context, states),
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  color: widget.selected == null
                      ? theme.resources.textFillColorSecondary
                      : null,
                ),
                maxLines: 1,
                child: Row(
                    key: _buttonKey,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...fieldMap.elementAt(0) ?? [],
                      if (fieldMap.length > 1 &&
                          fieldMap.elementAt(1) != null) ...[
                        if (fieldMap.elementAt(0) != null) divider,
                        ...fieldMap.elementAt(1)!,
                      ],
                      if (fieldMap.length > 2 &&
                          fieldMap.elementAt(2) != null) ...[
                        divider,
                        ...fieldMap.elementAt(2)!,
                      ],
                      if (fieldMap.length > 3 &&
                          fieldMap.elementAt(3) != null) ...[
                        divider,
                        ...fieldMap.elementAt(3)!,
                      ],
                      if (fieldMap.length > 4 &&
                          fieldMap.elementAt(4) != null) ...[
                        divider,
                        ...fieldMap.elementAt(4)!,
                      ],
                      if (fieldMap.length > 5 &&
                          fieldMap.elementAt(5) != null) ...[
                        divider,
                        ...fieldMap.elementAt(5)!,
                      ],
                    ]),
              ),
            ),
          );
        },
      ),
    );
    if (widget.header != null) {
      return InfoLabel(
        label: widget.header!,
        labelStyle: widget.headerStyle,
        child: picker,
      );
    }
    return picker;
  }
}

class _DateTimePickerContentPopUp extends StatefulWidget {
  const _DateTimePickerContentPopUp({
    required this.showMonth,
    required this.showDay,
    required this.showYear,
    required this.showHour,
    required this.showMinute,
    required this.date,
    required this.onChanged,
    required this.onCancel,
    required this.monthController,
    required this.dayController,
    required this.yearController,
    required this.hourController,
    required this.minuteController,
    required this.amPmController,
    required this.startDate,
    required this.endDate,
    required this.locale,
    required this.fieldOrder,
    required this.fieldFlex,
    required this.use24Format,
    required this.minuteIncrement,
  });

  final bool showMonth;
  final bool showDay;
  final bool showYear;
  final bool showHour;
  final bool showMinute;
  final DateTime date;
  final ValueChanged<DateTime> onChanged;
  final VoidCallback onCancel;
  final FixedExtentScrollController monthController;
  final FixedExtentScrollController dayController;
  final FixedExtentScrollController yearController;
  final FixedExtentScrollController hourController;
  final FixedExtentScrollController minuteController;
  final FixedExtentScrollController amPmController;
  final DateTime startDate;
  final DateTime endDate;
  final Locale? locale;
  final List<DateTimePickerField> fieldOrder;
  final List<int> fieldFlex;

  final bool use24Format;
  final int minuteIncrement;

  @override
  State<_DateTimePickerContentPopUp> createState() =>
      _DateTimePickerContentPopUpState();
}

class _DateTimePickerContentPopUpState
    extends State<_DateTimePickerContentPopUp> {
  int _getDaysInMonth([int? month, int? year]) {
    year ??= DateTime.now().year;
    month ??= DateTime.now().month;
    return DateTimeRange(
      start: DateTime.utc(year, month),
      end: DateTime.utc(year, month + 1),
    ).duration.inDays;
  }

  late DateTime localDate = widget.date;

  bool get isAm => widget.amPmController.selectedItem == 0;

  Iterable<int> get monthsInCurrentYear {
    return _monthsInYear(localDate, widget.startDate, widget.endDate);
  }

  void handleDateChanged(DateTime time) {
    if (localDate == time || !mounted) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      setState(() {
        localDate = time;
      });

      final monthIndex = monthsInCurrentYear.toList().indexOf(localDate.month);
      if (widget.showMonth &&
          widget.monthController.selectedItem != monthIndex) {
        widget.monthController.jumpToItem(monthIndex);
      }

      if (widget.showDay &&
          widget.dayController.selectedItem != localDate.day - 1) {
        widget.dayController.jumpToItem(localDate.day - 1);
      }
    });
  }

  int getClosestMinute(List<int> possibleMinutes, int goal) {
    return possibleMinutes
        .reduce(
          (prev, curr) =>
              (curr - goal).abs() < (prev - goal).abs() ? curr : prev,
        )
        .clamp(0, 59);
  }

  @override
  void initState() {
    super.initState();
    localDate = widget.date;
    final possibleMinutes = List.generate(
      60 ~/ widget.minuteIncrement,
      (index) => index * widget.minuteIncrement,
    );
    if (!possibleMinutes.contains(localDate.minute)) {
      localDate = DateTime(
        localDate.year,
        localDate.month,
        localDate.day,
        localDate.hour,
        getClosestMinute(possibleMinutes, localDate.minute),
        localDate.second,
        localDate.millisecond,
        localDate.microsecond,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final localizations = FluentLocalizations.of(context);
    final duration = theme.fasterAnimationDuration;
    const divider = Divider(
      direction: Axis.vertical,
      style: DividerThemeData(
        verticalMargin: EdgeInsets.zero,
        horizontalMargin: EdgeInsets.zero,
      ),
    );

    final locale = widget.locale ?? Localizations.maybeLocaleOf(context);
    final curve = theme.animationCurve;
    final months = monthsInCurrentYear;
    final hoursAmount = widget.use24Format ? 24 : 12;
    final monthWidget = [
      Expanded(
        flex: widget
            .fieldFlex[widget.fieldOrder.indexOf(DateTimePickerField.month)],
        child: () {
          final formatter = DateFormat.MMMM(locale.toString());
          // MONTH
          return PickerNavigatorIndicator(
            onBackward: () {
              widget.monthController.navigateSides(
                context,
                false,
                months.length,
              );
            },
            onForward: () {
              widget.monthController.navigateSides(
                context,
                true,
                months.length,
              );
            },
            child: ListWheelScrollView.useDelegate(
              controller: widget.monthController,
              itemExtent: kOneLineTileHeight,
              diameterRatio: kPickerDiameterRatio,
              physics: const FixedExtentScrollPhysics(),
              childDelegate: ListWheelChildLoopingListDelegate(
                children: List.generate(months.length, (index) {
                  final month = months.elementAt(index);
                  final text =
                      formatter.format(DateTime(1, month)).uppercaseFirst();
                  final selected = month == localDate.month;

                  return ListTile(
                    onPressed: selected
                        ? null
                        : () {
                            widget.monthController.animateToItem(
                              index,
                              duration: theme.mediumAnimationDuration,
                              curve: theme.animationCurve,
                            );
                          },
                    title: Text(
                      text,
                      style: kPickerPopupTextStyle(context, selected),
                      locale: locale,
                    ),
                  );
                }),
              ),
              onSelectedItemChanged: (index) {
                final month = months.elementAt(index);
                final daysInMonth = _getDaysInMonth(month, localDate.year);

                var day = localDate.day;
                if (day > daysInMonth) day = daysInMonth;

                handleDateChanged(DateTime(
                  localDate.year,
                  month,
                  day,
                  localDate.hour,
                  localDate.minute,
                  localDate.second,
                  localDate.millisecond,
                  localDate.microsecond,
                ));
              },
            ),
          );
        }(),
      ),
    ];

    final dayWidget = [
      Expanded(
        flex: widget
            .fieldFlex[widget.fieldOrder.indexOf(DateTimePickerField.day)],
        child: () {
          // DAY
          final daysInMonth = _getDaysInMonth(localDate.month, localDate.year);
          final formatter = DateFormat.d(locale.toString());
          return PickerNavigatorIndicator(
            onBackward: () {
              widget.dayController.navigateSides(
                context,
                false,
                daysInMonth,
              );
            },
            onForward: () {
              widget.dayController.navigateSides(
                context,
                true,
                daysInMonth,
              );
            },
            child: ListWheelScrollView.useDelegate(
              controller: widget.dayController,
              itemExtent: kOneLineTileHeight,
              diameterRatio: kPickerDiameterRatio,
              physics: const FixedExtentScrollPhysics(),
              childDelegate: ListWheelChildLoopingListDelegate(
                children: List<Widget>.generate(daysInMonth, (index) {
                  final day = index + 1;
                  final selected = day == localDate.day;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    key: ValueKey(day),
                    onPressed: selected
                        ? null
                        : () {
                            widget.dayController.animateToItem(
                              index,
                              duration: theme.mediumAnimationDuration,
                              curve: theme.animationCurve,
                            );
                          },
                    title: Center(
                      child: Text(
                        // '$day',
                        formatter.format(DateTime(
                          localDate.year,
                          localDate.month,
                          day,
                        )),
                        style: kPickerPopupTextStyle(context, selected),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }, growable: false),
              ),
              onSelectedItemChanged: (index) {
                handleDateChanged(DateTime(
                  localDate.year,
                  localDate.month,
                  index + 1,
                  localDate.hour,
                  localDate.minute,
                  localDate.second,
                  localDate.millisecond,
                  localDate.microsecond,
                ));
              },
            ),
          );
        }(),
      ),
    ];

    final yearWidget = [
      Expanded(
        flex: widget
            .fieldFlex[widget.fieldOrder.indexOf(DateTimePickerField.year)],
        child: () {
          final years = widget.endDate.year - widget.startDate.year + 1;
          final formatter = DateFormat.y(locale.toString());
          // YEAR
          return PickerNavigatorIndicator(
            onBackward: () {
              widget.yearController.navigateSides(
                context,
                false,
                years,
              );
            },
            onForward: () {
              widget.yearController.navigateSides(
                context,
                true,
                years,
              );
            },
            child: ListWheelScrollView(
              controller: widget.yearController,
              itemExtent: kOneLineTileHeight,
              diameterRatio: kPickerDiameterRatio,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                var month = localDate.month;

                if (!monthsInCurrentYear.contains(month)) {
                  month = monthsInCurrentYear.first;
                }

                handleDateChanged(DateTime(
                  widget.startDate.year + index,
                  month,
                  localDate.day,
                  localDate.hour,
                  localDate.minute,
                  localDate.second,
                  localDate.millisecond,
                  localDate.microsecond,
                ));
              },
              children: List.generate(years, (index) {
                final realYear = widget.startDate.year + index;
                final selected = realYear == localDate.year;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  onPressed: selected
                      ? null
                      : () {
                          widget.yearController.animateToItem(
                            index,
                            duration: theme.mediumAnimationDuration,
                            curve: theme.animationCurve,
                          );
                        },
                  title: Text(
                    formatter.format(DateTime(realYear)),
                    style: kPickerPopupTextStyle(context, selected),
                    textAlign: TextAlign.center,
                  ),
                );
              }),
            ),
          );
        }(),
      ),
    ];

    final hourWidget = [
      Expanded(
        flex: widget
            .fieldFlex[widget.fieldOrder.indexOf(DateTimePickerField.hour)],
        child: PickerNavigatorIndicator(
          onBackward: () {
            widget.hourController.navigateSides(
              context,
              false,
              hoursAmount,
            );
          },
          onForward: () {
            widget.hourController.navigateSides(
              context,
              true,
              hoursAmount,
            );
          },
          child: ListWheelScrollView.useDelegate(
            controller: widget.hourController,
            childDelegate: ListWheelChildLoopingListDelegate(
              children: List.generate(hoursAmount, (index) {
                final hour = index + 1;
                final realHour = () {
                  if (!widget.use24Format && localDate.hour > 12) {
                    return hour + 12;
                  }
                  return hour;
                }();
                final selected = localDate.hour == realHour;

                return ListTile(
                  onPressed: selected
                      ? null
                      : () {
                          widget.hourController.animateToItem(
                            index,
                            duration: theme.mediumAnimationDuration,
                            curve: theme.animationCurve,
                          );
                        },
                  title: Center(
                    child: Text(
                      _formatHour(hour, widget.locale!.toString()),
                      style: kPickerPopupTextStyle(context, selected),
                    ),
                  ),
                );
              }),
            ),
            itemExtent: kOneLineTileHeight,
            diameterRatio: kPickerDiameterRatio,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              var hour = index + 1;
              if (!widget.use24Format && !isAm) {
                hour += 12;
              }
              handleDateChanged(DateTime(
                localDate.year,
                localDate.month,
                localDate.day,
                hour,
                localDate.minute,
                localDate.second,
                localDate.millisecond,
                localDate.microsecond,
              ));
            },
          ),
        ),
      ),
    ];

    final minuteWidget = [
      Expanded(
        flex: widget
            .fieldFlex[widget.fieldOrder.indexOf(DateTimePickerField.minute)],
        child: PickerNavigatorIndicator(
          onBackward: () {
            widget.minuteController.navigateSides(
              context,
              false,
              60,
            );
          },
          onForward: () {
            widget.minuteController.navigateSides(
              context,
              true,
              60,
            );
          },
          child: ListWheelScrollView.useDelegate(
            controller: widget.minuteController,
            childDelegate: ListWheelChildLoopingListDelegate(
              children: List.generate(
                60 ~/ widget.minuteIncrement,
                (index) {
                  final minute = index * widget.minuteIncrement;
                  final selected = minute == localDate.minute;
                  return ListTile(
                    onPressed: selected
                        ? null
                        : () {
                            widget.minuteController.animateToItem(
                              index,
                              duration: theme.mediumAnimationDuration,
                              curve: theme.animationCurve,
                            );
                          },
                    title: Center(
                      child: Text(
                        _formatMinute(minute, '${widget.locale}'),
                        style: kPickerPopupTextStyle(context, selected),
                      ),
                    ),
                  );
                },
              ),
            ),
            itemExtent: kOneLineTileHeight,
            diameterRatio: kPickerDiameterRatio,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              final minute = index * widget.minuteIncrement;
              handleDateChanged(DateTime(
                localDate.year,
                localDate.month,
                localDate.day,
                localDate.hour,
                minute,
                localDate.second,
                localDate.millisecond,
                localDate.microsecond,
              ));
            },
          ),
        ),
      ),
    ];

    final ampmWidget = [
      Expanded(
        flex: widget
            .fieldFlex[widget.fieldOrder.indexOf(DateTimePickerField.amPm)],
        child: PickerNavigatorIndicator(
          onBackward: () {
            widget.amPmController.animateToItem(
              0,
              duration: duration,
              curve: curve,
            );
          },
          onForward: () {
            widget.amPmController.animateToItem(
              1,
              duration: duration,
              curve: curve,
            );
          },
          child: ListWheelScrollView(
            controller: widget.amPmController,
            itemExtent: kOneLineTileHeight,
            physics: const FixedExtentScrollPhysics(),
            children: [
              () {
                final selected = localDate.hour < 12;
                return ListTile(
                  onPressed: selected
                      ? null
                      : () {
                          widget.amPmController.animateToItem(
                            0,
                            duration: theme.mediumAnimationDuration,
                            curve: theme.animationCurve,
                          );
                        },
                  title: Center(
                    child: Text(
                      localizations.am,
                      style: kPickerPopupTextStyle(context, selected),
                    ),
                  ),
                );
              }(),
              () {
                final selected = localDate.hour >= 12;
                return ListTile(
                  onPressed: selected
                      ? null
                      : () {
                          widget.amPmController.animateToItem(
                            1,
                            duration: theme.mediumAnimationDuration,
                            curve: theme.animationCurve,
                          );
                        },
                  title: Center(
                    child: Text(
                      localizations.pm,
                      style: kPickerPopupTextStyle(context, selected),
                    ),
                  ),
                );
              }(),
            ],
            onSelectedItemChanged: (index) {
              // setState(() {});
              var hour = localDate.hour;
              final isAm = index == 0;
              if (!widget.use24Format) {
                // If it was previously am and now it's pm
                if (!isAm) {
                  hour += 12;
                  // If it was previously pm and now it's am
                } else if (isAm) {
                  hour -= 12;
                }
              }
              handleDateChanged(DateTime(
                localDate.year,
                localDate.month,
                localDate.day,
                hour,
                localDate.minute,
                localDate.second,
                localDate.millisecond,
                localDate.microsecond,
              ));
            },
          ),
        ),
      ),
    ];

    final fields = <DateTimePickerField, List<Widget>>{
      if (widget.showYear) DateTimePickerField.year: yearWidget,
      if (widget.showMonth) DateTimePickerField.month: monthWidget,
      if (widget.showDay) DateTimePickerField.day: dayWidget,
      if (widget.showHour) DateTimePickerField.hour: hourWidget,
      if (widget.showMinute) DateTimePickerField.minute: minuteWidget,
      if (!widget.use24Format) DateTimePickerField.amPm: ampmWidget,
    };

    final fieldMap = widget.fieldOrder.map((e) => fields[e]);

    return Column(children: [
      Expanded(
        child: Stack(children: [
          PickerHighlightTile(),
          Row(mainAxisSize: MainAxisSize.min, children: [
            ...fieldMap.elementAt(0) ?? [],
            if (fieldMap.length > 1 && fieldMap.elementAt(1) != null) ...[
              divider,
              ...fieldMap.elementAt(1)!,
            ],
            if (fieldMap.length > 2 && fieldMap.elementAt(2) != null) ...[
              divider,
              ...fieldMap.elementAt(2)!,
            ],
            if (fieldMap.length > 3 && fieldMap.elementAt(3) != null) ...[
              divider,
              ...fieldMap.elementAt(3)!,
            ],
            if (fieldMap.length > 4 && fieldMap.elementAt(4) != null) ...[
              divider,
              ...fieldMap.elementAt(4)!,
            ],
            if (fieldMap.length > 5 && fieldMap.elementAt(5) != null) ...[
              divider,
              ...fieldMap.elementAt(5)!,
            ],
          ]),
        ]),
      ),
      const Divider(
        style: DividerThemeData(
          verticalMargin: EdgeInsets.zero,
          horizontalMargin: EdgeInsets.zero,
        ),
      ),
      YesNoPickerControl(
        onChanged: () {
          widget.onChanged(localDate);
          Navigator.pop(context);
        },
        onCancel: () {
          widget.onCancel();
          Navigator.pop(context);
        },
      ),
    ]);
  }
}

/// Get the date order based on the current locale.
///
///
/// ![](https://upload.wikimedia.org/wikipedia/commons/thumb/9/97/Date_format_by_country_NEW.svg/700px-Date_format_by_country_NEW.svg.png)
///
/// DMY is mostly used around the globe, so that's the returned
///
/// See also:
///
///  * <https://en.wikipedia.org/wiki/Date_format_by_country>
List<DateTimePickerField> _getDateOrderFromLocale(Locale? locale) {
  final dmy = [
    DateTimePickerField.day,
    DateTimePickerField.month,
    DateTimePickerField.year,
    DateTimePickerField.hour,
    DateTimePickerField.minute,
    DateTimePickerField.amPm,
  ];
  final ymd = [
    DateTimePickerField.year,
    DateTimePickerField.month,
    DateTimePickerField.day,
    DateTimePickerField.hour,
    DateTimePickerField.minute,
    DateTimePickerField.amPm,
  ];
  final mdy = [
    DateTimePickerField.month,
    DateTimePickerField.day,
    DateTimePickerField.year,
    DateTimePickerField.hour,
    DateTimePickerField.minute,
    DateTimePickerField.amPm,
  ];

  if (locale?.countryCode?.toLowerCase() == 'us') return mdy;

  final lang = locale?.languageCode;

  if (['zh', 'ko', 'jp'].contains(lang)) return ymd;

  return dmy;
}

/// Get the date flex based on the current locale.
/// The flex is used to determine the width of the fields.
List<int> _getDateFlexFromLocale(Locale? locale) {
  final lang = locale?.languageCode;
  if (locale?.countryCode?.toLowerCase() == 'us') {
    return const [2, 1, 1, 1, 1, 1];
  }

  if (['zh', 'ko'].contains(lang)) {
    return const [1, 1, 1, 1, 1, 1];
  }

  return [1, 2, 1, 1, 1, 1];
}
