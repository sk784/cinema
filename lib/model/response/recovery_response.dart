class RecoveryResponse {

  final String token;
  final String password;

  RecoveryResponse({this.token,this.password});

  factory RecoveryResponse.fromJson(Map<String, dynamic> json) {
    return RecoveryResponse(
      token: json['token'],
      password: json['password'],
    );
  }
}