import 'dart:io';

import 'package:animations/animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mtkp/settings_model.dart';
import 'package:mtkp/utils/internet_connection_checker.dart';
import 'package:mtkp/views/navigator_view.dart';
import 'package:mtkp/views/search_view/search_view.dart';
import 'package:mtkp/views/settings_view.dart';
import 'package:mtkp/database/database_interface.dart';
import 'package:mtkp/views/domens_view.dart';
import 'package:mtkp/models.dart';
import 'package:mtkp/views/lessons_view.dart';
import 'package:mtkp/widgets/layout.dart' as layout;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mtkp/workers/caching.dart';
import 'package:mtkp/workers/file_worker.dart';
import 'package:mtkp/main.dart' as app_global;
import 'package:tuple/tuple.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({Key? key}) : super(key: key);

  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  final PageStorageBucket _bucket = PageStorageBucket();

  int _selectedView = 1;
  late List<Widget> _views;
  bool appbarAnimationDirection = false;

  String _selectedGroup = 'Группа';
  List<String> entryOptions = [];
  bool needUpdateTrigger = false;

  late bool _isReplacementSelected = false;
  DateTime? _lastReplacements;
  Map<String, String> _domens = {};

  bool _inSearchShedule = false;
  String _searchOption = '';

  List<String> cachedPinnedGroups = [];
  List<Tuple2<int, String>> cachedPinnedTeachers = [];

  String _searchedClassroom = '';

  @override
  void initState() {
    super.initState();

    _tryLoadCache();
    _requestGroups();

    _views = List<Widget>.filled(5, Container(color: Colors.pinkAccent));
  }

  @override
  Widget build(BuildContext context) {
    var lessonsKey = const PageStorageKey("Lessons");

    _views[0] = SearchView(
        key: const PageStorageKey("Search"),
        pinnedGroups: cachedPinnedGroups,
        pinnedTeachers: cachedPinnedTeachers,
        option: _searchOption,
        onClassroomTap: (c) => handleClassroomTap(c),
        callback: (newSearchOption) => setState(() {
              _searchOption = newSearchOption;
              _inSearchShedule = _searchOption.isNotEmpty;
            }));

    _views[1] = NavigatorView(
      key: const PageStorageKey("Navigator"),
      previousOrSingleClassroom: _searchedClassroom,
    );

    _views[3] = _selectedGroup == 'Группа'
        ? EmptyWelcome(
            loading: entryOptions.isEmpty && _selectedGroup == 'Группа')
        : DomensView(existingPairs: _domens);
    _views[4] = _selectedGroup == 'Группа'
        ? EmptyWelcome(
            loading: entryOptions.isEmpty && _selectedGroup == 'Группа')
        : const SettingsView();

    final _updateAction = IconButton(
        splashRadius: 18,
        onPressed: () async {
          setState(() {
            needUpdateTrigger = true;
            _searchedClassroom = '';
          });
          if (_selectedGroup == 'Группа') await _requestGroups();
        },
        icon: Icon(
          Icons.refresh_rounded,
          color: Theme.of(context).primaryColorLight,
        ));

    final _groupSelectorAction = Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, right: 16),
      child: layout.GroupSelector(
        selectedGroup: _selectedGroup,
        options: entryOptions,
        callback: (value) async {
          setState(() {
            _searchedClassroom = '';
            if (_selectedGroup != value) {
              _selectedGroup = value;
              needUpdateTrigger = true;
              _selectedView = 2;
            }
          });

          if (!kIsWeb) {
            await clearMessageStamp();
            await saveSubscriptionToGroup(_selectedGroup);
          }
        },
      ),
    );

    _views[2] = _selectedGroup == 'Группа'
        ? EmptyWelcome(
            loading: entryOptions.isEmpty && _selectedGroup == 'Группа')
        : LessonsView(
            key: lessonsKey,
            selectedGroup: _selectedGroup,
            forTeacher: false,
            dirty: needUpdateTrigger,
            inSearch: false,
            callback: (bool isReplacementSelected, DateTime? lastReplacements,
                Map<String, String> domens) {
              setState(() {
                _isReplacementSelected = isReplacementSelected;
                _lastReplacements = lastReplacements;
                _domens = domens;
              });
            },
            onClassroomTap: (classroom) => handleClassroomTap(classroom));

    needUpdateTrigger = false;

    late Widget title;
    switch (_selectedView) {
      case 0:
        title = layout.SharedAxisSwitcher(
          reverse: _searchOption.isEmpty,
          duration: const Duration(milliseconds: 600),
          child: Row(key: ValueKey(_searchOption), children: [
            _searchOption.isEmpty
                ? const Text('Поиск')
                : Text(_searchOption.split('~').last)
          ]),
        );
        break;
      case 1:
        title = Row(children: const [Text('Навигация')]);
        break;
      case 2:
        title = layout.SharedAxisSwitcher(
          reverse: !_isReplacementSelected,
          child: Row(
            key: ValueKey(_isReplacementSelected),
            children: [
              Expanded(
                child: _isReplacementSelected
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Замены'),
                          Text(
                            _lastReplacements == null
                                ? 'Данные о заменах устарели'
                                : 'Обновлено ' +
                                    SimpleDate.fromDateTime(_lastReplacements!)
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
        );
        break;
      case 3:
        title = Row(children: const [Text('Предметы')]);
        break;
      case 4:
        title = Row(children: const [Text('Настройки')]);
        break;
      default:
        title = Container(color: Colors.purpleAccent);
    }

    return Scaffold(
        appBar: AppBar(
          title: layout.SharedAxisSwitcher(
              reverse: appbarAnimationDirection,
              transitionType: SharedAxisTransitionType.horizontal,
              child: Container(key: ValueKey(_selectedView), child: title)),
          actions: [_updateAction, _groupSelectorAction],
        ),
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedView,
            onTap: (index) => setState(() {
                  _searchedClassroom = '';
                  if (_inSearchShedule && index == 0 && _selectedView == 0) {
                    _inSearchShedule = false;
                    _searchOption = '';
                  }

                  appbarAnimationDirection = _selectedView > index;
                  _selectedView = index;
                }),
            items: [
              BottomNavigationBarItem(
                  icon: layout.SharedAxisSwitcher(
                    reverse: _inSearchShedule,
                    duration: const Duration(milliseconds: 600),
                    child: _inSearchShedule
                        ? Icon(Icons.arrow_downward_rounded,
                            color: app_global.focusColor,
                            key: ValueKey(_inSearchShedule))
                        : Icon(Icons.search_rounded,
                            key: ValueKey(_inSearchShedule)),
                  ),
                  label: 'Поиск'),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.pin_drop_rounded), label: 'Навигация'),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.view_day_rounded), label: 'Расписание'),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.school_rounded), label: 'Предметы'),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.settings_rounded), label: 'Настройки'),
            ]),
        body: PageStorage(
          bucket: _bucket,
          child: layout.SharedAxisSwitcher(
            reverse: appbarAnimationDirection,
            duration: const Duration(milliseconds: 600),
            transitionType: SharedAxisTransitionType.horizontal,
            child: _views[_selectedView],
          ),
        ));
  }

  void handleClassroomTap(String classroom) {
    if (classrooms[classroom] != null) {
      setState(() {
        _searchedClassroom = classroom;
        appbarAnimationDirection = true;
        _selectedView = 1;
      });
    } else {
      if (!kIsWeb && Platform.isLinux) return;
      Fluttertoast.showToast(
          msg: 'Невозможно узнать кабинет или он не находится в техникуме :(');
    }
  }

  Future<void> _tryLoadCache() async {
    if (app_global.debugMode) {
      setState(() {
        _selectedGroup = 'Тест';
        cachedPinnedGroups = ['ТИП-00', 'ХУу-666'];
      });
      return;
    }

    if (kIsWeb) return;

    var gr = (await loadWeekSheduleCache())?.item1 ?? 'Группа';
    var pg = await loadPinnedGroups();
    var te = await loadPinnedTeachers();

    setState(() {
      _selectedGroup = gr;
      cachedPinnedGroups = pg;
      cachedPinnedTeachers = te;
    });
  }

  Future<void> _requestGroups() async {
    try {
      await checkInternetConnection(() async {
        await DatabaseWorker.currentDatabaseWorker!
            .getAllGroups()
            .then((value) => setState(() => entryOptions = value));
      });
    } catch (e) {
      layout.showTextSnackBar(
          context,
          'Не удаётся загрузить данные о группах. Нажмите кнопку обновления.',
          2000);
    }
  }
}

class EmptyWelcome extends StatelessWidget {
  final bool loading;
  const EmptyWelcome({Key? key, required this.loading}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Center(
          child: Text(
        loading
            ? 'Загружается список групп...'
            : 'Выберите группу, чтобы посмотреть её расписание',
        style: app_global.headerFont,
        textAlign: TextAlign.center,
      )),
    );
  }
}
