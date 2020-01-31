import 'dart:convert';

import 'package:cinema/model/api_client.dart';
import 'package:cinema/model/entity/notifications.dart';
import 'package:cinema/model/entity/update_profile.dart';
import 'package:cinema/utils/settings_toggle.dart';
import 'package:cinema/screens/home_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {

  const Profile({Key key, this.oldPassword}) : super(key: key);
  final String oldPassword;

  @override
  _Profile createState() => _Profile();
}

class _Profile extends State<Profile> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _newPasswordText = false;
  bool _notifications = true;
  bool _isLoading = false;
  bool _autoValidateName = false;
  MovieApi _guestUserApi;
  TextEditingController _tecName = new TextEditingController();
  TextEditingController _tecPass = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _guestUserApi = new MovieApi();
    _tecName.addListener(() => setState(() {
      if (_tecName.text.length > 0) {
        _autoValidateName = true;
      } else {
        _autoValidateName = false;
      }
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Theme
              .of(context)
              .scaffoldBackgroundColor,
          brightness: Theme
              .of(context)
              .brightness,
          iconTheme: Theme
              .of(context)
              .iconTheme
              .copyWith(color: Theme
              .of(context)
              .accentColor),
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
                        margin: const EdgeInsets.only(left: 16.0, bottom: 20.0),
                        child: Text(
                          'Профиль',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            //   color: Colors.white,
                          ),
                        )),
                    Container(
                        alignment: Alignment.topLeft,
                        margin: const EdgeInsets.only(left: 16.0, bottom: 6.0),
                        child: Text(
                          'Имя',
                          style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),
                        )),
                    buildNameTextField(),
                    Container(
                        alignment: Alignment.topLeft,
                        margin: const EdgeInsets.only(left: 16.0,
                            bottom: 6.0, top: 10.0),
                        child: Text(
                          'Пароль',
                          style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),
                        )
                    ),
                    buildPasswordTextField(context),
                    Visibility(
                      visible: _newPasswordText == true,
                      child: Container(
                          alignment: Alignment.topLeft,
                          margin: const EdgeInsets.only(left: 16.0,
                              bottom: 6.0, top: 10.0),
                          child: Text(
                            'Новый пароль',
                            style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),
                          )
                      ),
                    ),
                    buildNewPasswordTextField(context),
                    confirmButton(),
                    SettingsToggle(
                      title: 'Уведомления из приложения',
                      onChanged: changeNotifications,
                      value: _notifications==true,
                    ),
                  ],
                )
            )
        )
    );
  }

  Widget buildNameTextField() =>
      Container(
        alignment: Alignment(0.5, 0.5),
        height: 36.0,
        margin: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
        decoration:
        BoxDecoration(
            borderRadius: BorderRadius.all(const Radius.circular(4.0)),
            border: Border.all(color: Theme
                .of(context)
                .accentColor)),
        child: TextFormField(
          controller: _tecName,
          keyboardType: TextInputType.text,
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
            border: Border.all(color: Theme
                .of(context)
                .accentColor)),
        child: TextFormField(
          initialValue: widget.oldPassword,
          obscureText: true,
          decoration: InputDecoration(
              suffixIcon: GestureDetector(
                  dragStartBehavior: DragStartBehavior.down,
                  onTap: () {
                    setState(() {
                      _newPasswordText = !_newPasswordText;
                    });
                  },
                  child: Visibility(
                    visible: _newPasswordText == false,
                    child: Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        'Изменить',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    )
                  )
              )
          ),
        ),
      );

  Widget buildNewPasswordTextField(BuildContext context) =>
      Visibility(
        visible: _newPasswordText == true,
          child:
           Container(
             alignment: Alignment(0.5, 0.5),
             height: 36.0,
             margin: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 6.0),
             padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration:
            BoxDecoration(
             borderRadius: BorderRadius.all(const Radius.circular(4.0)),
             border: Border.all(color: Theme
                .of(context)
                .accentColor)),
             child: TextFormField(
               controller: _tecPass,
               obscureText: true,
        ),
      )
      );

  Widget confirmButton() =>
      new Padding(padding: new EdgeInsets.all(16.0),
          child: RaisedButton(
              onPressed:_autoValidateName ==false
                  ? null : () {
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
    Notifications notifications = Notifications(0, 0);
    UpdateProfile updateProfile = UpdateProfile(_tecName.text, widget.oldPassword,
        _tecPass.text, null, null, notifications);
    String jsonUpdateProfile = jsonEncode(updateProfile);
    print(jsonUpdateProfile);

     _guestUserApi.userUpdate(jsonUpdateProfile).then((response){
      if(response.statusCode == 200){
        setState(() {
          _isLoading = false;
        });
        print(response.statusCode);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => HomePage()));
      }
      else if (response.statusCode == 401){
        setState(() {
          _isLoading = false;
        });
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Ошибка авторизации"),
          backgroundColor:Colors.red,
        ));
        print(response.statusCode);
      }
      else if (response.statusCode == 403){
        setState(() {
          _isLoading = false;
        });
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Неверный старый пароль"),
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

  void changeNotifications(bool value) {
    setState(() {

    });
  }

  @override
  void dispose() {
    _tecName.dispose();
    _tecPass.dispose();
    super.dispose();
  }
}