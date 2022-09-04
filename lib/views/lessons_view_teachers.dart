import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mtkp/database/database_interface.dart';
import 'package:mtkp/models.dart';
import 'package:mtkp/utils/internet_connection_checker.dart';
import 'package:mtkp/widgets/layout.dart';
import 'package:mtkp/widgets/shedule.dart';
import 'package:tuple/tuple.dart';
import 'package:mtkp/main.dart' as app_global;
import 'package:mtkp/workers/caching.dart' as caching;
import 'package:url_launcher/url_launcher.dart';

final testTimetable = Timetable(
    Time('9:00', '10:30'),
    Time('10:50', '12:10'),
    Time('12:40', '14:00'),
    Time('14:30', '16:00'),
    Time('16:10', '17:40'),
    Time('18:00', '19:30'));
final testWeekShedule = WeekShedule(Tuple3(testTimetable, [
  for (var i = 0; i < 6; i++)
    [
      for (var r = i; r < 6; r++)
        PairModel('Предмет', 'Учитель', '11${i.toString()}')
    ]
], [
  for (var i = 0; i < 6; i++)
    [
      for (var r = i; r < 6; r++)
        PairModel('Эбабаба', 'Данаман', '22${i.toString()}')
    ]
]));

class LessonsViewForTeacher extends StatefulWidget {
  final String selectedGroup;
  final bool inSearch;

  final void Function(String classroom) onClassroomTap;

  const LessonsViewForTeacher(
      {Key? key,
      required this.selectedGroup,
      required this.inSearch,
      required this.onClassroomTap})
      : super(key: key);

  @override
  State<LessonsViewForTeacher> createState() => _LessonsViewForTeacherState();
}

class _LessonsViewForTeacherState extends State<LessonsViewForTeacher> {
  PageStorageBucket? storage;

  late int _selectedIndex;
  late int _selectedDay;
  late Month _selectedMonth;
  late int _selectedWeek;
  late DateTime now;

  bool failed = false;

  WeekShedule? _weekShedule;
  List<PairModel?>? dayShedule;
  Timetable _timetable = Timetable.empty();

  @override
  void initState() {
    super.initState();

    storage = PageStorage.of(context)!;

    now = DateTime.now();
    DateTime date;
    if (now.hour > 14 || now.weekday == DateTime.sunday) {
      date = now.add(Duration(days: now.weekday == DateTime.saturday ? 2 : 1));
    } else {
      date = now;
    }
    _selectedIndex = date.weekday - 1;
    _selectedDay = date.day;
    _selectedMonth = Month.all[date.month - 1];
    _selectedWeek = Jiffy(date).week;

    initialization();
  }

  @override
  Widget build(BuildContext context) {
    if (failed) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.sentiment_dissatisfied_rounded,
                  color: app_global.accessColor, size: 74),
              Text(
                'Не получается посмотреть расписание',
                style: app_global.headerFont,
                textAlign: TextAlign.center,
              ),
              Text(
                'Вероятнее всего, замешаны потусторонние силы или особенности парсинга журнала',
                style: app_global.primeFont,
                textAlign: TextAlign.center,
              ),
              ColoredTextButton(
                text: 'Проверить самостоятельно',
                onPressed: () async => await launchUrl(
                    Uri.parse('https://vk.com/mtkp_bmstu'),
                    mode: LaunchMode.externalApplication),
                foregroundColor: Colors.white,
                boxColor: app_global.accessColor,
                splashColor: app_global.accessColor,
                outlined: true,
              ),
            ],
          ),
        ),
      );
    }

    Border border;
    if (_weekShedule == null) {
      border = Border.all(color: app_global.errorColor, width: 2);
    } else {
      border = Border.all(color: app_global.primaryColor, width: 1);

      dayShedule = _selectedWeek % 2 == 1
          ? _weekShedule!.weekLessons.item2[_selectedIndex]
          : _weekShedule!.weekLessons.item3[_selectedIndex];
    }

    late final Widget sheduleContentWidget;

    sheduleContentWidget = SheduleContentWidget(
        dayShedule: Tuple2(_timetable, dayShedule),
        onClassroomTap: widget.onClassroomTap);

    var sheduleWidget = AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          border: border,
          borderRadius: BorderRadius.circular(8),
        ),
        child: _weekShedule == null
            ? const Center(child: CircularProgressIndicator())
            : sheduleContentWidget);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: DatePreview(
                        selectedDay: _selectedDay,
                        selectedMonth: _selectedMonth,
                        replacementSelected: false,
                        selectedWeek: _selectedWeek,
                        datePreviewKey: ValueKey(_selectedDay.toString())),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                      splashRadius: 18,
                      onPressed: () async => await refresh(),
                      icon: Icon(Icons.refresh_rounded,
                          color: Theme.of(context).primaryColorLight)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
              flex: 12,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: sheduleWidget,
              )),
          const SizedBox(height: 10.0),
          FittedBox(
            child: OutlinedRadioGroup(
              startIndex: _selectedIndex,
              startWeek: _selectedWeek,
              callback: (index, day, month, week) => setState(() {
                _selectedIndex = index;
                _selectedDay = day;
                _selectedMonth = month;
                _selectedWeek = week;
              }),
            ),
          )
        ],
      ),
    );
  }

  void initialization() async {
    var state = storage?.readState(context, identifier: widget.key);
    if (state == null || state[0] != widget.selectedGroup) {
      await tryLoadCache();

      await checkInternetConnection(() async {
        await _requestShedule(widget.selectedGroup);
        saveStateToStorage();
      });

      saveStateToStorage();
    } else {
      setState(() {
        _weekShedule = state[1];
        if (_weekShedule == null) {
          failed = true;
          return;
        }

        _timetable = _weekShedule!.weekLessons.item1;
      });
    }
  }

  Future refresh() async {
    setState(() => _weekShedule = null);

    await checkInternetConnection(() async {
      await _requestShedule(widget.selectedGroup);
      saveStateToStorage();
    });
  }

  Future<void> tryLoadCache() async {
    if (app_global.debugMode) {
      setState(() {
        _weekShedule = testWeekShedule;
        _timetable = testTimetable;
      });
      return;
    }

    await caching
        .loadWeekShedule(widget.inSearch ? widget.selectedGroup : '')
        .then((value) {
      if (value != null) {
        setState(() {
          _timetable = value.item2;
          _weekShedule = value.item3;
        });
      }
    });
  }

  Future<void> _requestShedule(String teacher) async {
    try {
      var id = int.parse(RegExp('^([0-9]+)(?=~)').stringMatch(teacher)!);
      var result =
          await DatabaseWorker.currentDatabaseWorker!.getSheduleForTeacher(id);

      if (result.isEmpty) {
        setState(() => failed = true);
        return;
      }

      //upcycle
      var up = <List<PairModel?>>[];
      var down = <List<PairModel?>>[];
      var day = 1;
      bool cf = true;
      var downFlag = false;
      for (var k = 0; k < result.length;) {
        var lessons = <PairModel?>[];
        var r = result[k];

        downFlag = r['down'];
        if (cf && downFlag == true) {
          cf = false;
          day = 1;
          while (up.length < 6) {
            up.add([for (var i = 0; i < 6; i++) null]);
          }
        }
        for (var l = 1; l < 7; l++) {
          if (r['weekday'] == day && r['queue'] == l) {
            lessons.add(PairModel(r['subject'], r['group'], r['room']));
            if (k == result.length - 1) break;
            r = result[++k];
          } else {
            lessons.add(null);
          }
        }
        while (lessons.length < 6) {
          lessons.add(null);
        }
        day++;
        if (downFlag) {
          down.add(lessons);
          if (down.length == 6) break;
        } else {
          up.add(lessons);
        }
      }

      DatabaseWorker.currentDatabaseWorker!.getTimeshedule().then((value) {
        if (value.length == 6) {
          var times = <List<String>>[];
          for (var i = 0; i < 6; i++) {
            times.add(value[i].split('-'));
          }
          _timetable = Timetable(
              Time(times[0][0], times[0][1]),
              Time(times[1][0], times[1][1]),
              Time(times[2][0], times[2][1]),
              Time(times[3][0], times[3][1]),
              Time(times[4][0], times[4][1]),
              Time(times[5][0], times[5][1]));
        }

        if (mounted) {
          setState(() {
            _weekShedule = WeekShedule(Tuple3(_timetable, up, down));
            failed = false;
          });
        }

        saveStateToStorage();

        if (_weekShedule != null) {
          caching.saveWeekshedule(
              widget.selectedGroup, _weekShedule!, widget.inSearch);
        }
      });
    } catch (e) {
      log('Ошибка при парсинге расписания для преподавателей: ' + e.toString());
      setState(() => failed = true);
    }
  }

  void saveStateToStorage() {
    if (mounted) {
      storage!.writeState(
          context,
          [
            widget.selectedGroup,
            _weekShedule,
          ],
          identifier: widget.key);
    }
  }
}
