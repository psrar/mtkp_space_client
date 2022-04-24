import 'package:auto_size_text/auto_size_text.dart';
import 'package:mtkp/models.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mtkp/main.dart' as app_global;

import 'layout.dart' show ColoredTextButton;

AutoSizeGroup _sizeGroup = AutoSizeGroup();

class SheduleContentWidget extends StatelessWidget {
  final Tuple2<Timetable, List<PairModel?>?> dayShedule;
  final void Function(String classroom) onClassroomTap;

  const SheduleContentWidget(
      {Key? key, required this.dayShedule, required this.onClassroomTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var lessonsWidgetList = <Widget>[];
    var timetable = dayShedule.item1;
    var lessons = dayShedule.item2;
    if (lessons != null && lessons.every((element) => element == null)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Icon(Icons.cake_rounded,
                color: app_global.accessColor, size: 74),
            Text(
              'Выходной!',
              style: app_global.headerFont,
            ),
            ColoredTextButton(
              text: 'Проверить самостоятельно',
              onPressed: () async => await launch('https://vk.com/mtkp_bmstu'),
              foregroundColor: Colors.white,
              boxColor: app_global.accessColor,
              splashColor: app_global.accessColor,
              outlined: true,
            ),
          ],
        ),
      );
    }

    for (var i = 0; i < 6; i++) {
      var time = timetable.all[i + 1];
      if (lessons != null && i < lessons.length) {
        if (lessons[i] == null) {
          lessonsWidgetList.add(EmptyLessonWidget(time: time!));
        } else {
          lessonsWidgetList.add(LessonWidget(
              time: time!,
              lessonModel: lessons[i]!,
              onClassroomTap: onClassroomTap));
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
            color: Colors.black26,
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

  final void Function(String classroom) onClassroomTap;

  const LessonWidget(
      {Key? key,
      required this.time,
      required this.lessonModel,
      required this.onClassroomTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            width: 56,
            decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: Colors.black26))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 4,
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
                  flex: 3,
                  child: InkWell(
                    onTap: () => onClassroomTap('${lessonModel.roomReadable}'),
                    child: AutoSizeText(
                      '${lessonModel.roomReadable}',
                      textAlign: TextAlign.right,
                      minFontSize: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 10,
                    child: AutoSizeText(
                      lessonModel.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                      minFontSize: 8,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 4,
                      group: _sizeGroup,
                    ),
                  ),
                  Expanded(flex: 1, child: Container()),
                  Expanded(
                    flex: 4,
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: AutoSizeText(
                        lessonModel.teacherReadable,
                        style: const TextStyle(fontSize: 100),
                        maxFontSize: 18,
                        overflow: TextOverflow.fade,
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
            width: 56,
            decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: Colors.black26))),
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
