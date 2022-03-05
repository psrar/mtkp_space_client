part of 'overview_page.dart';

class EmptyReplacements extends StatelessWidget {
  final BuildContext context;
  final int loadingState;
  final Tuple2<SimpleDate, List<PairModel?>?>? selectedReplacement;
  final Function retryAction;
  const EmptyReplacements(
      {Key? key,
      required this.context,
      required this.loadingState,
      required this.selectedReplacement,
      required this.retryAction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        loadingState == 0 && selectedReplacement == null
            ? Column(children: const [
                Text('Мы загружаем ваши замены'),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8.0),
                  child: LinearProgressIndicator(),
                ),
              ])
            : Text(
                loadingState == 2
                    ? 'Не удалось получить замены'
                    : selectedReplacement == null
                        ? 'Замен на этот день не обнаружено'
                        : 'Для вашей группы нет замен на этот день',
                style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 12),
        layout.ColoredTextButton(
          text: 'Проверить самостоятельно',
          onPressed: () async =>
              await url_launcher.launch('https://vk.com/mtkp_bmstu'),
          foregroundColor: Colors.white,
          boxColor: appGlobal.errorColor,
          splashColor: appGlobal.errorColor,
          outlined: true,
        ),
        const SizedBox(height: 12),
        layout.ColoredTextButton(
          text: 'Попробовать снова',
          onPressed: retryAction,
          foregroundColor: Colors.white,
          boxColor: appGlobal.focusColor,
          splashColor: appGlobal.focusColor,
          outlined: true,
        ),
      ],
    ));
  }
}

class EmptyWelcome extends StatelessWidget {
  final bool loading;
  const EmptyWelcome({Key? key, required this.loading}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Center(
          child: Text(
        loading
            ? 'Загружается список групп...'
            : 'Выберите группу, чтобы посмотреть её расписание',
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      )),
    );
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
            child: layout.SlideTransitionDraft(
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
            child: layout.SlideTransitionDraft(
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
                  layout.SlideTransitionDraft(
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
