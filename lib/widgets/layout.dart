import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:mtkp/models.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

class OutlinedRadioGroup extends StatefulWidget {
  final Function(int _selectedIndex, int selectedDay, Month selectedMonth,
      int selectedWeek)? callback;
  final int startIndex;
  final int startWeek;

  const OutlinedRadioGroup(
      {Key? key,
      this.callback,
      required this.startIndex,
      required this.startWeek})
      : super(key: key);

  @override
  _OutlinedRadioGroupState createState() => _OutlinedRadioGroupState();
}

class _OutlinedRadioGroupState extends State<OutlinedRadioGroup> {
  final int _currentDay = Jiffy(DateTime.now()).dayOfYear;
  final int _currentWeek = Jiffy(DateTime.now()).week;
  late int _selectedIndex;
  late int _selectedWeek;
  late List<DateTime> _days;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.startIndex;
    _selectedWeek = widget.startWeek;

    _constructDays();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> radios = [
      for (var i = 0; i < _days.length; i++)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              border: Border.all(
                  color: _selectedIndex == i
                      ? Theme.of(context).primaryColorLight
                      : Colors.black54,
                  width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: () => setState(() {
                _selectedIndex = i;
                _sendCallback();
              }),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 8.0),
                child: AnimatedPadding(
                    padding: EdgeInsets.symmetric(
                        horizontal: _selectedIndex == i ? 10 : 4),
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    child: Text(Weekday.all[i].shortName + '\n${_days[i].day}',
                        style: Jiffy(_days[i]).dayOfYear == _currentDay
                            ? const TextStyle(
                                fontSize: 18, color: Color(0xFF2ec4b6))
                            : const TextStyle(fontSize: 18))),
              ),
              splashFactory: InkRipple.splashFactory,
            ),
          ),
        )
    ];

    var diff = _currentWeek - _selectedWeek;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            onPressed: diff < 2
                ? () => setState(() {
                      _selectedWeek--;
                      if (_selectedIndex == 0) _selectedIndex = 5;
                      _constructDays();
                      _sendCallback();
                    })
                : null,
            splashRadius: 18,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: Theme.of(context).primaryColorLight),
        ...radios,
        IconButton(
            onPressed: -diff < 2
                ? () => setState(() {
                      _selectedWeek++;
                      if (_selectedIndex == 5) _selectedIndex = 0;
                      _constructDays();
                      _sendCallback();
                    })
                : null,
            splashRadius: 18,
            icon: const Icon(Icons.arrow_forward_ios_rounded),
            color: Theme.of(context).primaryColorLight),
      ],
    );
  }

  void _sendCallback() => widget.callback?.call(
      _selectedIndex,
      _days[_selectedIndex].day,
      Month.all[_days[_selectedIndex].month - 1],
      _selectedWeek);

  void _constructDays() {
    var d =
        DateTime(DateTime.now().year).add(Duration(days: _selectedWeek * 7));
    int w = d.weekday;
    _days = [
      for (var i = 0; i < 6; i++)
        d.subtract(Duration(days: w - 1)).add(Duration(days: i))
    ];
  }
}

class GroupSelector extends StatelessWidget {
  final String selectedGroup;
  final List<String> options;
  final Function(String)? callback;
  const GroupSelector(
      {Key? key,
      required this.selectedGroup,
      required this.options,
      required this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColorLight),
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
            onTap: () => showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    title: const Text('Выберите группу',
                        style: TextStyle(color: Colors.white, fontSize: 22)),
                    backgroundColor: const Color.fromARGB(255, 69, 69, 69),
                    insetPadding: const EdgeInsets.all(60),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height - 200,
                        width: 300,
                        child: ListView.separated(
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(
                                  options[index],
                                  style: const TextStyle(color: Colors.white),
                                ),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  callback?.call(options[index]);
                                },
                              );
                            },
                            separatorBuilder: (context, index) => const Divider(
                                  color: Colors.grey,
                                  thickness: 1,
                                  height: 0,
                                ),
                            itemCount: options.length),
                      ),
                    ],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  );
                }),
            borderRadius: BorderRadius.circular(6),
            child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(selectedGroup),
                ))));
  }
}

class SlideTransitionDraft extends StatelessWidget {
  final Widget child;
  const SlideTransitionDraft({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (
          Widget child,
          Animation<double> primaryAnimation,
          Animation<double> secondaryAnimation,
        ) {
          var c = CurveTween(curve: Curves.easeOutCubic);
          primaryAnimation = primaryAnimation.drive(c);
          secondaryAnimation = secondaryAnimation.drive(c);
          return FadeTransition(
            opacity: ReverseAnimation(secondaryAnimation),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(0.0, -0.2),
              ).animate(secondaryAnimation),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset.zero,
                  end: const Offset(0.0, 0.4),
                ).animate(ReverseAnimation(primaryAnimation)),
                child: FadeTransition(
                  opacity: primaryAnimation,
                  child: child,
                ),
              ),
            ),
          );
        },
        child: child);
  }
}

class SharedAxisSwitcher extends StatelessWidget {
  final bool reverse;
  final Widget child;
  final SharedAxisTransitionType transitionType;
  const SharedAxisSwitcher(
      {Key? key,
      required this.child,
      required this.reverse,
      this.transitionType = SharedAxisTransitionType.vertical})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
        reverse: reverse,
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (
          Widget child,
          Animation<double> primaryAnimation,
          Animation<double> secondaryAnimation,
        ) {
          var c = CurveTween(curve: Curves.easeInOutCubic);
          primaryAnimation = primaryAnimation.drive(c);
          secondaryAnimation = secondaryAnimation.drive(c);
          return SharedAxisTransition(
            fillColor: Colors.transparent,
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            transitionType: transitionType,
            child: child,
          );
        },
        child: child);
  }
}

class ColoredTextButton extends StatelessWidget {
  final Function onPressed;
  final Color foregroundColor;
  final Color boxColor;
  final Color splashColor;
  final String text;
  final bool outlined;
  const ColoredTextButton(
      {Key? key,
      required this.onPressed,
      required this.text,
      required this.foregroundColor,
      required this.boxColor,
      this.splashColor = Colors.white,
      this.outlined = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () => onPressed.call(),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Text(text,
              style: TextStyle(color: foregroundColor, fontSize: 16)),
        ),
        style: outlined == true
            ? TextButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: boxColor),
                    borderRadius: BorderRadius.circular(8)),
                primary: splashColor)
            : TextButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: boxColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                primary: splashColor));
  }
}

class DatePreview extends StatelessWidget {
  final int selectedDay;
  final Month selectedMonth;
  final bool replacementSelected;
  final int selectedWeek;
  final Key? datePreviewKey;
  const DatePreview(
      {Key? key,
      required this.selectedDay,
      required this.selectedMonth,
      required this.replacementSelected,
      required this.selectedWeek,
      required this.datePreviewKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      decoration: BoxDecoration(
          color: Colors.black12, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: SlideTransitionDraft(
              child: AutoSizeText(
                '$selectedDay ${selectedMonth.ofName}' +
                    (replacementSelected ? ', Замены' : ''),
                key: datePreviewKey,
                textAlign: TextAlign.center,
                minFontSize: 8,
              ),
            ),
          ),
          Container(
            width: 1,
            color: Colors.black12,
          ),
          Expanded(
            child: SlideTransitionDraft(
              child: AutoSizeText(
                selectedWeek % 2 == 0 ? 'Нижняя неделя' : 'Верхняя неделя',
                key: ValueKey(selectedWeek),
                textAlign: TextAlign.center,
                minFontSize: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReplacementSelection extends StatelessWidget {
  final Color sheduleColor;
  final Color replacementColor;
  final int replacementState;
  final bool isReplacementSelected;
  final Function callback;
  const ReplacementSelection(
      {Key? key,
      required this.sheduleColor,
      required this.replacementColor,
      required this.replacementState,
      required this.isReplacementSelected,
      required this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: const BoxConstraints.expand(),
            decoration: BoxDecoration(
              border: Border.all(
                  color:
                      isReplacementSelected ? replacementColor : sheduleColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
                onTap: () => callback(),
                borderRadius: BorderRadius.circular(6),
                child: Stack(alignment: Alignment.center, children: [
                  SlideTransitionDraft(
                    child: AutoSizeText(
                      isReplacementSelected
                          ? 'Смотреть расписание'
                          : 'Смотреть замены',
                      key: ValueKey(isReplacementSelected),
                      minFontSize: 8,
                    ),
                  ),
                  if (replacementState == 0)
                    Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 8),
                        child: const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 3, color: Colors.white)))
                ])),
          ),
        ),
      ],
    );
  }
}

class ScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices =>
      {PointerDeviceKind.touch, PointerDeviceKind.mouse};
}

showTextSnackBar(BuildContext context, String text, int milliseconds) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(text),
    behavior: SnackBarBehavior.floating,
    duration: Duration(milliseconds: milliseconds),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ));
}
