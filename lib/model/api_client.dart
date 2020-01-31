import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MovieApi {

  final String baseUrl = 'https://kino-api.senseisoft.com';
  final String _token = "token";
  final String appId = "9f4110c2-81c8-4e99-bd59-9b7a9388fec4";

  static final _client = MovieApi._internal();
  MovieApi._internal();

  factory MovieApi() => _client;

  Map <String, String> headers = {'Content-Type': 'application/json'};

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<String> getMobileToken() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(_token) ?? '';
  }

  Future<bool> setMobileToken(String token) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setString(_token, token);
  }

  Future<Map<String, String>> getHeadersWithAuthorization() async {
    final String mobileToken = await getMobileToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $mobileToken'
    };
  }

  Future<http.Response> legalTexts(String body) async {
    final response = await http.post(baseUrl + "/app/legal",
        body: body, headers: headers);
    return response;
  }

  Future<http.Response> userRegistration(String body) async {
    final response = await http.post(baseUrl + "/account/register",
        body: body, headers: headers);
    return response;
  }

  Future<http.Response> userRequestCode(String body) async {
    final response = await http.post(baseUrl + "/account/recovery/request",
        body: body, headers: headers);
    return response;
  }

  Future<http.Response> userUpdate(String body) async {
    final headersWithAuth = await getHeadersWithAuthorization();
    print(headersWithAuth.toString());
    final response = await http.post(baseUrl + "/account/update",
        body: body, headers: headersWithAuth);
    return response;
  }


  Future<http.Response> userLogin(String body) async {
    final headersWithAuth = await getHeadersWithAuthorization();
    final response = await http.post(baseUrl + "/account/login",
        body: body, headers: headersWithAuth);
    return response;
  }

  Future<http.Response> userVerifyCode(String body) async {
    final response = await http.post(baseUrl + "/account/recovery/verify",
        body: body, headers: headers);
    return response;
  }

  Future<http.Response> userConfirmCode(String body) async {
    final response = await http.post(baseUrl + "/account/confirm",
        body: body, headers: headers);
    print(response.body);
    return response;
  }
}


