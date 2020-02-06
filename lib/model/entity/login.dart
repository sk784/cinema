class Login {
  String appId;
  String phone;
  String password;
  String deviceId;
  String fcmToken;


  Login(this.appId, this.phone, this.password, this.deviceId,
      this.fcmToken);

  Map toJson() {
    return {
      "appId": appId,
      "phone": phone,
      "password": password,
      "deviceId": deviceId,
      "fcmToken": fcmToken,
    };
  }
}