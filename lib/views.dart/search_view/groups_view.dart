import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mtkp/database/database_interface.dart';
import 'package:mtkp/widgets/layout.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class GroupsView extends StatefulWidget {
  final Function callback;
  const GroupsView({Key? key, required this.callback}) : super(key: key);

  @override
  _GroupsViewState createState() => _GroupsViewState();
}

class _GroupsViewState extends State<GroupsView> {
  List<String> _groups = [];

  @override
  void initState() {
    super.initState();

    _requestGroups();
  }

  @override
  Widget build(BuildContext context) {
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
                return InkWell(
                  onTap: () {
                    widget.callback.call(_groups[index]);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    constraints: const BoxConstraints.expand(height: 56),
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(left: 18),
                    child: Text(
                      _groups[index],
                      style: const TextStyle(fontSize: 16),
                      softWrap: false,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const Divider(height: 0),
              itemCount: _groups.length),
    );
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
