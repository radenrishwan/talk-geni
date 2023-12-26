import 'package:flutter/material.dart';
import 'package:gemini_chat/model/model.dart';
import 'package:gemini_chat/widget/bubble_chat.dart';

class MessageBody extends StatelessWidget {
  // final SharedPreferences sharedPreferences;
  final ValueNotifier<List<Content>> listChat;
  final ScrollController scrollController;

  const MessageBody({
    super.key,
    required this.listChat,
    required this.scrollController,
    // required this.sharedPreferences,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        controller: scrollController,
        child: ValueListenableBuilder(
          valueListenable: listChat,
          builder: (context, value, _) {
            return Column(
              children: List.generate(value.length, (index) {
                final content = value[index];

                return BubbleChat(
                  isReply: content.role == 'user',
                  parts: content.parts[0],
                  inlineData: content.inlineData,
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
