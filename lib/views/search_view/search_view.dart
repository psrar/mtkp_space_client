import 'package:flutter/material.dart';
import 'package:mtkp/main.dart';
import 'package:mtkp/views/lessons_view.dart';
import 'package:mtkp/views/search_view/groups_view.dart';
import 'package:mtkp/views/search_view/teachers_view.dart';
import 'package:mtkp/widgets/layout.dart';
import 'package:mtkp/workers/caching.dart';

class SearchView extends StatefulWidget {
  final String option;
  final void Function(String searchOption) callback;

  final List<String> pinnedGroups;

  const SearchView(
      {Key? key,
      required this.pinnedGroups,
      required this.option,
      required this.callback})
      : super(key: key);

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  late String _option;
  late Widget _searchMenu;

  List<String> _pinnedGroups = [];

  late PageStorageBucket storage;

  @override
  void initState() {
    super.initState();

    storage = PageStorage.of(context)!;

    var data = storage.readState(context, identifier: widget.key);
    if (data == null) {
      _pinnedGroups = widget.pinnedGroups;
    } else {
      _pinnedGroups = storage.readState(context, identifier: widget.key);
    }
  }

  @override
  Widget build(BuildContext context) {
    _option = widget.option;

    storage = PageStorage.of(context)!;
    _searchMenu = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Преподаватели', style: giantFont),
          const SizedBox(height: 16),
          ColoredTextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TeachersView(callback: () {}))),
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
                      storage.writeState(context, _pinnedGroups,
                          identifier: widget.key);
                    }))),
            text: 'Найти или закрепить группу',
            foregroundColor: Colors.white,
            boxColor: primaryColor,
            outlined: true,
          ),
        ],
      ),
    );

    return SharedAxisSwitcher(
      reverse: _option.isEmpty,
      duration: const Duration(seconds: 1),
      child: _option.isNotEmpty
          ? LessonsView(
              key: ValueKey(_option),
              selectedGroup: _option,
              callback: (_, __, ___) {},
              dirty: false,
              inSearch: true)
          : _searchMenu,
    );
  }
}
