import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mtkp/database/database_interface.dart';
import 'package:mtkp/widgets/layout.dart';
import 'package:flutter/material.dart';
import 'package:mtkp/main.dart' as appGlobal;

class GroupsView extends StatefulWidget {
  final List<String> pinnedGroups;

  final Function(List<String>) onGroupPinned;
  final Function callback;

  const GroupsView(
      {Key? key,
      this.pinnedGroups = const [],
      required this.callback,
      required this.onGroupPinned})
      : super(key: key);

  @override
  _GroupsViewState createState() => _GroupsViewState();
}

class _GroupsViewState extends State<GroupsView> {
  List<String> _groups = [];
  List<String> _pinnedGroups = [];

  @override
  void initState() {
    super.initState();

    _requestGroups();
    _pinnedGroups = widget.pinnedGroups.toList();
  }

  @override
  Widget build(BuildContext context) {
    var pg = _pinnedGroups.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Группы'),
        actions: [
          IconButton(
              splashRadius: 18,
              onPressed: () {
                setState(() {
                  _groups = [];
                  _requestGroups();
                });
              },
              icon: Icon(
                Icons.refresh_rounded,
                color: Theme.of(context).primaryColorLight,
              ))
        ],
      ),
      body: _groups.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemBuilder: (context, index) {
                bool pinned = false;
                if (_pinnedGroups.isNotEmpty) {
                  pinned = _pinnedGroups.contains(_groups[index]);
                  if (pinned) pg.remove(_groups[index]);
                }

                return InkWell(
                  onTap: () {
                    widget.callback.call(_groups[index]);
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
                          _groups[index],
                          style: const TextStyle(fontSize: 16),
                          softWrap: false,
                          overflow: TextOverflow.fade,
                        ),
                        IconButton(
                            color: appGlobal.primaryColor,
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
              itemCount: _groups.length),
    );
  }

  void pin(int index, bool pin) {
    setState(() {
      if (pin) {
        _pinnedGroups.add(_groups[index]);
      } else {
        _pinnedGroups.remove(_groups[index]);
      }

      widget.onGroupPinned(_pinnedGroups);
    });
  }

  void _requestGroups() {
    Connectivity().checkConnectivity().then((value) {
      if (value == ConnectivityResult.none) {
        showTextSnackBar(
            context,
            'Вы не подключены к интернету. Попробуйте обновить список, когда он появится.',
            5000);
      } else {
        DatabaseWorker.currentDatabaseWorker!.getAllGroups().then((value) {
          if (value.isEmpty) {
            showTextSnackBar(
                context,
                'Группы не найдены или не удалось получить информацию о них',
                5000);
          }
          setState(() => _groups = value);
        });
      }
    });
  }
}
