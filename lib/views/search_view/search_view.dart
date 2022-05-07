import 'package:flutter/material.dart';
import 'package:mtkp/main.dart';
import 'package:mtkp/views/lessons_view.dart';
import 'package:mtkp/views/lessons_view_teachers.dart';
import 'package:mtkp/views/search_view/groups_view.dart';
import 'package:mtkp/views/search_view/teachers_view.dart';
import 'package:mtkp/widgets/layout.dart';
import 'package:mtkp/workers/caching.dart';
import 'package:tuple/tuple.dart';

class SearchView extends StatefulWidget {
  final String option;
  final void Function(String searchOption) callback;
  final void Function(String classroom) onClassroomTap;

  final List<String> pinnedGroups;
  final List<Tuple2<int, String>> pinnedTeachers;

  const SearchView(
      {Key? key,
      required this.pinnedTeachers,
      required this.pinnedGroups,
      required this.option,
      required this.callback,
      required this.onClassroomTap})
      : super(key: key);

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final PageStorageBucket _bucket = PageStorageBucket();
  late String _option;
  late Widget _searchMenu;

  List<String> _pinnedGroups = [];
  List<Tuple2<int, String>> _pinnedTeachers = [];

  late PageStorageBucket storage;

  @override
  void initState() {
    super.initState();

    storage = PageStorage.of(context)!;

    var data = storage.readState(context, identifier: widget.key);
    if (data == null) {
      _pinnedGroups = widget.pinnedGroups;
      _pinnedTeachers = widget.pinnedTeachers;
    } else {
      _pinnedGroups = storage.readState(context, identifier: widget.key)[0];
      _pinnedTeachers = storage.readState(context, identifier: widget.key)[1];
    }
  }

  @override
  Widget build(BuildContext context) {
    _option = widget.option;
    storage = PageStorage.of(context)!;

    _searchMenu = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Преподаватели', style: giantFont),
              const SizedBox(height: 16),
              for (var item in _pinnedTeachers)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ColoredTextButton(
                      onPressed: () {
                        setState(() {
                          _option = item.item2;
                          widget
                              .callback(item.item1.toString() + '~' + _option);
                        });
                      },
                      text: item.item2,
                      foregroundColor: Colors.white,
                      boxColor: primaryColor),
                ),
              ColoredTextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => TeachersView(
                        pinnedTeachers: _pinnedTeachers,
                        callback: (te) {
                          _option = te;
                          widget.callback(_option);
                        },
                        onTeacherPinned: (pinnedTeachers) {
                          setState(() => _pinnedTeachers = pinnedTeachers);
                          savePinnedTeachers(_pinnedTeachers);
                          storage.writeState(
                              context, [_pinnedGroups, _pinnedTeachers],
                              identifier: widget.key);
                        }))),
                text: 'Найти или закрепить преподавателя',
                foregroundColor: Colors.white,
                boxColor: primaryColor,
                outlined: true,
              ),
              const SizedBox(height: 30),
              const Divider(color: Colors.grey, thickness: 1, height: 0),
              const SizedBox(height: 18),
              Text('Группы', style: giantFont),
              const SizedBox(height: 18),
              for (var item in _pinnedGroups)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ColoredTextButton(
                      onPressed: () {
                        setState(() {
                          _option = item;
                          widget.callback(_option);
                        });
                      },
                      text: item,
                      foregroundColor: Colors.white,
                      boxColor: primaryColor),
                ),
              ColoredTextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => GroupsView(
                        pinnedGroups: _pinnedGroups,
                        callback: (gr) => setState(() {
                              _option = gr;
                              widget.callback(_option);
                            }),
                        onGroupPinned: (pinnedGroups) {
                          setState(() => _pinnedGroups = pinnedGroups);
                          savePinnedGroups(_pinnedGroups);
                          storage.writeState(
                              context, [_pinnedGroups, _pinnedTeachers],
                              identifier: widget.key);
                        }))),
                text: 'Найти или закрепить группу',
                foregroundColor: Colors.white,
                boxColor: primaryColor,
                outlined: true,
              ),
            ],
          ),
        ),
      ),
    );

    Widget w;
    if (_option.isNotEmpty) {
      w = _option.contains('~')
          ? LessonsViewForTeacher(
              key: const PageStorageKey('Lessons'),
              selectedGroup: _option,
              inSearch: true,
              onClassroomTap: (c) => widget.onClassroomTap(c))
          : LessonsView(
              key: const PageStorageKey('Lessons'),
              selectedGroup: _option,
              callback: (_) {},
              inSearch: true,
              onClassroomTap: (c) => widget.onClassroomTap(c));
    } else {
      w = _searchMenu;
    }

    return PageStorage(
      bucket: _bucket,
      child: SharedAxisSwitcher(
        reverse: _option.isEmpty,
        duration: const Duration(milliseconds: 600),
        child: w,
      ),
    );
  }
}
