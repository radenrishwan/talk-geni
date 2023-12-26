import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModelSettingStatic {
  static const modelInstructionKey = 'model_instruction';
  static const stopSequenceKey = 'stop_sequence';

  static const temperatureKey = 'temperature';
  static const harassmentKey = 'harassment';
  static const hateSpeechKey = 'hate_speech';
  static const sexualityExplicitKey = 'sexuality_explicit';
  static const dangerousContentKey = 'dangerous_content';
}

class ModelSettingScreen extends StatefulWidget {
  const ModelSettingScreen({super.key});

  @override
  State<ModelSettingScreen> createState() => _ModelSettingScreenState();
}

class _ModelSettingScreenState extends State<ModelSettingScreen> {
  final modelInstructionController = TextEditingController();
  final stopSequenceController = TextEditingController();

  final ValueNotifier isLoadSetting = ValueNotifier(false);
  final ValueNotifier<double> temperatureValue = ValueNotifier(0.5);
  final ValueNotifier<double> harassmentValue = ValueNotifier(0.5);
  final ValueNotifier<double> hateSpeechValue = ValueNotifier(0.5);
  final ValueNotifier<double> sexualityExplicitValue = ValueNotifier(0.5);
  final ValueNotifier<double> dangerousContentValue = ValueNotifier(0.5);

  @override
  void initState() {
    isLoadSetting.value = true;
    SharedPreferences.getInstance().then((value) {
      modelInstructionController.text =
          value.getString(ModelSettingStatic.modelInstructionKey) ?? '';
      stopSequenceController.text =
          value.getString(ModelSettingStatic.stopSequenceKey) ?? '';

      temperatureValue.value =
          value.getDouble(ModelSettingStatic.temperatureKey) ?? 0.9;
      harassmentValue.value =
          value.getDouble(ModelSettingStatic.harassmentKey) ?? 0.5;
      hateSpeechValue.value =
          value.getDouble(ModelSettingStatic.hateSpeechKey) ?? 0.5;
      sexualityExplicitValue.value =
          value.getDouble(ModelSettingStatic.sexualityExplicitKey) ?? 0.5;
      dangerousContentValue.value =
          value.getDouble(ModelSettingStatic.dangerousContentKey) ?? 0.5;

      isLoadSetting.value = false;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final sharedPreferences = SharedPreferences.getInstance();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Model Setting'),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([isLoadSetting]),
        builder: (context, _) {
          if (isLoadSetting.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildTitle(
                        context,
                        title: 'Model Instruction',
                        icon: const Icon(Icons.info_outline),
                      ),
                      TextField(
                        controller: modelInstructionController,
                        onChanged: (instruction) {
                          sharedPreferences.then((value) {
                            value.setString(
                              ModelSettingStatic.modelInstructionKey,
                              instruction,
                            );
                          });
                        },
                        maxLines: 3,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(8),
                          isDense: true,
                          hintText:
                              'You always say hello at the start of the conversation',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      buildTitle(
                        context,
                        title: 'Temperature',
                        icon: const Icon(Icons.thermostat_rounded),
                      ),
                      ValueListenableBuilder(
                        valueListenable: temperatureValue,
                        builder: (context, value, _) {
                          return Slider(
                            value: value,
                            onChanged: (now) {
                              temperatureValue.value = now;
                              sharedPreferences.then((value) {
                                value.setDouble(
                                  ModelSettingStatic.temperatureKey,
                                  now,
                                );
                              });
                            },
                          );
                        },
                      ),
                      buildTitle(
                        context,
                        title: 'Stop Sequence',
                        icon: const Icon(Icons.stop_circle_outlined),
                      ),
                      TextField(
                        controller: stopSequenceController,
                        onChanged: (sequence) {
                          sharedPreferences.then((value) {
                            value.setString(
                              ModelSettingStatic.stopSequenceKey,
                              sequence,
                            );
                          });
                        },
                        maxLines: 1,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(8),
                          isDense: true,
                          hintText: 'add stop sequence here...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      buildTitle(
                        context,
                        title: 'Safety Setting',
                        icon: const Icon(Icons.health_and_safety),
                      ),
                      buildSafetySetting(
                        title: 'Harassment',
                        value: harassmentValue,
                        onChanged: () {
                          sharedPreferences.then((value) {
                            value.setDouble(
                              ModelSettingStatic.harassmentKey,
                              harassmentValue.value,
                            );
                          });
                        },
                      ),
                      buildSafetySetting(
                        title: 'Hate Speech',
                        value: hateSpeechValue,
                        onChanged: () {
                          sharedPreferences.then((value) {
                            value.setDouble(
                              ModelSettingStatic.hateSpeechKey,
                              hateSpeechValue.value,
                            );
                          });
                        },
                      ),
                      buildSafetySetting(
                        title: 'Sexuality Explicit',
                        value: sexualityExplicitValue,
                        onChanged: () {
                          sharedPreferences.then((value) {
                            value.setDouble(
                              ModelSettingStatic.sexualityExplicitKey,
                              sexualityExplicitValue.value,
                            );
                          });
                        },
                      ),
                      buildSafetySetting(
                        title: 'Dangerous Content',
                        value: dangerousContentValue,
                        onChanged: () {
                          sharedPreferences.then((value) {
                            value.setDouble(
                              ModelSettingStatic.dangerousContentKey,
                              dangerousContentValue.value,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildSafetySetting({
    required final String title,
    required final ValueNotifier<double> value,
    required final VoidCallback onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(title),
          ),
          ValueListenableBuilder(
            valueListenable: value,
            builder: (context, current, _) {
              return Slider(
                value: current,
                onChanged: (now) {
                  value.value = now;
                  onChanged.call();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildTitle(
    BuildContext context, {
    required final String title,
    required final Widget icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
