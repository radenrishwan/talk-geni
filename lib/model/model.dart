class InlineData {
  final String mimeType;
  final String data;

  InlineData({
    required this.mimeType,
    required this.data,
  });

  factory InlineData.fromJson(Map<String, dynamic> json) {
    return InlineData(
      mimeType: json['mime_type'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() => {
        'mime_type': mimeType,
        'data': data,
      };

  @override
  String toString() {
    return 'InlineData{mimeType: $mimeType, data: $data}';
  }

  InlineData copyWith({
    String? mimeType,
    String? data,
  }) {
    return InlineData(
      mimeType: mimeType ?? this.mimeType,
      data: data ?? this.data,
    );
  }
}

class Parts {
  final String text;

  Parts({
    required this.text,
  });

  factory Parts.fromJson(Map<String, dynamic> json) {
    return Parts(
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
      };

  @override
  String toString() {
    return 'Parts{text: $text}';
  }
}

class Content {
  final String role;
  final List<Parts> parts;
  final InlineData? inlineData;

  Content({
    required this.role,
    required this.parts,
    this.inlineData,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      role: json['role'],
      parts: json['parts']
          .map<Parts>((json) => Parts.fromJson(json))
          .toList()
          .cast<Parts>(),
    );
  }

  Map<String, dynamic> toJson() {
    if (inlineData != null) {
      return {
        'role': role,
        'parts': [
          ...parts.map((e) => e.toJson()).toList(),
          {
            "inline_data": inlineData!.toJson(),
          }
        ],
      };
    }

    return {
      'role': role,
      'parts': parts.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'Content{role: $role, parts: $parts}';
  }
}
