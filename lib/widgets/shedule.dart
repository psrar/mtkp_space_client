import 'package:auto_size_text/auto_size_text.dart';
import 'package:diary/models.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class SheduleContentWidget extends StatelessWidget {
  final Tuple2<Timetable, List<PairModel?>?> dayShedule;

  const SheduleContentWidget({Key? key, required this.dayShedule})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var lessonsWidgetList = <Widget>[];
    var timetable = dayShedule.item1;
    var lessons = dayShedule.item2;
    for (var i = 0; i < 6; i++) {
      var time = timetable.all[i + 1];
      if (lessons != null && i < lessons.length) {
        if (lessons[i] == null) {
          lessonsWidgetList.add(EmptyLessonWidget(time: time!));
        } else {
          lessonsWidgetList
              .add(LessonWidget(time: time!, lessonModel: lessons[i]!));
        }
      } else {
        lessonsWidgetList.add(EmptyLessonWidget(time: time!));
      }
    }

    for (var i = 1; i < lessonsWidgetList.length; i += 2) {
      lessonsWidgetList.insert(
          i,
          const Divider(
            height: 1,
            thickness: 1,
            color: Colors.black38,
          ));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: lessonsWidgetList,
      ),
    );
  }
}

class LessonWidget extends StatelessWidget {
  final PairModel lessonModel;
  final Time time;

  const LessonWidget({Key? key, required this.time, required this.lessonModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            width: 48,
            decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: Colors.black38))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child: AutoSizeText(
                    time.start + '\n' + time.end,
                    textAlign: TextAlign.right,
                  ),
                ),
                const Divider(
                  color: Colors.black26,
                  thickness: 1,
                  height: 8,
                ),
                Expanded(
                  child: AutoSizeText(
                    '${lessonModel.toStringMap['room']}',
                    textAlign: TextAlign.right,
                    minFontSize: 4,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 10,
                    child: AutoSizeText(
                      lessonModel.toStringMap['name']!,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: AutoSizeText(
                        lessonModel.toStringMap['teacher']!,
                        minFontSize: 8,
                        softWrap: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyLessonWidget extends StatelessWidget {
  final Time time;

  const EmptyLessonWidget({Key? key, required this.time}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            width: 48,
            decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: Colors.black38))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child: AutoSizeText(
                    time.start + '\n' + time.end,
                    textAlign: TextAlign.right,
                  ),
                ),
                const Divider(
                  color: Colors.black26,
                  thickness: 0,
                  height: 8,
                ),
                Expanded(
                  child: Container(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
                child: Container(
              height: 1,
              width: 24,
              color: Colors.black26,
            )),
          )
        ],
      ),
    );
  }
}
