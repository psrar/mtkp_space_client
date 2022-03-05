import 'dart:developer';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:mtkp/workers/caching.dart' as caching;
import 'package:mtkp/database/database_interface.dart';
import 'package:mtkp/views.dart/domens_view.dart';
import 'package:mtkp/models.dart';
import 'package:mtkp/utils/internet_connection_checker.dart';
import 'package:mtkp/widgets/layout.dart' as layout;
import 'package:mtkp/widgets/shedule.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import '../main.dart' as appGlobal;

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
const debug = false;

class OverviewPage extends StatefulWidget {
  const OverviewPage({Key? key}) : super(key: key);

  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  Key? datePreviewKey;

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

  Replacements _replacements = Replacements(null);
  Tuple2<SimpleDate, List<PairModel?>?>? _selectedReplacement;
  DateTime? _lastReplacements;
  int _replacementsLoadingState = 0;

  int _selectedView = 0;
  final _views = <Widget>[Container(), Container()];
  bool appbarAnimationDirection = false;

  Map<String, String> lessons = {};

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
      border = Border.all(color: Theme.of(context).errorColor, width: 2);
    } else {
      _views[1] = DomensView(existingPairs: lessons);

      border = Border.all(
          color: _isReplacementSelected
              ? appGlobal.focusColor
              : appGlobal.primaryColor,
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
      sheduleContentWidget = EmptyReplacements(
          context: context,
          loadingState: _replacementsLoadingState,
          selectedReplacement: _selectedReplacement,
          retryAction: () => checkInternetConnection(context, () {
                _replacementsLoadingState = 0;
                setState(() => _replacementsLoadingState = 0);
                _requestReplacements(_selectedGroup, 2);
              }));
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
          checkInternetConnection(context, () {
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
              checkInternetConnection(context, () async {
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
        ? EmptyWelcome(
            loading: entryOptions.isEmpty && _selectedGroup == 'Группа')
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: DatePreview(
                        key: ValueKey(_selectedView),
                        selectedDay: _selectedDay,
                        selectedMonth: _selectedMonth,
                        replacementSelected: _isReplacementSelected,
                        selectedWeek: _selectedWeek,
                        datePreviewKey: datePreviewKey),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                    flex: 12,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: sheduleWidget,
                    )),
                const SizedBox(height: 18),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: ReplacementSelection(
                        sheduleColor: appGlobal.primaryColor,
                        replacementColor: appGlobal.focusColor,
                        replacementState: _replacementsLoadingState,
                        isReplacementSelected: _isReplacementSelected,
                        callback: () => setState(() {
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
                      if (day != _selectedDay) datePreviewKey = ValueKey(day);
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
          title: layout.SharedAxisSwitcher(
              reverse: appbarAnimationDirection,
              transitionType: SharedAxisTransitionType.horizontal,
              child: _selectedView == 0
                  ? layout.SharedAxisSwitcher(
                      key: ValueKey(appbarAnimationDirection),
                      reverse: !_isReplacementSelected,
                      child: Row(
                        key: ValueKey(_isReplacementSelected),
                        children: [
                          Expanded(
                            child: _isReplacementSelected
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const Text('Замены'),
                                      Text(
                                        _lastReplacements == null
                                            ? 'Данные о заменах устарели'
                                            : 'Обновлено ' +
                                                SimpleDate.fromDateTime(
                                                        _lastReplacements!)
                                                    .toSpeech() +
                                                ' в ${_lastReplacements!.hour.toString().padLeft(2, '0')}:${_lastReplacements!.minute.toString().padLeft(2, '0')}',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ],
                                  )
                                : const Text('Расписание'),
                          ),
                        ],
                      ),
                    )
                  : Row(
                      children: [
                        Text('Предметы'),
                      ],
                    )),
          actions: [_updateAction, _groupSelectorAction],
        ),
        bottomNavigationBar: NavigationBar(
            animationDuration: const Duration(milliseconds: 400),
            selectedIndex: _selectedView,
            onDestinationSelected: (index) => setState(() {
                  appbarAnimationDirection = index < _selectedView;
                  _selectedView = index;
                }),
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.view_day_rounded, color: Colors.grey),
                  selectedIcon:
                      Icon(Icons.view_day_rounded, color: Colors.white),
                  label: 'Расписание'),
              NavigationDestination(
                  icon: Icon(Icons.school_rounded, color: Colors.grey),
                  selectedIcon: Icon(Icons.school_rounded, color: Colors.white),
                  label: 'Преподаватели и предметы'),
              NavigationDestination(
                  icon: Icon(Icons.settings_rounded, color: Colors.grey),
                  selectedIcon:
                      Icon(Icons.settings_rounded, color: Colors.white),
                  label: 'Настройки'),
            ]),
        body: layout.SharedAxisSwitcher(
          reverse: appbarAnimationDirection,
          transitionType: SharedAxisTransitionType.horizontal,
          child: _views[_selectedView],
        ));
  }

  void initialization() async {
    if (!debug) {
      await tryLoadCache();

      await checkInternetConnection(context, () async {
        await _requestGroups();
        await _requestReplacements(_selectedGroup, 2);
      });
    } else {
      weekShedule = testWeekShedule;
      timetable = testTimetable;
      _selectedGroup = 'Тест';
    }

    buildDomensMap(weekShedule);
  }

  Future<void> tryLoadCache() async {
    if (kIsWeb || !Platform.isAndroid) return;

    await caching.loadWeekSheduleCache().then((value) {
      if (value != null) {
        setState(() {
          _selectedGroup = value.item1;
          timetable = value.item2;
          weekShedule = value.item3;
        });
      }
    });

    await caching.loadReplacementsCache().then((value) {
      if (value == null) return;
      setState(() {
        _replacements = value.item2;
        _lastReplacements = value.item1;
        _replacementsLoadingState = 1;
        if (_replacements
                .getReplacement(SimpleDate(_selectedDay, _selectedMonth))
                ?.item2 !=
            null) _isReplacementSelected = true;
      });
    });
  }

  Future<void> _requestGroups() async {
    try {
      await DatabaseWorker.currentDatabaseWorker!
          .getAllGroups()
          .then((value) => setState(() => entryOptions = value));
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
            setState(() {
              weekShedule = WeekShedule(Tuple3(timetable, up, down));
              buildDomensMap(weekShedule);
            });

            if (weekShedule != null) {
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
    _replacementsLoadingState = 0;
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
          setState(() => _replacementsLoadingState = 2);
          // layout.showTextSnackBar(
          //     context,
          //     'Не удалось получить замены. Узнайте их вручную.\n' + res.item1!,
          //     6000);
        } else if (res.item2 != null) {
          for (var pairs in res.item2!.values) {
            if (pairs != null) {
              for (var pair in pairs) {
                if (pair != null) {
                  var resolving = resolveDomens(pair.name);
                  pair.name = resolving.item1;
                  pair.teacherName = resolving.item2;
                }
              }
            }
          }
          results.addAll(res.item2!);
        }
      }

      setState(() {
        _replacements = Replacements(results);
        _lastReplacements = DateTime.now();
        _replacementsLoadingState = 1;
        if (_replacements
                .getReplacement(SimpleDate(_selectedDay, _selectedMonth))
                ?.item2 !=
            null) {
          _isReplacementSelected = true;
        }
      });
      caching.saveReplacements(_replacements, _lastReplacements);
    }
  }

  void buildDomensMap(WeekShedule? inputShedule) {
    if (inputShedule != null) {
      var result = <String, String>{};
      var pairs =
          inputShedule.weekLessons.item2 + inputShedule.weekLessons.item3;
      for (var element in pairs) {
        for (var pair in element) {
          if (pair != null) {
            String? mdk =
                RegExp(r'([А-Я]+.\d{1,2}.\d{1,2})').stringMatch(pair.name);
            if (mdk != null) {
              String match = result.keys.firstWhere(
                  (element) => element.contains(mdk),
                  orElse: (() => ''));
              if (match.isNotEmpty) {
                if (match.length < pair.name.length) {
                  result.remove(match);
                  result[pair.name] = pair.teacherReadable;
                }
              } else {
                result[pair.name] = pair.teacherReadable;
              }
            } else {
              result[pair.name] = pair.teacherReadable;
            }
          }
        }
      }

      lessons = result;
    }
  }

  Tuple2<String, String> resolveDomens(String lessonName) {
    if (lessonName.isNotEmpty) {
      String? mdk = RegExp(r'([А-Я]+.\d{1,2}.\d{1,2})').stringMatch(lessonName);
      String match = lessons.keys.firstWhere(
          (element) =>
              (mdk != null && element.contains(mdk)) || element == lessonName,
          orElse: (() => ''));

      if (match.isNotEmpty) {
        if (lessonName == match || lessonName.length < match.length) {
          return Tuple2(match, lessons[match]!);
        }
      }
    }
    return Tuple2(lessonName, '');
  }
}
