import 'dart:developer';

import 'package:mtkp/models.dart';
import 'package:supabase/supabase.dart';
import 'package:tuple/tuple.dart';

const String supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlhdCI6MTY0MTE2MjA3MSwiZXhwIjoxOTU2NzM4MDcxfQ.YOfFRCE1ltwHN319j5nScsCNOaY4e4ABlw0EdVu3j3A';
const String supabaseURL = "https://ukucnsshztcrrlwwayaw.supabase.co";

class DatabaseWorker {
  static late DatabaseWorker _currentDatabaseWorker;
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

  Future<Tuple2<String, List<Tuple4<int, String, String, String>>>>
      getAllMessages({Tuple2<int, DateTime>? from, String? group}) async {
    PostgrestResponse<dynamic> result;
    if (from == null) {
      if (group == null) {
        result = await _client.from('t_message').select().execute();
      } else {
        result = await _client
            .from('t_message')
            .select()
            .like('receiver', group)
            .execute();
      }
    } else {
      if (group == null) {
        result = await _client
            .from('t_message')
            .select()
            .gt('id', from.item1)
            .limit(8)
            .execute();
      } else {
        result = await _client
            .from('t_message')
            .select()
            .like('receiver', group)
            .gt('id', from.item1)
            .limit(8)
            .execute();
      }
    }
    if (result.hasError) return Tuple2(result.error.toString(), []);

    var messages = <Tuple4<int, String, String, String>>[];
    for (var element in (result.data as List<dynamic>)) {
      messages.add(Tuple4(element['id'], element['receiver'], element['title'],
          element['body']));
    }

    return Tuple2('', messages);
  }

  Future<Tuple2<String?, Map<SimpleDate, List<PairModel?>?>?>> getReplacements(
      SimpleDate date, String group) async {
    try {
      var response = await _client.rpc('replacementsexist', params: {
        'selectedgroup': group,
        'selecteddt': '2000-${date.month.num}-${date.day}'
      }).execute();

      if (response.hasError) {
        return Tuple2(
            'Can\'t get replacements: ' + response.error!.message, null);
      } else {
        var data = response.data as bool;
        if (data == false) {
          response = await _client
              .from('t_replacement')
              .select()
              .eq('dt', '2000-${date.month.num}-${date.day}')
              .limit(1)
              .execute();
          if (response.hasError) {
            return Tuple2(
                'Can\'t get replacements: ' + response.error!.message, null);
          } else {
            if ((response.data as List<dynamic>).isNotEmpty) {
              return Tuple2(null, {date: null});
            } else {
              return const Tuple2(null, null);
            }
          }
        } else {
          response = await _client.rpc('getreplacement', params: {
            'selectedgroup': group,
            'selecteddt': '2000-${date.month.num}-${date.day}'
          }).execute();

          if (response.hasError) {
            return Tuple2(
                'Can\'t get replacements: ' + response.error!.message, null);
          } else {
            var pairs = <PairModel?>[];
            var data = response.data as List<dynamic>;
            for (var e in data) {
              if (e['subject'] == null) {
                pairs.add(null);
              } else {
                pairs.add(PairModel(e['subject'], e['teacher'], e['room']));
              }
            }

            return Tuple2('', {date: pairs});
          }
        }
      }
    } catch (e) {
      return Tuple2('Can\'t get replacements: ' + e.toString(), null);
    }
  }
}
