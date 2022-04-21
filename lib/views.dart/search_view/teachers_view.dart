import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mtkp/database/database_interface.dart';
import 'package:mtkp/widgets/layout.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class TeachersView extends StatefulWidget {
  final VoidCallback callback;
  const TeachersView({Key? key, required this.callback}) : super(key: key);

  @override
  _TeachersViewState createState() => _TeachersViewState();
}

class _TeachersViewState extends State<TeachersView> {
  List<Tuple2<int, String>>? _teachers;

  @override
  void initState() {
    super.initState();

    _requestTeachers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Преподаватели',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  _teachers = null;
                  _requestTeachers();
                });
              },
              icon: Icon(
                Icons.refresh_rounded,
                color: Theme.of(context).primaryColorLight,
              ))
        ],
      ),
      body: _teachers == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Row(children: [
                    Expanded(
                      child: Text(
                        _teachers![index].item2,
                        style: const TextStyle(fontSize: 16),
                        softWrap: false,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ]),
                );
              },
              separatorBuilder: (context, index) => const Divider(height: 0),
              itemCount: _teachers!.length),
    );
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
