import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mtkp/main.dart' as appGlobal;
import 'package:mtkp/widgets/layout.dart';
import 'package:mtkp/workers/background_worker.dart' as bw;
import 'package:mtkp/settings_model.dart';
import 'package:optimize_battery/optimize_battery.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _isBackgroundWorkEnabled =
      appGlobal.settings['background_enabled'] ?? false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColoredTextButton(
                onPressed: () async {
                  try {
                    if (kIsWeb) {
                      Fluttertoast.showToast(msg: 'Доступно только на Android');
                    } else {
                      await OptimizeBattery.stopOptimizingBatteryUsage();
                    }
                  } finally {
                    showDialog(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: const Text('Про работу в фоновом режиме'),
                        titlePadding: const EdgeInsets.all(20),
                        backgroundColor: const Color.fromARGB(255, 69, 69, 69),
                        contentPadding: const EdgeInsets.all(18),
                        children: [
                          SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                    '    Данное приложение может работать в фоновом режиме (даже когда вы закрыли его), чтобы отправлять вам уведомления о заменах и другие важные сообщения.\n    Хотя вы, вероятно, только что разрешили приложению работу в фоне и отключили оптимизацию батареи для него, многие производители оболочек на основе Android используют собственные решения для ограничения фоновой работы. Среди них: Samsung, OnePlus, Xiaomi, Huawei, Honor и многие другие. Для того, чтобы пользователям данных устройств приходили уведомления, необходимо провести дополнительную настройку. Это распространённая практика, и существует много руководств, объясняющих, как это сделать. Они приведены в конце заметки. Помимо ссылок на руководства, ниже приведено описание действий для устройств, которые я уже протестировал.',
                                    style: TextStyle(fontSize: 14)),
                                const Text('Почему так произошло?',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                const Text(
                                    '    Я очень извиняюсь за ту мороку, которую вызывает принятое мной решение. Поскольку у МТКП Space нет серверов для обработки данных, небольшая часть работы выполняется на вашем устройстве. Самым распространённым решением являлась служба Firebase Cloud Messaging, которая, однако, на момент разработки не позволяет завести российский платежный аккаунт.\n    Над оптимизацией фоновой работы приложения проводится кропотливая работа, так что вы не должны столкнуться с каким-либо ощутимым потреблением ресурсов батареи и трафика. Если же такое произошло, вы всегда можете отключить функцию и связаться со мной для скорейшего исправления ошибки.',
                                    style: TextStyle(fontSize: 14)),
                                const SizedBox(height: 18),
                                const Text('Xiaomi MIUI',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                const SizedBox(height: 4),
                                const Text(
                                    'Откройте настройки - Перейдите в пункт "Приложения" - "Все приложения" - Найдите приложение "МТКП Space" - Включите параметр "Автозапуск" - Далее выберите параметр "Контроль активности" и установите значение "Нет ограничений" - Желательно перезагрузить устройство и перезапустить приложение.',
                                    style: TextStyle(fontSize: 14)),
                                const SizedBox(height: 8),
                                const Text('Huawei EMUI',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                const SizedBox(height: 4),
                                const Text(
                                    'Откройте настройки - выберите пункт "Батарея" - "Запуск приложений" - Найдите приложение "МТКП Space" - Выключите параметр "Автоматическое управление", во всплывающем окне оставьте включёнными параметры "Автозапуск" и "Работа в фоновом режиме" - Желательно перезагрузить устройство и перезапустить приложение.',
                                    style: TextStyle(fontSize: 14)),
                                const SizedBox(height: 18),
                                InkWell(
                                    onTap: () async => await url_launcher.launch(
                                        'https://intercom.help/Wheely-help/ru/articles/4294782-%D0%BA%D0%B0%D0%BA-%D0%BE%D1%82%D0%BA%D0%BB%D1%8E%D1%87%D0%B8%D1%82%D1%8C-%D0%BE%D0%BF%D1%82%D0%B8%D0%BC%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8E-%D1%80%D0%B0%D1%81%D1%85%D0%BE%D0%B4%D0%B0-%D0%B1%D0%B0%D1%82%D0%B0%D1%80%D0%B5%D0%B8-%D0%BD%D0%B0-android-%D1%83%D1%81%D1%82%D1%80%D0%BE%D0%B9%D1%81%D1%82%D0%B2%D0%B0%D1%85'),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                          'Руководство по отключению оптимизации батареи на русском языке (Xiaomi, Huawei, Samsung, Asus)',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.lightBlue)),
                                    )),
                                const SizedBox(height: 8),
                                InkWell(
                                    onTap: () async => await url_launcher
                                        .launch('https://dontkillmyapp.com/'),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                          'Dontkillmyapp: Руководство на английском языке и специализированный на данной проблеме сайт для всех производителей устройств',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.lightBlue)),
                                    )),
                                const SizedBox(height: 18),
                                ColoredTextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    text: 'Я все прочитал(а)',
                                    foregroundColor: Colors.white,
                                    boxColor: Colors.blue)
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
                text:
                    'Разрешить приложению работать в фоне для получения уведомлений',
                foregroundColor: Colors.white,
                boxColor: appGlobal.primaryColor),
            const SizedBox(height: 18),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                  color: _isBackgroundWorkEnabled
                      ? Colors.green
                      : appGlobal.errorColor,
                  borderRadius: BorderRadius.circular(8)),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                child: ColoredTextButton(
                  onPressed: () async {
                    if (!kIsWeb) {
                      if (_isBackgroundWorkEnabled) {
                        bw.stopShedule();
                        setState(() => _isBackgroundWorkEnabled = false);
                      } else {
                        bw.startShedule();
                        setState(() => _isBackgroundWorkEnabled = true);
                      }
                      await saveSettings(
                          {'background_enabled': _isBackgroundWorkEnabled});
                    } else {
                      Fluttertoast.showToast(msg: 'Доступно только на Android');
                    }
                  },
                  text: _isBackgroundWorkEnabled
                      ? 'Фоновая проверка замен включена'
                      : 'Включить фоновую проверку замен',
                  boxColor: Colors.transparent,
                  foregroundColor: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
