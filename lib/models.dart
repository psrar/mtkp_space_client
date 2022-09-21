import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:tuple/tuple.dart';

part 'models.g.dart';

const Map<String, Tuple2<double, double>> classrooms = {
  //Первый этаж
  '101': Tuple2(305, 826),
  'библиотека': Tuple2(305, 826),
  '102': Tuple2(337, 866),
  '104': Tuple2(337, 882),
  '105': Tuple2(337, 929),
  '108': Tuple2(260, 905),
  '109': Tuple2(220, 905),
  '110': Tuple2(180, 905),
  '111': Tuple2(140, 905),
  '112': Tuple2(80, 950),
  '113': Tuple2(67, 934),
  '114': Tuple2(73, 903),
  '115': Tuple2(74, 844),
  '116': Tuple2(64, 808),
  '117': Tuple2(64, 778),
  '118': Tuple2(127, 804),
  '119': Tuple2(130, 777),
  '122': Tuple2(129, 641),
  '123': Tuple2(177, 641),
  '124': Tuple2(227, 641),
  '126': Tuple2(243, 706),
  '130': Tuple2(187, 690),
  '131': Tuple2(118, 703),

  //Второй этаж
  '200': Tuple2(664, 761),
  '201': Tuple2(664, 790),
  '202': Tuple2(664, 816),
  '203': Tuple2(709, 807),
  '205': Tuple2(709, 831),
  '206': Tuple2(709, 843),
  '207': Tuple2(709, 858),
  '208': Tuple2(709, 870),
  '209': Tuple2(709, 882),
  '210': Tuple2(709, 898),
  '211': Tuple2(709, 928),
  '212': Tuple2(676, 977),
  '214': Tuple2(631, 902),
  '215': Tuple2(592, 902),
  '216': Tuple2(551, 902),
  '217': Tuple2(512, 902),
  '219': Tuple2(465, 963),
  '220': Tuple2(433, 908),
  '221': Tuple2(433, 863),
  '222': Tuple2(433, 837),
  '223': Tuple2(433, 817),
  '224': Tuple2(433, 789),
  '225': Tuple2(501, 816),
  '226': Tuple2(501, 788),
  '227': Tuple2(501, 760),
  '228': Tuple2(460, 730),
  '229': Tuple2(460, 715),
  '230': Tuple2(460, 700),
  '231': Tuple2(510, 642),
  '234': Tuple2(553, 627),
  '235': Tuple2(566, 627),
  '236': Tuple2(579, 627),
  '237': Tuple2(573, 658),
  '245': Tuple2(655, 638),

  //Третий этаж
  '300': Tuple2(274, 237),
  '301': Tuple2(274, 267),
  '303': Tuple2(340, 267),
  '304': Tuple2(340, 300),
  '305': Tuple2(340, 326),
  '306': Tuple2(340, 346),
  '307': Tuple2(340, 358),
  '308': Tuple2(340, 390),
  '310': Tuple2(310, 455),
  '312': Tuple2(260, 380),
  '313': Tuple2(222, 380),
  '314': Tuple2(180, 380),
  '315': Tuple2(150, 380),
  '316': Tuple2(130, 380),
  '318': Tuple2(93, 440),
  '320': Tuple2(60, 390),
  '321': Tuple2(60, 340),
  '322': Tuple2(60, 308),
  '323': Tuple2(60, 293),
  '324': Tuple2(60, 268),
  '325': Tuple2(132, 293),
  '326': Tuple2(132, 265),
  '327': Tuple2(132, 237),
  '328': Tuple2(90, 222),
  '329': Tuple2(93, 177),
  '333': Tuple2(144, 156),
  '338': Tuple2(311, 176),

  //Четвертый этаж
  '400': Tuple2(643, 237),
  '401': Tuple2(643, 265),
  '402': Tuple2(643, 293),
  '403': Tuple2(710, 265),
  '404': Tuple2(710, 293),
  '405': Tuple2(710, 307),
  '406': Tuple2(710, 333),
  '407': Tuple2(710, 359),
  '408': Tuple2(710, 389),
  '409': Tuple2(670, 390),
  '410': Tuple2(678, 455),
  '411': Tuple2(637, 455),
  'актовый зал': Tuple2(571, 379),
  '414': Tuple2(513, 379),
  '415': Tuple2(504, 455),
  '416': Tuple2(464, 455),
  '417': Tuple2(432, 388),
  '418': Tuple2(431, 338),
  '419': Tuple2(431, 309),
  '420': Tuple2(431, 294),
  '421': Tuple2(431, 278),
  '422': Tuple2(502, 295),
  '425': Tuple2(648, 187),
};

class Weekday {
  final String _value;
  const Weekday._internal(this._value);

  @override
  String toString() => 'Weekday.$_value';

  String get name {
    switch (this) {
      case Weekday.monday:
        return 'Понедельник';
      case Weekday.tuesday:
        return 'Вторник';
      case Weekday.wednesday:
        return 'Среда';
      case Weekday.thursday:
        return 'Четверг';
      case Weekday.friday:
        return 'Пятница';
      case Weekday.saturday:
        return 'Суббота';
      case Weekday.sunday:
        return 'Воскресенье';
      default:
        throw Exception('Как в неделе оказался 8 день?');
    }
  }

  String get shortName {
    switch (this) {
      case Weekday.monday:
        return 'Пн';
      case Weekday.tuesday:
        return 'Вт';
      case Weekday.wednesday:
        return 'Ср';
      case Weekday.thursday:
        return 'Чт';
      case Weekday.friday:
        return 'Пт';
      case Weekday.saturday:
        return 'Сб';
      case Weekday.sunday:
        return 'Вс';
      default:
        throw Exception('Как в неделе оказался 8 день?');
    }
  }

  static const monday = Weekday._internal('monday');
  static const tuesday = Weekday._internal('tuesday');
  static const wednesday = Weekday._internal('wednesday');
  static const thursday = Weekday._internal('thursday');
  static const friday = Weekday._internal('friday');
  static const saturday = Weekday._internal('saturday');
  static const sunday = Weekday._internal('sunday');

  static const List<Weekday> all = [
    Weekday.monday,
    Weekday.tuesday,
    Weekday.wednesday,
    Weekday.thursday,
    Weekday.friday,
    Weekday.saturday,
    Weekday.sunday
  ];
  static final List<Weekday> exceptSunday = all.sublist(0, 6);
  static final List<Weekday> exceptWeekend = all.sublist(0, 5);
}

class Month {
  final String _value;
  const Month._internal(this._value);

  @override
  String toString() => 'Month.$_value';

  static Month fromNum(int num) => Month.all[num];

  String get name {
    switch (this) {
      case Month.january:
        return 'Январь';
      case Month.february:
        return 'Февраль';
      case Month.march:
        return 'Март';
      case Month.april:
        return 'Апрель';
      case Month.may:
        return 'Май';
      case Month.june:
        return 'Июнь';
      case Month.july:
        return 'Июль';
      case Month.august:
        return 'Август';
      case Month.september:
        return 'Сентябрь';
      case Month.october:
        return 'Октябрь';
      case Month.november:
        return 'Ноябрь';
      case Month.december:
        return 'Декабрь';
      default:
        throw Exception('Как появился 13 месяц?');
    }
  }

  String get ofName {
    switch (this) {
      case Month.january:
        return 'января';
      case Month.february:
        return 'февраля';
      case Month.march:
        return 'марта';
      case Month.april:
        return 'апреля';
      case Month.may:
        return 'мая';
      case Month.june:
        return 'июня';
      case Month.july:
        return 'июля';
      case Month.august:
        return 'августа';
      case Month.september:
        return 'сентября';
      case Month.october:
        return 'октября';
      case Month.november:
        return 'ноября';
      case Month.december:
        return 'декабря';
      default:
        throw Exception('Как появился 13 месяц?');
    }
  }

  ///From 1 to 12
  int get num {
    switch (this) {
      case Month.january:
        return 1;
      case Month.february:
        return 2;
      case Month.march:
        return 3;
      case Month.april:
        return 4;
      case Month.may:
        return 5;
      case Month.june:
        return 6;
      case Month.july:
        return 7;
      case Month.august:
        return 8;
      case Month.september:
        return 9;
      case Month.october:
        return 10;
      case Month.november:
        return 11;
      case Month.december:
        return 12;
      default:
        throw Exception('Как появился 13 месяц?');
    }
  }

  static const january = Month._internal('january');
  static const february = Month._internal('february');
  static const march = Month._internal('march');
  static const april = Month._internal('april');
  static const may = Month._internal('may');
  static const june = Month._internal('june');
  static const july = Month._internal('july');
  static const august = Month._internal('august');
  static const september = Month._internal('september');
  static const october = Month._internal('october');
  static const november = Month._internal('november');
  static const december = Month._internal('december');

  static const List<Month> all = [
    Month.january,
    Month.february,
    Month.march,
    Month.april,
    Month.may,
    Month.june,
    Month.july,
    Month.august,
    Month.september,
    Month.october,
    Month.november,
    Month.december,
  ];
}

@JsonSerializable(fieldRename: FieldRename.snake)
class PairModel {
  String name;
  String? teacherName;
  String? room;

  ///Создает модель пары по расписанию. Week - обозначение нечетности (1) и четности (2) недели. Если предмет есть на обеих неделях, необходимо указать число (3).
  PairModel(this.name, this.teacherName, this.room);

  get teacherReadable =>
      teacherName == null || teacherName == '' ? 'Не указан' : teacherName!;

  get roomReadable => room ?? '—';

  factory PairModel.fromJson(Map<String, dynamic> json) =>
      _$PairModelFromJson(json);

  Map<String, dynamic> toJson() => _$PairModelToJson(this);

  @override
  String toString() {
    return name +
        ' ' +
        (teacherName ?? 'Преподаватель не указан') +
        ' ' +
        (room ?? 'Кабинет не указан');
  }
}

class Replacements {
  late final Map<SimpleDate, List<PairModel?>?>? replacements;

  Replacements(this.replacements);
  Replacements.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) return;

    replacements = {};
    for (var entry in json.entries) {
      if (entry.value == '') {
        replacements![SimpleDate.fromNum(entry.key)] = null;
        continue;
      }
      var pairs = <PairModel?>[];
      for (var i = 0; i < 6; i++) {
        var pair = entry.value[i.toString()];
        pairs.add(pair == null
            ? null
            : PairModel(pair['name'], pair['teacher_name'], pair['room']));
      }
      replacements![SimpleDate.fromNum(entry.key)] = pairs;
    }
  }

  Tuple2<SimpleDate, List<PairModel?>?>? getReplacement(SimpleDate simpleDate) {
    if (replacements != null && replacements!.containsKey(simpleDate)) {
      return Tuple2(simpleDate, replacements![simpleDate]);
    } else {
      return null;
    }
  }

  void cutDays(int storedAmount) {
    if (replacements != null && replacements!.length < storedAmount) return;

    var rp = replacements!.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    replacements!
      ..clear()
      ..addEntries(rp.sublist(rp.length - storedAmount));
  }

  int get count => replacements?.length ?? 0;

  Map<String, dynamic> toJson() {
    if (replacements == null) return {};

    var result = <String, dynamic>{};
    for (var repl in replacements!.entries) {
      if (repl.value == null) {
        result[repl.key.toNum()] = '';
        continue;
      }
      var pairs = {};
      for (var i = 0; i < 6; i++) {
        pairs[i.toString()] = repl.value?[i]?.toJson();
      }
      result[repl.key.toNum()] = pairs;
    }
    String jsonString = jsonEncode(result);
    Map<String, dynamic> js = jsonDecode(jsonString);
    Replacements.fromJson(js);
    return result;
  }
}

///Класс, содержащий информацию о начале и конце занятия
@JsonSerializable(fieldRename: FieldRename.snake)
class Time {
  final String start;
  final String end;

  Time(this.start, this.end);

  factory Time.fromJson(Map<String, dynamic> json) => _$TimeFromJson(json);

  Map<String, dynamic> toJson() => _$TimeToJson(this);
}

///Модель упрощенной даты (день и месяц)
class SimpleDate implements Comparable<SimpleDate> {
  late final int day;
  late final Month month;

  SimpleDate(this.day, this.month);
  SimpleDate.fromDateTime(DateTime dateTime) {
    day = dateTime.day;
    month = Month.all[dateTime.month - 1];
  }
  SimpleDate.fromNum(String num) {
    var n = num.split('.');
    day = int.parse(n.first);
    month = Month.fromNum(int.parse(n.last) - 1);
  }

  bool get isToday =>
      DateTime.now().day == day && DateTime.now().month == month.num;

  @override
  bool operator ==(other) =>
      (other is SimpleDate && day == other.day && month == other.month);

  @override
  int get hashCode => Object.hash(day, month);

  @override
  String toString() {
    return '$day, ${month.name}';
  }

  String toSpeech() => '$day ${month.ofName}';

  String toNum() => '$day.${month.num}';

  @override
  int compareTo(SimpleDate other) {
    if (day == other.day && month == other.month) return 0;
    if ((other.month.num * 32 + other.day) - (month.num * 32 + day) < 0) {
      return 1;
    }

    return -1;
  }
}

///Расписание начала и конца пар
@JsonSerializable(fieldRename: FieldRename.snake)
class Timetable {
  late Time first;
  late Time second;
  late Time third;
  late Time fourth;
  late Time fifth;
  late Time sixth;

  Timetable(
      this.first, this.second, this.third, this.fourth, this.fifth, this.sixth);

  Timetable.empty() {
    first = Time('', '');
    second = Time('', '');
    third = Time('', '');
    fourth = Time('', '');
    fifth = Time('', '');
    sixth = Time('', '');
  }

  factory Timetable.fromJson(Map<String, dynamic> json) =>
      _$TimetableFromJson(json);

  Map<String, dynamic> toJson() => _$TimetableToJson(this);

  Map<int, Time> get all => {
        1: first,
        2: second,
        3: third,
        4: fourth,
        5: fifth,
        6: sixth,
      };
}

///Расписание на неделю, timetable, верхняя неделя и нижняя
class WeekShedule {
  late final Tuple3<Timetable, List<List<PairModel?>>, List<List<PairModel?>>>
      weekLessons;

  WeekShedule(this.weekLessons);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SaveModel {
  late final Timetable timetable;
  late final List<List<PairModel?>> upShedule;
  late final List<List<PairModel?>> downShedule;
  late final String group;

  SaveModel(
    this.timetable,
    this.upShedule,
    this.downShedule,
    this.group,
  );

  factory SaveModel.fromJson(Map<String, dynamic> json) =>
      _$SaveModelFromJson(json);

  Map<String, dynamic> toJson() => _$SaveModelToJson(this);
}
