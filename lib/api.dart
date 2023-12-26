import 'package:dio/dio.dart';
import 'package:gemini_chat/model/model.dart';

class Api {
  final endpoint = "https://generativelanguage.googleapis.com/v1beta";

  Future<Content> sendMessage(List<Content> contents, String apiKey) async {
    Dio dio = Dio();

    var resultEndpoint = '';
    // check if contents has inline data
    if (contents[0].inlineData != null) {
      resultEndpoint = "$endpoint/models/gemini-pro-vision:generateContent";
    } else {
      resultEndpoint = "$endpoint/models/gemini-pro:generateContent";
    }

    final body = {
      "contents": [
        contents.map((e) => e.toJson()).toList(),
      ],
    };

    final result = await dio.post(
      resultEndpoint,
      queryParameters: {
        "key": apiKey,
      },
      data: body,
    );

    return Content.fromJson(result.data['candidates'][0]['content']);
  }
}
