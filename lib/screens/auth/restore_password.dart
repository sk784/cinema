import 'dart:convert';
import 'package:cinema/model/api_client.dart';
import 'package:cinema/model/response/recovery_response.dart';
import 'package:cinema/utils/countdown_timer.dart';
import 'package:cinema/utils/format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../home_page.dart';

class RestorePassword extends StatefulWidget {
  @override
  _RestorePassword createState() => _RestorePassword();
}

class _RestorePassword extends State<RestorePassword> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final RusNumberTextInputFormatter _phoneNumberFormatter =
  RusNumberTextInputFormatter();
  TextEditingController _controller = new TextEditingController();
  bool _checkCode = false;
  bool _resendCode = false;
  bool _isLoading = false;
  String _phone = "";
  RecoveryResponse _recoveryResponse;
  String _token;
  MovieApi _guestUserApi;

  @override
  void initState() {
    super.initState();
    _guestUserApi = new MovieApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          brightness: Theme.of(context).brightness,
          iconTheme: Theme.of(context)
              .iconTheme
              .copyWith(color: Theme.of(context).accentColor),
        ),
        key: _scaffoldKey,
        body: _isLoading ? new Center(
          child: new CircularProgressIndicator(),
              ):SingleChildScrollView(
          child:Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  height: 40.0,
                ),
                Container(
                    alignment: Alignment.topLeft,
                    margin: const EdgeInsets.only(left: 16.0, bottom: 20.0),
                    child: Text(
                      'Восстановить пароль',
                      style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold
                      ),
                    )),
                Container(
                    alignment: Alignment.topLeft,
                    margin: const EdgeInsets.only(left: 16.0, bottom: 10.0),
                    child: Text(_checkCode == false
                        ? 'Введите телефон, который был указан при регистрации'
                        :
                    'На Ваш телефон отправлен код, введите его '
                        'для сброса пароля',
                    )),
                Container(
                    alignment: Alignment.topLeft,
                    margin: const EdgeInsets.only(left: 16.0, bottom: 6.0),
                    child: Text(
                      _checkCode == false
                          ? 'Телефон' : 'Код для сброса пароля',
                      style: TextStyle(
                          fontWeight: FontWeight.bold
                      ),
                    )),
                buildPhoneTextField(),
                Visibility(
                    visible: _checkCode == true,
                    child: FlatButton(
                        onPressed: _resendCodePressed,
                        child: Text(
                          'Отправить код повторно',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                              color: Colors.blue
                          ),
                        )
                    )
                ),
                Visibility(
                    visible: _resendCode == true,
                    child: CountDownTimer(
                        secondsRemaining: 180,
                        whenTimeExpires: () {
                          setState(() {
                            _resendCode = false;
                          });
                        })
                ),
                confirmButton(),
              ],
            )
        )
    )
    );
  }

  Widget buildPhoneTextField() =>
      Container(
        alignment: Alignment(0.5, 0.5),
        height: 36.0,
        margin: const EdgeInsets.only(left: 16.0, right: 16.0),
        decoration:
        BoxDecoration(
            borderRadius: BorderRadius.all(const Radius.circular(4.0)),
            border: Border.all(color: Theme.of(context).accentColor)),
        child: TextFormField(
          controller: _controller,
          inputFormatters: _checkCode == false ? <TextInputFormatter>[
            WhitelistingTextInputFormatter.digitsOnly,
            _phoneNumberFormatter
          ] : null,
          keyboardType: TextInputType.phone,
          decoration: _checkCode == false ? InputDecoration(
              prefixText: '+7',
              prefixStyle: TextStyle(color: Theme.of(context).brightness
                  == Brightness.dark
                  ? Colors.white:Colors.black,
                  fontSize: 16.0)
          ) : null,
        ),
      );

  Widget confirmButton() =>
      Padding(padding: new EdgeInsets.only(left: 16.0,top:40.0,right: 16.0),
          child: RaisedButton(
              onPressed: _resendCode == true ? null : () {
                setState(() {
                  _isLoading = true;
                });
                _confirmPressed();
              },
              color: Colors.blue,
              child: Text(
                'Подтвердить',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              )));


  void _confirmPressed() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    if (_checkCode == false) {
      _phone = "+7" + _controller.text.replaceAll("(", "").
      replaceAll(")", "").replaceAll("-", "");

      var body = jsonEncode({
        "appId": _guestUserApi.appId,
        "phone": _phone,
      });

      var data = json.encode(body);
      print(data);

      _guestUserApi.userRequestCode(body).then((response) {
        if (response.statusCode == 202) {
          setState(() {
            _isLoading = false;
            _checkCode = !_checkCode;
            _controller.clear();
          });
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("Успешно, код отправлен"),
            backgroundColor: Colors.green,
          ));
          print(response.body);
        }
        else if (response.statusCode == 404) {
          setState(() {
            _isLoading = false;
          });
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("Аккаунт не найден"),
            backgroundColor: Colors.red,
          ));
          print(response.body);
          print(response.statusCode);
        }
        else if (response.statusCode == 429) {
          setState(() {
            _isLoading = false;
          });
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("С момента предыдущей отправки кода на этот телефон "
                "не прошло 3 минут"),
            backgroundColor: Colors.red,
          ));
          print(response.body);
        }
        else if (response.statusCode == 450) {
          setState(() {
            _isLoading = false;
          });
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("На этот номер отправка невозможна"),
            backgroundColor: Colors.red,
          ));
          print(response.body);
        }
        else {
          print(response.statusCode);
          setState(() {
            _isLoading = false;
          });
        }
      }).catchError((error) {
        setState(() {
          _isLoading = false;
        });
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Неизвестная ошибка"),
          backgroundColor: Colors.red,
        ));
        print('error : $error');
      });
    }
    else {
      var body = jsonEncode({
        "appId": _guestUserApi.appId,
        "phone": _phone,
        "code": _controller.text
      });

      var data = json.encode(body);
      print(data);

      void _processResponse(http.Response response) {
        if (response.statusCode == 200) {
          setState(() {
            _isLoading = false;
            _controller.clear();
            _recoveryResponse = RecoveryResponse.fromJson(json.decode(response.body));
            _token = _recoveryResponse.token;
             print(_token);
            _guestUserApi.setMobileToken(_token);
          });

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
                (Route<dynamic> route) => false,
          );
        }
        else if (response.statusCode == 404) {
          setState(() {
            _isLoading = false;
          });
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("Аккаунт не найден"),
            backgroundColor: Colors.red,
          ));
          print(response.body);
          print(response.statusCode);
        }
        else if (response.statusCode == 410) {
          setState(() {
            _isLoading = false;
          });
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("Неверный код и превышен лимит попыток; "
                "запрос на восстановление удалён"),
            backgroundColor: Colors.red,
          ));
          print(response.body);
        }
        else {
          print(response.statusCode);
          setState(() {
            _isLoading = false;
          });
        }
      }
      _guestUserApi.userVerifyCode(body).then((_processResponse))
          .catchError((error) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Неизвестная ошибка"),
          backgroundColor: Colors.red,
        ));
        setState(() {
          _isLoading = false;
        });
        print('error : $error');
      });
    }
  }

  void _resendCodePressed() {
    setState(() {
      _resendCode = !_resendCode;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}




