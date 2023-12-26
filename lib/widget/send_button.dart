import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gemini_chat/model/model.dart';

class SendButton extends StatelessWidget {
  final VoidCallback onSendMessage;
  final VoidCallback onUploadFile;
  final ValueNotifier<bool> isLoading;
  final ValueNotifier<InlineData?> inlineData;
  final TextEditingController textController;

  const SendButton({
    super.key,
    required this.onSendMessage,
    required this.onUploadFile,
    required this.isLoading,
    required this.textController,
    required this.inlineData,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = ValueNotifier(true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder(
          valueListenable: isLoading,
          builder: (context, value, _) {
            return Visibility(
              visible: value,
              child: LinearProgressIndicator(
                minHeight: 2.0,
                color: Colors.green.shade400,
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.green.shade200,
                ),
              ),
            );
          },
        ),
        ValueListenableBuilder(
          valueListenable: inlineData,
          builder: (context, value, _) {
            if (value == null) {
              return const SizedBox();
            }

            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.memory(
                      base64Decode(value.data),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: -4,
                  right: -4,
                  child: IconButton.filled(
                    iconSize: 12,
                    onPressed: () {
                      inlineData.value = null;
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            );
          },
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          child: Row(
            children: [
              IconButton(
                onPressed: onUploadFile,
                icon: const Icon(Icons.attach_file),
              ),
              Expanded(
                child: TextField(
                  enabled: !isLoading.value,
                  controller: textController,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      isEmpty.value = true;
                    } else {
                      isEmpty.value = false;
                    }
                  },
                  onSubmitted: (value) {
                    if (value.isEmpty) {
                      return;
                    }

                    onSendMessage.call();
                  },
                  textInputAction: TextInputAction.send,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                      borderSide: BorderSide.none,
                    ),
                    labelText: 'Type message here',
                  ),
                  maxLines: 3,
                  minLines: 1,
                ),
              ),
              const SizedBox(width: 8.0),
              ValueListenableBuilder(
                  valueListenable: isEmpty,
                  builder: (context, value, _) {
                    return ElevatedButton(
                      onPressed: value ? null : onSendMessage,
                      child: const Text('Send'),
                    );
                  }),
            ],
          ),
        ),
      ],
    );
  }
}
