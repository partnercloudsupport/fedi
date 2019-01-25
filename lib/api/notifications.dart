import 'package:fedi/definitions/instance.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:fedi/definitions/notification.dart';
import 'package:fedi/definitions/user.dart';
import 'package:fedi/definitions/file.dart';

getNotifications(Instance instance, String authCode,
    {List<FediNotification> currentNotifications}) async {
  List<FediNotification> notifications;

  switch (instance.type) {
    case "misskey":
      {
        notifications = await getMisskeyNotifications(instance, authCode,
            currentNotifications: currentNotifications);
        break;
      }
    // TODO: get hometimeline on mastodon
    default:
      {
        throw Exception(instance.type + " isnt supported lol");
      }
  }
  return notifications;
}

Future<List> getMisskeyNotifications(Instance instance, String authCode,
    {List<FediNotification> currentNotifications}) async {
  List<FediNotification> newNotifications = new List();
  Map<String, dynamic> params;
  String actionPath = "/api/i/notifications";

  params = Map.from({
    "limit": 40,
    "i": authCode,
  });

  final response =
      await http.post(instance.uri + actionPath, body: json.encode(params));

  if (response.statusCode == 200) {
    List<dynamic> returned = json.decode(response.body);

    returned.forEach((v) {
      var notification = FediNotification.fromMisskey(v, instance);
      if (notification != null) newNotifications.add(notification);
    });

    if (currentNotifications != null) {
      return new List<FediNotification>.from(newNotifications)
        ..addAll(currentNotifications);
    }

    return newNotifications;
  } else {
    throw Exception('Failed to load post ' +
        (instance.uri + actionPath + json.encode(params)));
  }
}