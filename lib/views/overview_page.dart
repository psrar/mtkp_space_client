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
  final lessonsKey = const PageStorageKey("Lessons");

  int _selectedView = 2;
  late List<Widget> _views;
  bool appbarAnimationDirection = false;

  String _selectedGroup = 'Группа';
  List<String> entryOptions = [];

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
            loading: entryOptions.isEmpty && _selectedGroup == 'Группа',
            retryAction: () async => await _requestGroups())
        : DomensView(existingPairs: _domens);
    _views[4] = _selectedGroup == 'Группа'
        ? EmptyWelcome(
            loading: entryOptions.isEmpty && _selectedGroup == 'Группа',
            retryAction: () async => await _requestGroups())
        : const SettingsView();

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
            loading: entryOptions.isEmpty && _selectedGroup == 'Группа',
            retryAction: () async => await _requestGroups())
        : LessonsView(
            key: lessonsKey,
            selectedGroup: _selectedGroup,
            inSearch: false,
            callback: (Map<String, String> domens) {
              setState(() {
                _domens = domens;
              });
            },
            onClassroomTap: (classroom) => handleClassroomTap(classroom));

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
        title = Row(children: const [Text('Расписание')]);
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
          actions: [_groupSelectorAction],
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
                  icon: Icon(Icons.book_rounded), label: 'Расписание'),
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
    if (!kIsWeb && Platform.isLinux) return;

    if (classroom == 'ВЦ') {
      Fluttertoast.showToast(
          msg:
              'Открытых данных о расписании в ВЦ не имеется, проверить расположение невозможно');
      return;
    }
    if (classrooms[classroom.toLowerCase()] != null) {
      setState(() {
        _searchedClassroom = classroom;
        appbarAnimationDirection = true;
        _selectedView = 1;
      });
    } else {
      Fluttertoast.showToast(
          msg: 'Невозможно узнать кабинет или он не находится в техникуме');
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

    var gr = (await loadWeekShedule())?.item1 ?? 'Группа';
    var te = await loadPinnedTeachers();
    var pg = await loadPinnedGroups();

    setState(() {
      _selectedGroup = gr;
      cachedPinnedGroups = pg;
      cachedPinnedTeachers = te;
    });
  }

  Future<void> _requestGroups() async {
    try {
      await checkInternetConnection(() async {
        setState(() {
          entryOptions.clear();
        });
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
  final void Function() retryAction;
  const EmptyWelcome(
      {Key? key, required this.loading, required this.retryAction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            loading
                ? 'Пытаемся загрузить список групп...'
                : 'Выберите группу, чтобы посмотреть её расписание',
            style: app_global.headerFont,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          layout.ColoredTextButton(
            text: 'Обновить список вручную, если что-то пошло не так',
            onPressed: () => retryAction(),
            foregroundColor: Colors.white,
            boxColor: app_global.errorColor,
            splashColor: app_global.errorColor,
            outlined: true,
          ),
        ],
      ),
    );
  }
}
