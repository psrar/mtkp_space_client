import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mtkp/database/database_interface.dart';
import 'package:mtkp/widgets/layout.dart';
import 'package:flutter/material.dart';
import 'package:mtkp/main.dart' as app_global;
import 'package:tuple/tuple.dart';

class TeachersView extends StatefulWidget {
  final List<Tuple2<int, String>> pinnedTeachers;

  final Function(List<Tuple2<int, String>>) onTeacherPinned;
  final Function callback;
  const TeachersView(
      {Key? key,
      this.pinnedTeachers = const [],
      required this.callback,
      required this.onTeacherPinned})
      : super(key: key);

  @override
  _TeachersViewState createState() => _TeachersViewState();
}

class _TeachersViewState extends State<TeachersView> {
  List<Tuple2<int, String>> _teachers = [];
  List<Tuple2<int, String>> _pinnedTeachers = [];

  @override
  void initState() {
    super.initState();

    _requestTeachers();
    _pinnedTeachers = widget.pinnedTeachers.toList();
  }

  @override
  Widget build(BuildContext context) {
    var pg = _pinnedTeachers.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Группы'),
        actions: [
          IconButton(
              splashRadius: 18,
              onPressed: () {
                setState(() {
                  _teachers = [];
                  _requestTeachers();
                });
              },
              icon: Icon(
                Icons.refresh_rounded,
                color: Theme.of(context).primaryColorLight,
              ))
        ],
      ),
      body: _teachers.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
              color: app_global.accessColor,
            ))
          : ListView.separated(
              itemBuilder: (context, index) {
                bool pinned = false;
                if (_pinnedTeachers.isNotEmpty) {
                  pinned = _pinnedTeachers.contains(_teachers[index]);
                  if (pinned) pg.remove(_teachers[index]);
                }

                return InkWell(
                  onTap: () {
                    widget.callback.call(_teachers[index].item1.toString() +
                        '~' +
                        _teachers[index].item2);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    constraints: const BoxConstraints.expand(height: 56),
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _teachers[index].item2,
                          style: const TextStyle(fontSize: 16),
                          softWrap: false,
                          overflow: TextOverflow.fade,
                        ),
                        IconButton(
                            color: app_global.primaryColor,
                            splashRadius: 20,
                            tooltip: 'Закрепить на экране поиска',
                            onPressed: () {
                              pin(index, !pinned);
                            },
                            icon: Icon(
                              pinned
                                  ? Icons.push_pin_rounded
                                  : Icons.push_pin_outlined,
                            ))
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const Divider(height: 0),
              itemCount: _teachers.length),
    );
  }

  void pin(int index, bool pin) {
    setState(() {
      if (pin) {
        _pinnedTeachers.add(_teachers[index]);
      } else {
        _pinnedTeachers.remove(_teachers[index]);
      }

      widget.onTeacherPinned(_pinnedTeachers);
    });
  }

  void _requestTeachers() {
    Connectivity().checkConnectivity().then((value) {
      if (value == ConnectivityResult.none) {
        showTextSnackBar(
            context,
            'Вы не подключены к интернету. Попробуйте обновить список, когда он появится.',
            5000);
      } else {
        DatabaseWorker.currentDatabaseWorker!.getAllTeachers().then((value) {
          if (value == null) {
            showTextSnackBar(
                context,
                'Преподаватели не найдены или не удалось получить информацию о них',
                5000);
          } else {
            value.sort((a, b) => a.item2.compareTo(b.item2));
            setState(() => _teachers = value);
          }
        });
      }
    });
  }
}
