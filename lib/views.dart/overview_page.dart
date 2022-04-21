import 'package:animations/animations.dart';
import 'package:mtkp/settings_model.dart';
import 'package:mtkp/views.dart/lessons_view.dart';
import 'package:mtkp/views.dart/search_view/search_view.dart';
import 'package:mtkp/views.dart/settings_view.dart';
import 'package:mtkp/database/database_interface.dart';
import 'package:mtkp/views.dart/domens_view.dart';
import 'package:mtkp/models.dart';
import 'package:mtkp/widgets/layout.dart' as layout;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mtkp/workers/file_worker.dart';
import 'package:mtkp/main.dart' as appGlobal;

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

  @override
  void initState() {
    super.initState();
    _requestGroups();

    _views = List<Widget>.filled(4, Container(color: Colors.pinkAccent));
    _views[0] = SearchView(key: const PageStorageKey("Search"));
  }

  @override
  Widget build(BuildContext context) {
    var lessonsKey = const PageStorageKey("Lessons");

    _views[2] = _selectedGroup == 'Группа'
        ? EmptyWelcome(
            loading: entryOptions.isEmpty && _selectedGroup == 'Группа')
        : DomensView(existingPairs: _domens);
    _views[3] = _selectedGroup == 'Группа'
        ? EmptyWelcome(
            loading: entryOptions.isEmpty && _selectedGroup == 'Группа')
        : const SettingsView();

    final _updateAction = IconButton(
        splashRadius: 18,
        onPressed: () => {setState(() => needUpdateTrigger = true)},
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
            if (_selectedGroup != value) {
              _selectedGroup = value;
              needUpdateTrigger = true;
              _selectedView = 1;
            }
          });

          if (!kIsWeb) {
            await clearMessageStamp();
            await saveSubscriptionToGroup(_selectedGroup);
          }
        },
      ),
    );

    _views[1] = _selectedGroup == 'Группа'
        ? EmptyWelcome(
            loading: entryOptions.isEmpty && _selectedGroup == 'Группа')
        : LessonsView(
            key: lessonsKey,
            selectedGroup: _selectedGroup,
            dirty: needUpdateTrigger,
            callback: (bool isReplacementSelected, DateTime? lastReplacements,
                Map<String, String> domens) {
              setState(() {
                _isReplacementSelected = isReplacementSelected;
                _lastReplacements = lastReplacements;
                _domens = domens;
              });
            });

    needUpdateTrigger = false;

    late Widget title;
    switch (_selectedView) {
      case 0:
        title = Row(children: const [Text('Поиск')]);
        break;
      case 1:
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
      case 2:
        title = Row(children: const [Text('Предметы')]);
        break;
      case 3:
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
                  appbarAnimationDirection = index < _selectedView;
                  _selectedView = index;
                }),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.search_rounded), label: 'Поиск'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.view_day_rounded), label: 'Расписание'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.school_rounded), label: 'Предметы'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings_rounded), label: 'Настройки'),
            ]),
        body: PageStorage(
          bucket: _bucket,
          child: layout.SharedAxisSwitcher(
            reverse: appbarAnimationDirection,
            transitionType: SharedAxisTransitionType.horizontal,
            child: _views[_selectedView],
          ),
        ));
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
        style: appGlobal.headerFont,
        textAlign: TextAlign.center,
      )),
    );
  }
}
