import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mtkp/main.dart' as appGlobal;
import 'package:mtkp/widgets/layout.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:mtkp/workers/background_worker.dart' as bw;
import 'package:mtkp/settings_model.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _isBackgroundWorkEnabled = false;

  @override
  void initState() {
    super.initState();

    loadSettings().then((value) =>
        setState(() => _isBackgroundWorkEnabled = value['background_enabled']));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ColoredTextButton(
                  onPressed: () async {
                    if (kIsWeb) {
                      Fluttertoast.showToast(msg: 'Доступно только на Android');
                    } else {
                      await DisableBatteryOptimization
                          .showDisableBatteryOptimizationSettings();
                      var batteryOptimizationDisabled =
                          await DisableBatteryOptimization
                              .isAllBatteryOptimizationDisabled;
                      if (batteryOptimizationDisabled != null &&
                          batteryOptimizationDisabled == false) {
                        await DisableBatteryOptimization
                            .showDisableManufacturerBatteryOptimizationSettings(
                                'Ваше устройство блокирует фоновую работу приложения',
                                'Пожалуйста, разрешите работу приложения в фоне. Это необходимо только для фоновой проверки замен и получения важных уведомлений. Отключить функцию можно будет в любое время в настройках приложения.');
                      } else {
                        Fluttertoast.showToast(msg: 'Все уже готово!');
                      }
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
                      if (_isBackgroundWorkEnabled) {
                        bw.stopShedule();
                        setState(() => _isBackgroundWorkEnabled = false);
                      } else {
                        bw.startShedule();
                        setState(() => _isBackgroundWorkEnabled = true);
                      }
                      await saveSettings(
                          {'background_enabled': _isBackgroundWorkEnabled});
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
      ],
    );
  }
}
