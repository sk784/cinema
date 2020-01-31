import 'notifications.dart';

class UpdateProfile {
  String name;
  String oldPassword;
  String newPassword;
  String lat;
  String lon;
  Notifications notifications;

  UpdateProfile(this.name, this.oldPassword, this.newPassword, this.lat,
      this.lon, this.notifications);

  Map toJson() {
    Map notifications = this.notifications != null ? this.notifications.toJson() : null;
    return {
      "name": name,
      "lat": lat,
      "lon": lon,
      "oldPassword": oldPassword,
      "newPassword": newPassword,
      "notifications": notifications
    };
  }
}