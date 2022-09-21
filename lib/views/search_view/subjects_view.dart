import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mtkp/database/database_interface.dart';
import 'package:mtkp/main.dart' as app_global;
import 'package:mtkp/widgets/layout.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class SubjectsView extends StatefulWidget {
  final VoidCallback callback;
  const SubjectsView({Key? key, required this.callback}) : super(key: key);

  @override
  _SubjectsViewState createState() => _SubjectsViewState();
}

class _SubjectsViewState extends State<SubjectsView> {
  List<Tuple2<int, String>>? _subjects;
  String _selectedGroup = 'Все';

  List<String> entryOptions = [];

  @override
  void initState() {
    super.initState();

    _requestGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Предметы',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        actions: [
          IconButton(
              splashRadius: 18,
              onPressed: () {
                setState(() {
                  _subjects = null;
                  if (_selectedGroup == 'Все') {
                    _requestSubjects(null);
                  }
                });
              },
              icon: Icon(
                Icons.refresh_rounded,
                color: Theme.of(context).primaryColorLight,
              )),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 10, 8),
            child: GroupSelector(
                selectedGroup: _selectedGroup,
                options: entryOptions,
                callback: (value) => setState(() {
                      if (value == 'Показать все предметы') {
                        _selectedGroup = 'Все';
                        _requestSubjects(null);
                      } else {
                        _selectedGroup = value;
                        _requestSubjects(_selectedGroup);
                      }
                      // requestShedule(_selectedGroup);
                    })),
          )
        ],
      ),
      body: _subjects == null
          ? const Center(
              child: CircularProgressIndicator(
              color: app_global.accessColor,
            ))
          : ListView.separated(
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    widget.callback.call();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    constraints: const BoxConstraints.expand(height: 56),
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(left: 18),
                    child: Text(
                      _subjects![index].item2,
                      style: const TextStyle(fontSize: 16),
                      softWrap: false,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const Divider(height: 0),
              itemCount: _subjects!.length),
    );
  }

  void _requestSubjects(String? group) {
    Connectivity().checkConnectivity().then((value) {
      if (value == ConnectivityResult.none) {
        showTextSnackBar(
            context,
            'Вы не подключены к интернету. Попробуйте обновить список, когда он появится.',
            5000);
      } else {
        DatabaseWorker.currentDatabaseWorker!
            .getAllSubjects(group)
            .then((value) {
          if (value == null) {
            showTextSnackBar(
                context,
                'Предметы не найдены или не удалось получить информацию о них',
                5000);
          } else {
            value.sort((a, b) => a.item2.compareTo(b.item2));
            setState(() => _subjects = value);
          }
        });
      }
    });
  }

  void _requestGroups() async {
    try {
      await Connectivity().checkConnectivity().then((value) {
        if (value != ConnectivityResult.none) {
          DatabaseWorker.currentDatabaseWorker!
              .getAllGroups()
              .then((value) => setState(() {
                    entryOptions = value;
                    if (entryOptions.isNotEmpty) {
                      entryOptions.insert(0, 'Показать все предметы');
                    }

                    _requestSubjects(null);
                  }));
        } else {
          showTextSnackBar(
              context, 'Вы не в сети. Не удаётся загрузить данные.', 5000);
        }
      });
    } catch (e) {
      log(e.toString());
    }
  }
}
