import 'dart:convert';
import 'package:cinema/model/api_client.dart';
import 'package:cinema/model/response/code_response.dart';
import 'package:cinema/screens/auth/profile.dart';
import 'package:cinema/utils/countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class InputCode extends StatefulWidget {
  final String phone;
  final String password;
  const InputCode({Key key, this.phone,this.password}) : super(key: key);
  @override
  _InputCode createState() => _InputCode();
}

class _InputCode extends State<InputCode> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _resendCode = false;
  bool _isLoading = false;
  TextEditingController _tecCode = new TextEditingController();
  CodeResponse _codeResponse;
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
        body:  _isLoading ? new Center(
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
                          'Введите код',
                          style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold
                          ),
                        )),
                    Container(
                        alignment: Alignment.topLeft,
                        margin: const EdgeInsets.only(left: 16.0, right: 16.0,
                            bottom: 20.0),
                        child: Text(
                             'Мы отправили код активации по SMS на \nномер'
                                 ' ${widget.phone.replaceRange(4, 13, "*******")})',
                        )),
                    Container(
                        alignment: Alignment.topLeft,
                        margin: const EdgeInsets.only(left: 16.0, bottom: 6.0),
                        child: Text('Код активации',
                          style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),
                        )),
                    buildCodeTextField(),
                    FlatButton(
                        onPressed: _resendCodePressed,
                            child: Text(
                              'Отправить код повторно',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                  color: Colors.blue
                              ),
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

  Widget buildCodeTextField() =>
      Container(
        alignment: Alignment(0.5, 0.5),
        height: 36.0,
        margin: const EdgeInsets.only(left: 16.0, right: 16.0),
        decoration:
        BoxDecoration(
            borderRadius: BorderRadius.all(const Radius.circular(4.0)),
            border: Border.all(color: Theme.of(context).accentColor)),
        child: TextFormField(
          controller: _tecCode,
          keyboardType: TextInputType.number,
        ),
      );


  Widget confirmButton() =>
      Padding(padding: new EdgeInsets.only(left: 16.0,top:40.0,right: 16.0),
          child: RaisedButton(
              onPressed: _resendCode == true
                  ? null :() {
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
              )
          )
      );


  void _confirmPressed() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    var body = jsonEncode({
      "appId":  _guestUserApi.appId,
      "phone": widget.phone.replaceAll("(", "").
      replaceAll(")", "").replaceAll("-", ""),
      "code": _tecCode.text,
    });

    var data = json.encode(body);
    print(data);

    void _processResponse(http.Response response) {
      if(response.statusCode == 201){
        setState(() {
          _isLoading = false;
          _codeResponse = CodeResponse.fromJson(json.decode(response.body));
          _token = _codeResponse.token;
          print(_token);
          _guestUserApi.setMobileToken(_token);
          print(response.body);
          print(response.statusCode);
        });
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => Profile(
                oldPassword: widget.password)));
      }
      else if (response.statusCode == 403){
        setState(() {
          _isLoading = false;
        });
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Неверный код"),
          backgroundColor:Colors.red,
        ));
        print(response.statusCode);
      }
      else if (response.statusCode == 404){
        setState(() {
          _isLoading = false;
        });
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Аккаунт не найден"),
          backgroundColor:Colors.red,
        ));
        print(response.statusCode);
      }
      else if (response.statusCode == 410){
        setState(() {
          _isLoading = false;
        });
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Неверный код и превышен лимит попыток; аккаунт удалён"),
          backgroundColor:Colors.red,
        ));
        print(response.statusCode);
      }
      else {
        print(response.statusCode);
        setState(() {
          _isLoading = false;
        });
      }
    }
    _guestUserApi.userConfirmCode(body).then((_processResponse))
        .catchError((error){
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Неизвестная ошибка"),
        backgroundColor:Colors.red,
      ));
      setState(() {
        _isLoading = false;
      });
      print('error : $error');
    });
  }

  void _resendCodePressed() {
    setState(() {
      _resendCode = !_resendCode;
    });
  }

  @override
  void dispose() {
    _tecCode.dispose();
    super.dispose();
  }
}