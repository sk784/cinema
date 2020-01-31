class CodeResponse {

  final String token;

  CodeResponse({this.token});

  factory CodeResponse.fromJson(Map<String, dynamic> json) {
    return CodeResponse(
        token: json['token']
    );
  }
}