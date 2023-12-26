import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gemini_chat/api.dart';
import 'package:gemini_chat/model/model.dart';
import 'package:gemini_chat/screen/model_setting_screen.dart';
import 'package:gemini_chat/widget/message_body.dart';
import 'package:gemini_chat/widget/pop_up_menu_widget.dart';
import 'package:gemini_chat/widget/send_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final modelInstructionController = TextEditingController();
  final stopSequenceController = TextEditingController();

  final apiKey = ValueNotifier('');
  final isApiKeyLoading = ValueNotifier(false);
  final listChat = ValueNotifier(<Content>[]);
  final isLoading = ValueNotifier(false);
  final inlineData = ValueNotifier<InlineData?>(null);
  final scrollController = ScrollController();
  final textController = TextEditingController();

  final isLoadSetting = ValueNotifier(false);
  final temperatureValue = ValueNotifier(0.5);
  final harassmentValue = ValueNotifier(0.5);
  final hateSpeechValue = ValueNotifier(0.5);
  final sexualityExplicitValue = ValueNotifier(0.5);
  final dangerousContentValue = ValueNotifier(0.5);

  @override
  void initState() {
    isApiKeyLoading.value = true;
    SharedPreferences.getInstance().then((value) {
      final apiKey = value.getString('api_key') ?? '';

      this.apiKey.value = apiKey;

      // setting up the model
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

      isApiKeyLoading.value = false;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Gemini AI'),
        centerTitle: true,
        actions: [
          PopUpMenuWidget(
            listChat,
            apiKey,
            modelInstructionController: modelInstructionController,
            stopSequenceController: stopSequenceController,
            isLoadSetting: isLoadSetting,
            temperatureValue: temperatureValue,
            harassmentValue: harassmentValue,
            hateSpeechValue: hateSpeechValue,
            sexualityExplicitValue: sexualityExplicitValue,
            dangerousContentValue: dangerousContentValue,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([apiKey, isApiKeyLoading]),
        builder: (context, _) {
          if (isApiKeyLoading.value == true) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (apiKey.value == '') {
            return Center(
              child: RichText(
                text: TextSpan(children: [
                  const TextSpan(
                    text: 'Please set your API Key on top right\n',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: 'you can click here to get API Key',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        if (!await launchUrl(Uri.parse(
                            'https://makersuite.google.com/app/apikey'))) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to open url'),
                              ),
                            );
                          }
                        }
                      },
                    style: const TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ]),
              ),
            );
          }

          return MessageBody(
            scrollController: scrollController,
            listChat: listChat,
            // sharedPreferences: future.data!,
          );
        },
      ),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: apiKey,
        builder: (context, value, _) {
          if (apiKey.value == '') {
            return const SizedBox();
          }
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: SendButton(
              onSendMessage: () async {
                await onSendMessage(
                  beforeSendMessage: () {
                    FocusScope.of(context).unfocus();
                  },
                );
              },
              onUploadFile: () {
                onUploadFile();
              },
              isLoading: isLoading,
              inlineData: inlineData,
              textController: textController,
            ),
          );
        },
      ),
    );
  }

  onUploadFile() async {
    final file = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],
      allowMultiple: false,
      withData: true,
    );

    if (file != null) {
      // compress image
      final result = file.files.first;

      final compressImage = await FlutterImageCompress.compressWithFile(
        result.path!,
        quality: 30,
      );

      // TODO: convert image into png
      final base64 = base64Encode(compressImage!.toList());
      inlineData.value = InlineData(
        mimeType: 'image/png',
        data: base64,
      );
    }
  }

  onSendMessage({VoidCallback? beforeSendMessage}) async {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    final text = textController.text;

    try {
      final message = Content(
        role: 'user',
        inlineData: inlineData.value,
        parts: [
          Parts(
            text: text,
          ),
        ],
      );

      listChat.value = [...listChat.value, message];

      textController.clear();
      isLoading.value = true;
      inlineData.value = null;

      beforeSendMessage?.call();

      final api = Api();

      final reply = await api.sendMessage(listChat.value, apiKey.value);

      listChat.value = [...listChat.value, reply];
      isLoading.value = false;

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage =
            (e.response!.data as Map<String, dynamic>)['error']['message'];

        listChat.value = [
          ...listChat.value,
          Content(
            role: 'gemini',
            parts: [
              Parts(
                text:
                    'Look like something went wrong, here is message from gugel: ```${errorMessage ?? 'unknown error'}```. \n\n if you got error **Multiturn chat is not enabled for models/gemini-pro-vision**, you need to clear conversation by click restart button on top right.',
              ),
            ],
          ),
        ];
      }

      isLoading.value = false;

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      log("error: $e");
    } catch (e) {
      log("error: $e");
    }
  }
}
