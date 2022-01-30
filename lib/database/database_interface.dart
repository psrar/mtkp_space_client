import 'dart:developer';

import 'package:supabase/supabase.dart';
import 'package:tuple/tuple.dart';

const String supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlhdCI6MTY0MTE2MjA3MSwiZXhwIjoxOTU2NzM4MDcxfQ.YOfFRCE1ltwHN319j5nScsCNOaY4e4ABlw0EdVu3j3A';
const String supabaseURL = "https://ukucnsshztcrrlwwayaw.supabase.co";

class DatabaseWorker {
  static DatabaseWorker? _currentDatabaseWorker;
  late final SupabaseClient _client;

  DatabaseWorker(
      {String supabaseKey = supabaseKey, String supabaseURL = supabaseURL}) {
    _client = SupabaseClient(supabaseURL, supabaseKey);
    _currentDatabaseWorker = this;
  }

  static DatabaseWorker? get currentDatabaseWorker => _currentDatabaseWorker;

  Future<List<String>> getTimeshedule() async {
    try {
      var response = <String>[];
      await _client.from('t_timeshedule').select().execute().then((value) {
        if ((value.data as List<dynamic>).isEmpty) {
          return [];
        } else {
          var element = (value.data as List<dynamic>).first;
          response.add(element['firstpair']);
          response.add(element['secondpair']);
          response.add(element['thirdpair']);
          response.add(element['fourthpair']);
          response.add(element['fifthpair']);
          response.add(element['sixthpair']);
        }
      });
      return response;
    } catch (e) {
      log('getTimeshedule: ' + e.toString());
      return [];
    }
  }

  Future<List<String>> getAllGroups() async {
    try {
      var response = <String>[];
      await _client.from('t_group').select().execute().then((value) {
        for (var element in (value.data as List<dynamic>)) {
          response.add(element['groupname']);
        }
      });
      return response;
    } catch (e) {
      throw Exception('getAllGroups: ' + e.toString());
    }
  }

  Future<List<Tuple2<int, String>>?> getAllTeachers() async {
    try {
      var response = <Tuple2<int, String>>[];
      await _client.from('t_teacher').select().execute().then((value) {
        for (var element in value.data as List<dynamic>) {
          response.add(Tuple2(element['id'], element['name']));
        }
      });
      return response;
    } catch (e) {
      throw Exception('getAllTeachers: ' + e.toString());
    }
  }

  Future<List<Tuple2<int, String>>?> getAllSubjects(String? group) async {
    try {
      var response = <Tuple2<int, String>>[];
      if (group == null) {
        await _client.from('t_subject').select().execute().then((value) {
          for (var element in value.data as List<dynamic>) {
            response.add(Tuple2(element['id'], element['name']));
          }
        });
      } else {
        await _client
            .rpc('getsubjects', params: {'selectedgroup': group})
            .execute()
            .then((value) {
              for (var element in value.data as List<dynamic>) {
                response.add(Tuple2(element['id'], element['name']));
              }
            });
      }
      return response;
    } catch (e) {
      throw Exception('getAllSubjects: ' + e.toString());
    }
  }

  Future<List<Tuple3<String?, String?, String?>>> getShedule(
      String group) async {
    try {
      var response = <Tuple3<String?, String?, String?>>[];
      await _client
          .rpc('getshedule', params: {'selectedgroup': group})
          .execute()
          .then((value) {
            for (var element in (value.data as List<dynamic>)) {
              response.add(
                  Tuple3(element['sname'], element['tname'], element['room']));
            }
          });
      return response;
    } catch (e) {
      throw Exception('getShedule: ' + e.toString());
    }
  }
}
