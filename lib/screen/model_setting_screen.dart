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
  final TextEditingController modelInstructionController;
  final TextEditingController stopSequenceController;
  final ValueNotifier isLoadSetting;
  final ValueNotifier<double> temperatureValue;
  final ValueNotifier<double> harassmentValue;
  final ValueNotifier<double> hateSpeechValue;
  final ValueNotifier<double> sexualityExplicitValue;
  final ValueNotifier<double> dangerousContentValue;

  const ModelSettingScreen({
    super.key,
    required this.modelInstructionController,
    required this.stopSequenceController,
    required this.isLoadSetting,
    required this.temperatureValue,
    required this.harassmentValue,
    required this.hateSpeechValue,
    required this.sexualityExplicitValue,
    required this.dangerousContentValue,
  });

  @override
  State<ModelSettingScreen> createState() => _ModelSettingScreenState();
}

class _ModelSettingScreenState extends State<ModelSettingScreen> {
  final ValueNotifier isLoadSetting = ValueNotifier(false);

  @override
  void initState() {
    isLoadSetting.value = true;
    SharedPreferences.getInstance().then((value) {
      widget.modelInstructionController.text =
          value.getString(ModelSettingStatic.modelInstructionKey) ?? '';
      widget.stopSequenceController.text =
          value.getString(ModelSettingStatic.stopSequenceKey) ?? '';

      widget.temperatureValue.value =
          value.getDouble(ModelSettingStatic.temperatureKey) ?? 0.9;
      widget.harassmentValue.value =
          value.getDouble(ModelSettingStatic.harassmentKey) ?? 0.5;
      widget.hateSpeechValue.value =
          value.getDouble(ModelSettingStatic.hateSpeechKey) ?? 0.5;
      widget.sexualityExplicitValue.value =
          value.getDouble(ModelSettingStatic.sexualityExplicitKey) ?? 0.5;
      widget.dangerousContentValue.value =
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
        actions: [
          IconButton(
            onPressed: () {
              // reset the model setting
              sharedPreferences.then((value) {
                value.remove(ModelSettingStatic.modelInstructionKey);
                value.remove(ModelSettingStatic.stopSequenceKey);
                value.remove(ModelSettingStatic.temperatureKey);
                value.remove(ModelSettingStatic.harassmentKey);
                value.remove(ModelSettingStatic.hateSpeechKey);
                value.remove(ModelSettingStatic.sexualityExplicitKey);
                value.remove(ModelSettingStatic.dangerousContentKey);
              });

              widget.modelInstructionController.text = '';
              widget.stopSequenceController.text = '';
              widget.temperatureValue.value = 0.9;
              widget.harassmentValue.value = 0.5;
              widget.hateSpeechValue.value = 0.5;
              widget.sexualityExplicitValue.value = 0.5;
              widget.dangerousContentValue.value = 0.5;
            },
            icon: const Icon(Icons.replay_outlined),
          ),
        ],
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
                        controller: widget.modelInstructionController,
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
                        valueListenable: widget.temperatureValue,
                        builder: (context, value, _) {
                          return Slider(
                            value: value,
                            onChanged: (now) {
                              widget.temperatureValue.value = now;
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
                        controller: widget.stopSequenceController,
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
                        value: widget.harassmentValue,
                        onChanged: () {
                          sharedPreferences.then((value) {
                            value.setDouble(
                              ModelSettingStatic.harassmentKey,
                              widget.harassmentValue.value,
                            );
                          });
                        },
                      ),
                      buildSafetySetting(
                        title: 'Hate Speech',
                        value: widget.hateSpeechValue,
                        onChanged: () {
                          sharedPreferences.then((value) {
                            value.setDouble(
                              ModelSettingStatic.hateSpeechKey,
                              widget.hateSpeechValue.value,
                            );
                          });
                        },
                      ),
                      buildSafetySetting(
                        title: 'Sexuality Explicit',
                        value: widget.sexualityExplicitValue,
                        onChanged: () {
                          sharedPreferences.then((value) {
                            value.setDouble(
                              ModelSettingStatic.sexualityExplicitKey,
                              widget.sexualityExplicitValue.value,
                            );
                          });
                        },
                      ),
                      buildSafetySetting(
                        title: 'Dangerous Content',
                        value: widget.dangerousContentValue,
                        onChanged: () {
                          sharedPreferences.then((value) {
                            value.setDouble(
                              ModelSettingStatic.dangerousContentKey,
                              widget.dangerousContentValue.value,
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
