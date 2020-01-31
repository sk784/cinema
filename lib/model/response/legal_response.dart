class LegalResponse {

  final String terms;
  final String privacy;

  LegalResponse({this. terms,this.privacy});

  factory LegalResponse.fromJson(Map<String, dynamic> json) {
    return LegalResponse(
      terms: json['terms'],
      privacy: json['privacy'],
    );
  }
}