import 'package:cinema/model/api_client.dart';
import 'package:cinema/model/response/user_response.dart';
import 'package:cinema/screens/auth/registration.dart';
import 'package:cinema/screens/auth/restore_password.dart';
import 'package:cinema/screens/home_page.dart';
import 'package:cinema/utils/format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_info/device_info.dart';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

class SignIn extends StatefulWidget {

  @override
 _SignInState createState() => _SignInState();
 }

 class _SignInState extends State<SignIn> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final RusNumberTextInputFormatter _phoneNumberFormatter =
  RusNumberTextInputFormatter();

  bool _obscureText = true;
  bool _isLoading = false;
  String _token;
  String _deviceId = "";
  bool _autoValidatePhone = false;
  bool _autoValidatePass = false;
  TextEditingController _tecPhone = new TextEditingController();
  TextEditingController _tecPass = new TextEditingController();
  MovieApi _guestUserApi;
  UserResponse _userResponse;

  @override
  void initState() {
    super.initState();
    _guestUserApi = new MovieApi();
    fireBaseCloudMessagingListeners();
    initPlatformState();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body:_isLoading ? new Center(
        child: new CircularProgressIndicator(),
      ): SingleChildScrollView(
       child: Form(
         child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 80.0,
              ),
              Container(
                  alignment: Alignment.topLeft,
                  margin: const EdgeInsets.only(left: 16.0,bottom: 20.0),
                  child : Text(
                    'Вход в аккаунт',
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
                    'Телефон',
                    style: TextStyle(
                        fontWeight: FontWeight.bold
                    ),
                  )),
              buildPhoneTextField(),
              Container(
                  alignment: Alignment.topLeft,
                  margin: const EdgeInsets.only(left: 16.0,bottom: 6.0,top:10.0),
                  child : Text(
                    'Пароль',
                    style: TextStyle(
                        fontWeight: FontWeight.bold
                    ),
                  )),
              buildPasswordTextField(context),
              forgetPasswordButton(),
              confirmButton(),
              registrationButton()
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


  Widget forgetPasswordButton() =>
      Container(
          alignment: Alignment.topRight,
          child : FlatButton(
           onPressed: _forgetPasswordPressed,
           child:  Text(
            'Забыли пароль?',
             style: TextStyle(
                 fontWeight: FontWeight.bold,
                 fontSize: 16.0,
                 color: Colors.blue
             ),
          ))
      );

  Widget confirmButton() =>
      new Padding(padding: new EdgeInsets.symmetric(horizontal: 16.0),
          child:  RaisedButton(
              onPressed:  _autoValidatePhone ==false || _autoValidatePass==false
              ? null : () {
                setState(() {
                  _isLoading = true;
                });
                _confirmPressed();
              },
              color: Colors.blue,
              child: Text(
                'Войти',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Colors.white,
                ),
              )
          )
      );

  Widget registrationButton() =>
      FlatButton(
          onPressed: _registrationPressed,
          child:  Text(
            'Регистрация',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: Colors.blue
            ),
          ));


  void _forgetPasswordPressed() {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RestorePassword()));
  }

  void _confirmPressed(){
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    var body = jsonEncode({
      "appId": _guestUserApi.appId,
      "phone": "+7"+_tecPhone.text.replaceAll("(", "").
      replaceAll(")", "").replaceAll("-", ""),
      "password": _tecPass.text,
      "deviceId": _deviceId,
      "fcmToken": _token
    });

    var data = json.encode(body);
    print(data);

      void _processResponse(http.Response response) {
        if(response.statusCode == 200){
          print(response.body);
          setState(() {
            _isLoading = false;
            _userResponse = UserResponse.fromJson(json.decode(response.body));
           _token = _userResponse.token;
            print(_token);
           _guestUserApi.setMobileToken(_token);
          });
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()));
        }
        else if (response.statusCode == 401){
          print(response.statusCode);
          setState(() {
            _isLoading = false;
          });
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("Вы ввели неверный логин или пароль"),
            backgroundColor:Colors.red,
          ));
        }
        else {
          print(response.statusCode);
          setState(() {
            _isLoading = false;
          });
        }
      }

    _guestUserApi.userLogin(body).then((_processResponse))
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

  void _registrationPressed() {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Registration()));
  }

  Future<void> initPlatformState() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        print('Running on ${androidInfo.model}');
        _deviceId = androidInfo.model;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        print('Running on ${iosInfo.utsname.machine}');
        _deviceId = iosInfo.utsname.machine;
      }
    } on PlatformException {
      print( 'Error:Failed to get platform version.');
    }
    if (!mounted) return;
  }

  void fireBaseCloudMessagingListeners() {
    FirebaseAuth.instance.currentUser().then((user){
      final FirebaseMessaging _fireBaseMessaging = FirebaseMessaging();
      _fireBaseMessaging.getToken().then((token) {
        print(token);
        _token = token;
      });
    });
 }

  @override
  void dispose() {
    _tecPhone.dispose();
    _tecPass.dispose();
    super.dispose();
  }
 }




