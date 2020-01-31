import 'dart:async';
import 'dart:convert';
import 'package:cinema/model/api_client.dart';
import 'package:cinema/model/response/legal_response.dart';
import 'package:cinema/screens/auth/input_code.dart';
import 'package:cinema/utils/format.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Registration extends StatefulWidget {
  @override
  _Registration createState() => _Registration();
}

class _Registration extends State<Registration> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final RusNumberTextInputFormatter _phoneNumberFormatter =
  RusNumberTextInputFormatter();
  bool _obscureText = true;
  bool _isLoading = false;
  bool _autoValidatePhone = false;
  bool _autoValidatePass = false;
  String _phone = "";
  String _password = "";
  TextEditingController _tecPhone = new TextEditingController();
  TextEditingController _tecPass = new TextEditingController();
  TapGestureRecognizer _recognizer;
  MovieApi _guestUserApi;
  LegalResponse _legalResponse;
  String _url;

  @override
  void initState() {
    super.initState();
    _guestUserApi = new MovieApi();
    _tecPhone.addListener(() => setState(() {
      if (_tecPhone.text.length > 12) {
        _autoValidatePhone = true;
      } else {
        _autoValidatePhone = false;
      }
    }));
    _tecPass.addListener(() => setState(() {
      if (_tecPass.text.length > 0) {
        _autoValidatePass = true;
      } else {
        _autoValidatePass = false;
      }
    }));
    _recognizer = TapGestureRecognizer()
      ..onTap = () {
      _launchURL();
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          brightness: Theme.of(context).brightness,
          iconTheme: Theme.of(context)
              .iconTheme
              .copyWith(color: Theme.of(context).accentColor),
        ),
        body: _isLoading ? new Center(
          child: new CircularProgressIndicator(),
        ): SingleChildScrollView(
            child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(
                      height: 40.0,
                    ),
                    Container(
                        alignment: Alignment.topLeft,
                        margin: const EdgeInsets.only(left: 16.0,bottom: 20.0),
                        child : Text(
                          'Регистрация',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            //   color: Colors.white,
                          ),
                        )),
                    Container(
                        alignment: Alignment.topLeft,
                        margin: const EdgeInsets.only(left: 16.0,bottom: 6.0),
                        child : Text(
                          'Введите Ваш телефон',
                          style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),
                        )),
                    buildPhoneTextField(),
                    Container(
                        alignment: Alignment.topLeft,
                        margin: const EdgeInsets.only(left: 16.0,
                            bottom: 6.0,top:10.0),
                        child : Text(
                          'Придумайте пароль',
                          style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),
                        )),
                    buildPasswordTextField(context),
                    confirmButton(),
                    Container(
                        alignment: Alignment.topLeft,
                        margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      child : RichText(
                        text: TextSpan(
                          text: 'Нажимая кнопку "Зарегистрироваться", '
                              'Вы принимаете ',
                          style: TextStyle(color: Colors.black) ,
                          children: <TextSpan>[
                            TextSpan(text: 'условия пользовательского '
                                'соглашения',
                                style: TextStyle(decoration: TextDecoration.underline,
                                    color: Colors.blue),
                                recognizer: _recognizer),
                          ],
                        ),
                      ),
                    ),
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
        margin: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
        decoration:
        BoxDecoration(
            borderRadius: BorderRadius.all(const Radius.circular(4.0)),
            border: Border.all(color:  Theme.of(context).accentColor)),
        child: TextFormField(
          controller: _tecPhone,
          inputFormatters: <TextInputFormatter>[
            WhitelistingTextInputFormatter.digitsOnly,
            _phoneNumberFormatter
          ],
          keyboardType: TextInputType.phone,
          decoration:  InputDecoration(
              prefixText: '+7',
              prefixStyle: TextStyle(color: Theme.of(context).brightness ==
                  Brightness.dark
                  ? Colors.white : Colors.black,
                  fontSize: 16.0)
          ),
        ),
      );

  Widget buildPasswordTextField(BuildContext context) =>
      Container(
        alignment: Alignment(0.5, 0.5),
        height: 36.0,
        margin: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration:
        BoxDecoration(
            borderRadius: BorderRadius.all(const Radius.circular(4.0)),
            border: Border.all(color: Theme.of(context).accentColor)),
        child: TextFormField(
          controller: _tecPass,
          obscureText: _obscureText,
          decoration: InputDecoration(
              suffixIcon: GestureDetector(
                dragStartBehavior: DragStartBehavior.down,
                onTap: (){
                  setState(() {
                    _obscureText =!_obscureText;
                  });
                },
                child: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                ),
              )
          ),
        ),
      );


  Widget confirmButton() =>
      new Padding(padding: new EdgeInsets.all(16.0),
          child:  RaisedButton(
              onPressed: _autoValidatePhone ==false || _autoValidatePass==false
                  ? null : () {
                setState(() {
                  _isLoading = true;
                });
                _confirmPressed();
              },
              color: Colors.blue,
              child: Text(
                'Зарегистрироваться',
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
    _phone = "+7"+_tecPhone.text;
    _password = _tecPass.text;

    var body = jsonEncode({
      "appId":  _guestUserApi.appId,
      "phone": "+7"+_tecPhone.text.replaceAll("(", "").
      replaceAll(")", "").replaceAll("-", ""),
      "password": _tecPass.text,
    });

    var data = json.encode(body);
    print(data);

    _guestUserApi.userRegistration(body).then((response){
      if(response.statusCode == 202){
        setState(() {
          _isLoading = false;
        });
        _scaffoldKey.currentState.showSnackBar(SnackBar(
           content: Text("Успешно, SMS отправлено"),
           backgroundColor:Colors.green,
        ));
        print(response.body);

        Timer(Duration(seconds: 1), () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>
                  InputCode(phone: _phone,password: _password)));
        });
      }
      else if (response.statusCode == 409){
        setState(() {
          _isLoading = false;
        });
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Телефон уже зарегистрирован"),
          backgroundColor:Colors.red,
        ));
        print(response.body);
      }
      else if (response.statusCode == 429){
        setState(() {
          _isLoading = false;
        });
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("С момента предыдущей отправки кода на этот телефон "
              "не прошло 3 минут"),
          backgroundColor:Colors.red,
        ));
        print(response.body);
      }
      else if (response.statusCode == 450){
        setState(() {
          _isLoading = false;
        });
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("На этот номер отправка невозможна"),
          backgroundColor:Colors.red,
        ));
        print(response.body);
      }
      else {
        print(response.statusCode);
        setState(() {
          _isLoading = false;
        });
      }
    }).catchError((error){
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

  void _urlResponse(http.Response response) {
    if(response.statusCode == 200){
      _legalResponse = LegalResponse.fromJson(json.decode(response.body));
      _url = _legalResponse.privacy;
      print(_url);
    }
    else {
      print(response.statusCode);
    }
  }

  _launchURL() async {
    var body = jsonEncode({
      "appId":  _guestUserApi.appId,
    });

    _guestUserApi.legalTexts(body).then((_urlResponse))
        .catchError((error){
      print('error : $error');
    });

    if (await canLaunch(_url)) {
      await launch(_url);
    } else {
      throw 'Could not launch $_url';
    }
  }


  @override
  void dispose() {
    _tecPhone.dispose();
    _tecPass.dispose();
    super.dispose();
  }
}