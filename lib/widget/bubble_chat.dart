import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/atom-one-light.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gemini_chat/model/model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown/markdown.dart' as md;

class SyntaxHighligtherBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    var language = '';

    if (element.attributes['class'] != null) {
      String lg = element.attributes['class'] as String;
      language = lg.substring(9);
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
      ),
      child: HighlightView(
        element.textContent.trim(),
        language: language,
        theme: atomOneLightTheme,
        textStyle: GoogleFonts.jetBrainsMono(),
        padding: const EdgeInsets.all(4),
      ),
    );
  }
}

class BubbleChat extends StatelessWidget {
  final Parts parts;
  final InlineData? inlineData;
  final bool isReply;

  const BubbleChat({
    super.key,
    this.isReply = false,
    this.inlineData,
    required this.parts,
  });

  @override
  Widget build(BuildContext context) {
    final content = [
      const CircleAvatar(
        radius: 20.0,
      ),
      const SizedBox(width: 8.0),
      Column(
        crossAxisAlignment:
            isReply ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(
            isReply ? 'You' : 'Gemini AI',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xff61b095),
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.all(8.0),
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ...inlineData != null
                    ? [
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: Image.memory(
                                    base64Decode(inlineData!.data),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Placeholder(
                                        fallbackHeight: 200.0,
                                        fallbackWidth: 200.0,
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.memory(
                              base64Decode(inlineData!.data),
                              fit: BoxFit.cover,
                              height: 200,
                              width: 200,
                              errorBuilder: (context, error, stackTrace) {
                                return const Placeholder(
                                  fallbackHeight: 200.0,
                                  fallbackWidth: 200.0,
                                );
                              },
                            ),
                          ),
                        )
                      ]
                    : [
                        const SizedBox(),
                      ],
                MarkdownBody(
                  data: parts.text,
                  softLineBreak: true,
                  listItemCrossAxisAlignment:
                      MarkdownListItemCrossAxisAlignment.baseline,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  builders: {
                    'code': SyntaxHighligtherBuilder(),
                  },
                  shrinkWrap: true,
                  selectable: true,
                ),
              ],
            ),
          ),
        ],
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: isReply ? content : content.reversed.toList(),
      ),
    );
  }
}
