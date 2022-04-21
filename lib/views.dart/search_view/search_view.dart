import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mtkp/main.dart';
import 'package:mtkp/views.dart/search_view/groups_view.dart';
import 'package:mtkp/views.dart/search_view/teachers_view.dart';
import 'package:mtkp/widgets/layout.dart';

class SearchView extends StatefulWidget {
  SearchView({Key? key}) : super(key: key);

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  late PageStorageBucket _pageStorageBucket;

  late Widget _selectedWidget;
  var _selectedGroup;

  @override
  void initState() {
    super.initState();

    var a = PageStorage.of(context)!.readState(context, identifier: widget.key);
    _selectedGroup = a ?? '';

    _selectedWidget = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
      child: Center(
        child: SingleChildScrollView(
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
              ColoredTextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (c) => GroupsView(
                          callback: (gr) {
                            PageStorage.of(context)!.writeState(context, gr,
                                identifier: widget.key);

                            setState(() {
                              _selectedGroup = gr;
                            });
                          },
                        ))),
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
  }

  @override
  Widget build(BuildContext context) {
    Fluttertoast.showToast(msg: _selectedGroup);
    return _selectedWidget;
  }
}
