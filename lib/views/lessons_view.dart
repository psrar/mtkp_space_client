import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mtkp/database/database_interface.dart';
import 'package:mtkp/models.dart';
import 'package:mtkp/utils/domens_utils.dart';
import 'package:mtkp/utils/internet_connection_checker.dart';
import 'package:mtkp/widgets/layout.dart';
import 'package:mtkp/widgets/shedule.dart';
import 'package:tuple/tuple.dart';
import 'package:mtkp/main.dart' as app_global;
import 'package:mtkp/workers/caching.dart' as caching;
import 'package:url_launcher/url_launcher.dart' as url_launcher;

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

class LessonsView extends StatefulWidget {
  final String selectedGroup;
  final bool inSearch;

  final void Function(Map<String, String> _domens) callback;

  final void Function(String classroom) onClassroomTap;

  const LessonsView(
      {Key? key,
      required this.selectedGroup,
      required this.callback,
      required this.inSearch,
      required this.onClassroomTap})
      : super(key: key);

  @override
  State<LessonsView> createState() => _LessonsViewState();
}

class _LessonsViewState extends State<LessonsView> {
  PageStorageBucket? storage;

  late bool _isReplacementSelected = false;
  late int _selectedIndex;
  late int _selectedDay;
  late Month _selectedMonth;
  late int _selectedWeek;
  late DateTime now;

  WeekShedule? _weekShedule;
  List<PairModel?>? dayShedule;
  Timetable _timetable = Timetable.empty();

  Replacements _replacements = Replacements(null);
  Tuple2<SimpleDate, List<PairModel?>?>? _selectedReplacement;
  DateTime? _lastReplacements;
  int _replacementsLoadingState = 0;

  Map<String, String> _domens = {};

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
    Border border;
    if (_weekShedule == null) {
      border = Border.all(color: app_global.errorColor, width: 2);
    } else {
      border = Border.all(
          color: _isReplacementSelected
              ? app_global.focusColor
              : app_global.primaryColor,
          width: 1);

      if (_isReplacementSelected) {
        _selectedReplacement = _replacements
            .getReplacement(SimpleDate(_selectedDay, _selectedMonth));
        dayShedule = _selectedReplacement?.item2;
      } else {
        dayShedule = _selectedWeek % 2 == 1
            ? _weekShedule!.weekLessons.item2[_selectedIndex]
            : _weekShedule!.weekLessons.item3[_selectedIndex];
      }
    }

    late final Widget sheduleContentWidget;
    if (_isReplacementSelected && dayShedule == null) {
      sheduleContentWidget = EmptyReplacements(
          context: context,
          loadingState: _replacementsLoadingState,
          selectedReplacement: _selectedReplacement,
          retryAction: () => checkInternetConnection(() {
                _replacementsLoadingState = 0;
                setState(() => _replacementsLoadingState = 0);
                _requestReplacements(widget.selectedGroup, 2);
              }));
    } else {
      sheduleContentWidget = SheduleContentWidget(
          dayShedule: Tuple2(_timetable, dayShedule),
          onClassroomTap: widget.onClassroomTap);
    }

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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
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
                        replacementSelected: _isReplacementSelected,
                        selectedWeek: _selectedWeek,
                        datePreviewKey: ValueKey(
                            _isReplacementSelected.toString() +
                                _selectedDay.toString())),
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
          const SizedBox(height: 8),
          Expanded(
              flex: 12,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: sheduleWidget,
              )),
          const SizedBox(height: 18),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: ReplacementSelection(
                  sheduleColor: app_global.primaryColor,
                  replacementColor: app_global.focusColor,
                  replacementState: _replacementsLoadingState,
                  isReplacementSelected: _isReplacementSelected,
                  callback: () => setState(
                      () => _isReplacementSelected = !_isReplacementSelected)),
            ),
          ),
          const SizedBox(height: 10),
          FittedBox(
            child: OutlinedRadioGroup(
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
  }

  void initialization() async {
    var state = storage?.readState(context, identifier: widget.key);
    if (state == null || state[0] != widget.selectedGroup) {
      await tryLoadCache();

      await checkInternetConnection(() async {
        await _requestShedule(widget.selectedGroup);
        await _requestReplacements(widget.selectedGroup, 2);
        saveStateToStorage();
      });

      _domens = buildDomensMap(_weekShedule);
      saveStateToStorage();
    } else {
      setState(() {
        _weekShedule = state[1];
        _replacements = state[2];
        _timetable = state[3];
        _replacementsLoadingState = state[4];
        _domens = state[5];
        _isReplacementSelected = state[6];
      });

      if (_replacementsLoadingState == 0) {
        await checkInternetConnection(() async {
          await _requestShedule(widget.selectedGroup);
          await _requestReplacements(widget.selectedGroup, 2);
        });

        _domens = buildDomensMap(_weekShedule);
        saveStateToStorage();
      }
    }

    if (_replacements
            .getReplacement(SimpleDate(_selectedDay, _selectedMonth))
            ?.item2 ==
        null) {
      _isReplacementSelected = false;
    } else {
      _isReplacementSelected = true;
    }
  }

  Future refresh() async {
    if (_isReplacementSelected) {
      setState(() {
        _replacements = Replacements(null);
        _replacementsLoadingState = 0;
      });

      await checkInternetConnection(() async {
        await _requestReplacements(widget.selectedGroup, 2);
        saveStateToStorage();
      });
    } else {
      setState(() {
        _weekShedule = null;
        _replacements = Replacements(null);
      });

      await checkInternetConnection(() async {
        await _requestShedule(widget.selectedGroup);
        await _requestReplacements(widget.selectedGroup, 2);
        saveStateToStorage();
      });
    }
  }

  Future<void> tryLoadCache() async {
    if (app_global.debugMode) {
      _weekShedule = testWeekShedule;
      _replacements = Replacements(null);
      _timetable = testTimetable;
      return;
    }
    if (kIsWeb) return;

    await caching
        .loadWeekSheduleCache(widget.inSearch ? widget.selectedGroup : '')
        .then((value) {
      if (value != null) {
        // widget.selectedGroup = value.item1;
        _timetable = value.item2;
        _weekShedule = value.item3;
      }
    });

    await caching
        .loadReplacementsCache(widget.inSearch ? widget.selectedGroup : '')
        .then((value) {
      if (value == null) return;
      _replacements = value.item2;
      _lastReplacements = value.item1;
      _replacementsLoadingState = 1;
      if (_replacements
              .getReplacement(SimpleDate(_selectedDay, _selectedMonth))
              ?.item2 !=
          null) _isReplacementSelected = true;
    });

    setState(() {});
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
              });
            }

            _domens = buildDomensMap(_weekShedule);
            saveStateToStorage();

            if (_weekShedule != null) {
              caching.saveWeekshedule(
                  widget.selectedGroup, _weekShedule!, widget.inSearch);
            }
          });
        });
      } catch (e) {
        if (!Platform.isLinux) {
          Fluttertoast.showToast(msg: e.toString());
        }
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
          if (mounted) setState(() => _replacementsLoadingState = 2);
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

      if (mounted) {
        setState(() {
          _replacements = Replacements(results);
          _lastReplacements = DateTime.now();
          _replacementsLoadingState = 1;
          if (_replacements
                  .getReplacement(SimpleDate(_selectedDay, _selectedMonth))
                  ?.item2 !=
              null) _isReplacementSelected = true;
        });
      }
      caching.saveReplacements(_replacements, _lastReplacements,
          widget.inSearch ? widget.selectedGroup : '');
    }
  }

  Tuple2<String, String> resolveDomens(String lessonName) {
    if (lessonName.isNotEmpty) {
      String? mdk = RegExp(r'([А-Я]+.\d{1,2}.\d{1,2})').stringMatch(lessonName);
      String match = _domens.keys.firstWhere(
          (element) =>
              (mdk != null && element.contains(mdk)) || element == lessonName,
          orElse: (() => ''));

      if (match.isNotEmpty) {
        if (lessonName == match || lessonName.length < match.length) {
          return Tuple2(match, _domens[match]!);
        }
      }
    }
    return Tuple2(lessonName, '');
  }

  void callback() => widget.callback(_domens);

  void saveStateToStorage() {
    if (mounted) {
      storage!.writeState(
          context,
          [
            widget.selectedGroup,
            _weekShedule,
            _replacements,
            _timetable,
            _replacementsLoadingState,
            _domens,
            _isReplacementSelected
          ],
          identifier: widget.key);
    }
    callback();
  }
}

class EmptyReplacements extends StatelessWidget {
  final BuildContext context;
  final int loadingState;
  final Tuple2<SimpleDate, List<PairModel?>?>? selectedReplacement;
  final Function retryAction;
  const EmptyReplacements(
      {Key? key,
      required this.context,
      required this.loadingState,
      required this.selectedReplacement,
      required this.retryAction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        loadingState == 0 && selectedReplacement == null
            ? Column(children: [
                Text(
                  'Мы загружаем ваши замены',
                  style: app_global.headerFont,
                  textAlign: TextAlign.center,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8.0),
                  child: LinearProgressIndicator(),
                ),
              ])
            : Text(
                loadingState == 2
                    ? 'Не удалось получить замены'
                    : selectedReplacement == null
                        ? 'Замен на этот день не обнаружено'
                        : 'Для вашей группы нет замен на этот день',
                style: app_global.headerFont,
                textAlign: TextAlign.center,
              ),
        const SizedBox(height: 12),
        Column(
          children: [
            ColoredTextButton(
              text: 'Проверить самостоятельно',
              onPressed: () async =>
                  await url_launcher.launch('https://vk.com/mtkp_bmstu'),
              foregroundColor: Colors.white,
              boxColor: app_global.errorColor,
              splashColor: app_global.errorColor,
              outlined: true,
            ),
            const SizedBox(height: 12),
            ColoredTextButton(
              text: 'Попробовать снова',
              onPressed: retryAction,
              foregroundColor: Colors.white,
              boxColor: app_global.focusColor,
              splashColor: app_global.focusColor,
              outlined: true,
            ),
          ],
        )
      ],
    ));
  }
}
