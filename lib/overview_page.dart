import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:diary/caching.dart' as caching;
import 'package:diary/database/database_interface.dart';
import 'package:diary/domens_view.dart';
import 'package:diary/models.dart';
import 'package:diary/widgets/layout.dart' as layout;
import 'package:diary/widgets/shedule.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

part 'overview_page_widgets.dart';

final Timetable timetableEmpty = Timetable(Time('', ''), Time('', ''),
    Time('', ''), Time('', ''), Time('', ''), Time('', ''));

final testTimetable = Timetable(
    Time('9:00', '10:30'),
    Time('10:50', '12:10'),
    Time('12:40', '14:00'),
    Time('14:30', '16:00'),
    Time('16:10', '17:40'),
    Time('00:00', '99:99'));
final testWeekShedule = WeekShedule(Tuple3(testTimetable, [
  for (var i = 0; i < 6; i++)
    [
      for (var i = 0; i < 6; i++)
        PairModel('Предмет', 'Учитель', '11${i.toString()}')
    ]
], [
  for (var i = 0; i < 6; i++)
    [
      for (var i = 0; i < 6; i++)
        PairModel('Предмет', 'Учитель', '22${i.toString()}')
    ]
]));
const debug = true;

class OverviewPage extends StatefulWidget {
  const OverviewPage({Key? key}) : super(key: key);

  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  late bool _isReplacementSelected = false;
  late int _selectedIndex;
  late int _selectedDay;
  late Month _selectedMonth;
  late int _selectedWeek;
  String _selectedGroup = 'Группа';
  late DateTime now;

  List<String> entryOptions = [];

  WeekShedule? weekShedule;
  List<PairModel?>? dayShedule;
  Timetable timetable = timetableEmpty;

  var _replacements = Replacements(null);
  Tuple2<SimpleDate, List<PairModel?>?>? _selectedReplacement;
  DateTime? _lastReplacements;

  int _selectedView = 0;
  final _views = <Widget>[Container(), Container()];

  @override
  void initState() {
    super.initState();
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
    Border border;
    if (weekShedule == null) {
      border = Border.all(color: Colors.red, width: 2);
    } else {
      _views[1] =
          DomensView(existingPairs: weeksheduleToExistingPairs(weekShedule!));

      border = Border.all(
          color: _isReplacementSelected
              ? Colors.orange
              : Theme.of(context).primaryColorLight,
          width: 1);

      if (_isReplacementSelected) {
        _selectedReplacement = _replacements
            .getReplacement(SimpleDate(_selectedDay, _selectedMonth));
        dayShedule = _selectedReplacement?.item2;
      } else {
        dayShedule = _selectedWeek % 2 == 1
            ? weekShedule!.weekLessons.item2[_selectedIndex]
            : weekShedule!.weekLessons.item3[_selectedIndex];
      }
    }

    late final Widget sheduleContentWidget;
    if (_isReplacementSelected && dayShedule == null) {
      sheduleContentWidget = buildEmptyReplacements(
          context,
          _lastReplacements,
          _selectedReplacement,
          () => layout.checkInternetConnection(
              context, () => _requestReplacements(_selectedGroup, 2)));
    } else {
      sheduleContentWidget =
          SheduleContentWidget(dayShedule: Tuple2(timetable, dayShedule));
    }

    var sheduleWidget = AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          border: border,
          borderRadius: BorderRadius.circular(8),
        ),
        child: weekShedule == null
            ? const Center(child: CircularProgressIndicator())
            : sheduleContentWidget);

    final _updateAction = IconButton(
        splashRadius: 18,
        onPressed: () async {
          layout.checkInternetConnection(context, () {
            setState(() {
              weekShedule = null;
              _replacements = Replacements(null);
            });
            Future.wait([
              _requestShedule(_selectedGroup),
              _requestReplacements(_selectedGroup, 2),
              _requestGroups()
            ]).whenComplete(() => setState(() {}));
          });
        },
        icon: Icon(
          Icons.refresh_rounded,
          color: Theme.of(context).primaryColorLight,
        ));

    final _groupSelectorAction = Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          layout.GroupSelector(
            selectedGroup: _selectedGroup,
            options: entryOptions,
            callback: (value) {
              layout.checkInternetConnection(context, () async {
                setState(() {
                  weekShedule = null;
                  _replacements = Replacements(null);
                  _selectedGroup = value;
                });
                await Future.wait([
                  _requestShedule(_selectedGroup),
                  _requestReplacements(_selectedGroup, 2)
                ]).whenComplete(() => setState(() {}));
              });
            },
          ),
        ],
      ),
    );
// const EdgeInsets.symmetric(horizontal: 18, vertical: 8)
    _views[0] = _selectedGroup == 'Группа'
        ? buildEmptyWelcome(entryOptions.isEmpty && _selectedGroup == 'Группа')
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: buildDatePreview(_selectedDay, _selectedMonth,
                        _isReplacementSelected, _selectedWeek),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                    flex: 12,
                    child: PageView.builder(
                      scrollBehavior: layout.ScrollBehavior(),
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: sheduleWidget,
                      ),
                      itemCount: 10,
                    )),
                const SizedBox(height: 18),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: buildReplacementSelectiong(
                        Theme.of(context).primaryColorLight,
                        Colors.orange,
                        _isReplacementSelected,
                        () => setState(() {
                              _isReplacementSelected = !_isReplacementSelected;
                            })),
                  ),
                ),
                const SizedBox(height: 10),
                FittedBox(
                  child: layout.OutlinedRadioGroup(
                    startIndex: _selectedIndex,
                    startWeek: _selectedWeek,
                    callback: (index, day, month, week) => setState(() {
                      _selectedIndex = index;
                      _selectedDay = day;
                      _selectedMonth = month;
                      _selectedWeek = week;
                      if (_replacements
                              .getReplacement(
                                  SimpleDate(_selectedDay, _selectedMonth))
                              ?.item2 ==
                          null) {
                        _isReplacementSelected = false;
                      } else {
                        _isReplacementSelected = true;
                      }
                    }),
                  ),
                )
              ],
            ),
          );

    return Scaffold(
        appBar: AppBar(
          title: const Text('Расписание',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
          actions: [_updateAction, _groupSelectorAction],
        ),
        bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedView,
            onDestinationSelected: (index) =>
                setState(() => _selectedView = index),
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.view_day_rounded),
                  selectedIcon:
                      Icon(Icons.view_day_rounded, color: Colors.white),
                  label: 'Расписание'),
              NavigationDestination(
                  icon: Icon(Icons.school_rounded),
                  selectedIcon: Icon(Icons.school_rounded, color: Colors.white),
                  label: 'Преподаватели и предметы'),
            ]),
        body: _views[_selectedView]);
  }

  void initialization() async {
    if (!debug) {
      await tryLoadCache();

      await layout.checkInternetConnection(context, () async {
        await _requestGroups();
        await _requestReplacements(_selectedGroup, 2);
      });
    } else {
      weekShedule = testWeekShedule;
      timetable = testTimetable;
      _selectedGroup = 'Тест';
    }
  }

  Future<void> tryLoadCache() async {
    if (!kIsWeb) {
      await caching.loadWeekShedule().then((value) {
        if (value != null) {
          setState(() {
            _selectedGroup = value.item1;
            timetable = value.item2;
            weekShedule = value.item3;
          });
        }
      });
    }
  }

  Future<void> _requestGroups() async {
    try {
      await DatabaseWorker.currentDatabaseWorker!
          .getAllGroups()
          .then((value) => entryOptions = value);
    } catch (e) {
      layout.showTextSnackBar(
          context, 'Не удаётся загрузить данные о группах.', 2000);
    }
  }

  Future<void> _requestShedule(String group) async {
    if (group != 'Группа') {
      try {
        await DatabaseWorker.currentDatabaseWorker!
            .getShedule(group)
            .then((value) {
          var up = <List<PairModel?>>[];
          var down = <List<PairModel?>>[];
          for (var day = 0; day < 6; day++) {
            var lessons = <PairModel?>[];
            for (var lesson = 0; lesson < 6; lesson++) {
              var val = value[lesson + day * 6];
              if (val.item1 == null) {
                lessons.add(null);
              } else {
                lessons.add(PairModel(val.item1!, val.item2, val.item3));
              }
            }
            up.add(lessons);
          }

          for (var day = 6; day < 12; day++) {
            var lessons = <PairModel?>[];
            for (var lesson = 0; lesson < 6; lesson++) {
              var val = value[lesson + day * 6];
              if (val.item1 == null) {
                lessons.add(null);
              } else {
                lessons.add(PairModel(val.item1!, val.item2, val.item3));
              }
            }
            down.add(lessons);
          }

          DatabaseWorker.currentDatabaseWorker!.getTimeshedule().then((value) {
            if (value.length == 6) {
              var times = <List<String>>[];
              for (var i = 0; i < 6; i++) {
                times.add(value[i].split('-'));
              }
              timetable = Timetable(
                  Time(times[0][0], times[0][1]),
                  Time(times[1][0], times[1][1]),
                  Time(times[2][0], times[2][1]),
                  Time(times[3][0], times[3][1]),
                  Time(times[4][0], times[4][1]),
                  Time(times[5][0], times[5][1]));
            }
            setState(
                () => weekShedule = WeekShedule(Tuple3(timetable, up, down)));

            if (weekShedule != null && !kIsWeb) {
              caching.saveWeekshedule(_selectedGroup, weekShedule!);
            }
          });
        });
      } catch (e) {
        log(e.toString());
      }
    }
  }

  Future<void> _requestReplacements(String group, int rangeFromToday) async {
    setState(() => _lastReplacements = DateTime(0));
    var dates = [
      for (var i = 1; i <= rangeFromToday; i++) now.subtract(Duration(days: i)),
      now,
      now.add(const Duration(days: 1))
    ];
    if (group != 'Группа') {
      Map<SimpleDate, List<PairModel?>?>? results = {};
      var nextDay = SimpleDate.fromDateTime(now.add(const Duration(days: 1)));
      for (var element in dates) {
        var date = SimpleDate.fromDateTime(element);
        var res = await DatabaseWorker.currentDatabaseWorker!
            .getReplacements(date, group);
        if ((date.isToday || date == nextDay) &&
            res.item1 != null &&
            res.item1 != '') {
          setState(() => _lastReplacements = null);
          layout.showTextSnackBar(
              context,
              'Не удалось получить замены. Узнайте их вручную.\n' + res.item1!,
              6000);
        } else if (res.item2 != null) {
          results.addAll(res.item2!);
        }
      }

      setState(() {
        _replacements = Replacements(results);
        _lastReplacements = DateTime.now();
        if (_replacements
                .getReplacement(SimpleDate(_selectedDay, _selectedMonth))
                ?.item2 !=
            null) {
          _isReplacementSelected = true;
        }
      });
    }
  }

  Map<String, String> weeksheduleToExistingPairs(WeekShedule inputShedule) {
    var result = <String, String>{};
    for (var element in inputShedule.weekLessons.item2) {
      for (var pair in element) {
        if (pair != null) {
          result[pair.name] = pair.teacherReadable;
        }
      }
    }
    for (var element in inputShedule.weekLessons.item3) {
      for (var pair in element) {
        if (pair != null) {
          result[pair.name] = pair.teacherReadable;
        }
      }
    }

    return result;
  }
}
