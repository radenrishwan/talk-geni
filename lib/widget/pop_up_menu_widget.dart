import 'package:flutter/material.dart';
import 'package:gemini_chat/model/model.dart';
import 'package:gemini_chat/screen/model_setting_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PopUpValue {
  none,
  setAPIKey,
  setModelConfig,
  clearConversation,
}

class PopUpMenuWidget extends StatelessWidget {
  final ValueNotifier<String> apiKey;
  final ValueNotifier<List<Content>> listChat;

  const PopUpMenuWidget(this.listChat, this.apiKey, {super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController();

    return PopupMenuButton(
      initialValue: PopUpValue.none,
      onSelected: (value) {
        switch (value) {
          case PopUpValue.setAPIKey:
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text(
                      'Set API Key',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    content: TextField(
                      controller: textController,
                      decoration: const InputDecoration(
                        hintText: 'input your api key',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          apiKey.value = textController.text;
                          SharedPreferences.getInstance().then((value) {
                            value.setString('api_key', apiKey.value);
                            Navigator.pop(context);
                          });
                        },
                        child: const Text('Ok'),
                      )
                    ],
                  );
                });
            break;
          case PopUpValue.setModelConfig:
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return const ModelSettingScreen();
            }));
            break;
          case PopUpValue.clearConversation:
            listChat.value = [];
            break;
          default:
            break;
        }
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem(
            value: PopUpValue.setAPIKey,
            child: Text('Set API Key'),
          ),
          const PopupMenuItem(
            value: PopUpValue.setModelConfig,
            child: Text('Set model config'),
          ),
          const PopupMenuItem(
            value: PopUpValue.clearConversation,
            child: Text('Clear conversation'),
          ),
        ];
      },
    );
  }
}
