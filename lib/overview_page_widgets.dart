part of 'overview_page.dart';

Widget buildEmptyReplacements(
        BuildContext context,
        int loadingState,
        Tuple2<SimpleDate, List<PairModel?>?>? selectedReplacement,
        Function retryAction) =>
    Center(
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

Widget buildEmptyWelcome(bool loading) => Padding(
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

Widget buildDatePreview(int selectedDay, Month selectedMonth,
        bool replacementSelected, int selectedWeek, Key datePreviewKey) =>
    Container(
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

Widget buildReplacementSelection(Color sheduleColor, Color replacementColor,
        int replacementState, bool isReplacementSelected, Function callback) =>
    Row(
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
