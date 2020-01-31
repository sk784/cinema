class UserResponse {

  final String token;
  final String name;
  final String lat;
  final String lon;
  final int cinema;
  final int aggregator;

  UserResponse({this.token,this.name,this.lat,this.lon,this.cinema,this.aggregator});

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      token: json['token'],
      name: json['name'],
      lat: json['lat'],
      lon: json['lon'],
      cinema: json['notifications']['cinema'],
      aggregator: json['notifications']['aggregator']
    );
  }

}