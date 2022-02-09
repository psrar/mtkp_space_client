import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:diary/caching.dart' as caching;
import 'package:diary/database/database_interface.dart';
import 'package:diary/models.dart';
import 'package:diary/widgets/layout.dart' as layout;
import 'package:diary/widgets/shedule.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

final Timetable timetableEmpty = Timetable(Time('', ''), Time('', ''),
    Time('', ''), Time('', ''), Time('', ''), Time('', ''));

class OverviewPage extends StatefulWidget {
  const OverviewPage({Key? key}) : super(key: key);

  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  late bool _replacementSelected = false;
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

  @override
  void initState() {
    super.initState();
    now = DateTime.now();
    DateTime date;
    if (now.hour > 14 || now.weekday == DateTime.sunday) {
      date = now.add(const Duration(days: 1));
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
      border = Border.all(
          color: _replacementSelected
              ? Colors.orange
              : Theme.of(context).primaryColorLight,
          width: 1);

      if (_replacementSelected) {
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
    if (_replacementSelected && dayShedule == null) {
      sheduleContentWidget = Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _lastReplacements == DateTime(0)
              ? Column(children: const [
                  Text('Мы загружаем ваши замены'),
                  SizedBox(height: 8),
                  CircularProgressIndicator(),
                  SizedBox(height: 8)
                ])
              : Text(
                  _lastReplacements == null
                      ? 'Не удалось получить замены'
                      : _selectedReplacement == null
                          ? 'Замен на этот день не обнаружено'
                          : 'Для вашей группы нет замен на этот день',
                  style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          layout.ColoredTextButton(
            text: 'Проверить самостоятельно',
            onPressed: () async =>
                await url_launcher.launch('https://vk.com/mtkp_bmstu'),
            foregroundColor: Colors.black87,
            boxColor: Colors.red,
            splashColor: Colors.red,
            outlined: true,
          ),
          const SizedBox(height: 12),
          layout.ColoredTextButton(
            text: 'Попробовать снова',
            onPressed: () => layout.checkInternetConnection(
                context, () => _requestReplacements(_selectedGroup, 2)),
            foregroundColor: Colors.black87,
            boxColor: Colors.orange,
            splashColor: Colors.orange,
            outlined: true,
          ),
        ],
      ));
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Расписание',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
        ),
        actions: [_updateAction, _groupSelectorAction],
      ),
      body: _selectedGroup == 'Группа'
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                  child: Text(
                entryOptions.isEmpty && _selectedGroup == 'Группа'
                    ? 'Загружается список групп...'
                    : 'Выберите группу, чтобы посмотреть её расписание',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              )),
            )
          : Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(flex: 12, child: sheduleWidget),
                  const SizedBox(
                    height: 4,
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: layout.SlideTransitionDraft(
                              child: AutoSizeText(
                                '$_selectedDay, ${_selectedMonth.name}' +
                                    (_replacementSelected ? ', Замены' : ''),
                                key: ValueKey(
                                    [_selectedDay, _replacementSelected]),
                                textAlign: TextAlign.center,
                                minFontSize: 8,
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            color: Colors.black12,
                          ),
                          Expanded(
                            child: layout.SlideTransitionDraft(
                              child: AutoSizeText(
                                _selectedWeek % 2 == 0
                                    ? 'Нижняя неделя'
                                    : 'Верхняя неделя',
                                key: ValueKey(_selectedWeek),
                                textAlign: TextAlign.center,
                                minFontSize: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            constraints: const BoxConstraints.expand(),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: _replacementSelected
                                      ? Colors.orange
                                      : Theme.of(context).primaryColorLight),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: InkWell(
                                onTap: () => setState(() {
                                      _replacementSelected =
                                          !_replacementSelected;
                                    }),
                                borderRadius: BorderRadius.circular(6),
                                child: layout.SlideTransitionDraft(
                                  child: AutoSizeText(
                                    _replacementSelected
                                        ? 'Смотреть расписание'
                                        : 'Смотреть замены',
                                    key: ValueKey(_replacementSelected),
                                    minFontSize: 8,
                                  ),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  FittedBox(
                    child: layout.OutlinedRadioGroup(
                      startIndex: _selectedIndex,
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
                          _replacementSelected = false;
                        } else {
                          _replacementSelected = true;
                        }
                      }),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  void initialization() async {
    await tryLoadCache();

    await layout.checkInternetConnection(context, () async {
      await _requestGroups();
      await _requestReplacements(_selectedGroup, 2);
    });
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
          _replacementSelected = true;
        }
      });
    }
  }
}
