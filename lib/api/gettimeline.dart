import 'package:fedi/definitions/instance.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:fedi/definitions/item.dart';
import 'package:fedi/definitions/shared.dart';

Future<List<Item>> getTimeline(
    Instance instance, String authCode, String timelineName,
    {List<Item> currentStatuses, String sinceId, String targetUserId}) async {
  List<Item> statuses;

  switch (instance.type) {
    case "misskey":
      {
        statuses = await getMisskeyTimeline(instance, authCode, timelineName,
            currentStatuses: currentStatuses,
            sinceId: sinceId,
            targetUserId: targetUserId);
        break;
      }
    case "mastodon":
      {
        statuses = await getMastodonTimeline(instance, authCode, timelineName,
            currentStatuses: currentStatuses,
            sinceId: sinceId,
            targetUserId: targetUserId);
        break;
      }
    default:
      {
        throw (instance.type + "not supported");
      }
  }
  return statuses;
}

Future<List> getMisskeyTimeline(
    Instance instance, String authCode, String timelineName,
    {List<Item> currentStatuses, String sinceId, String targetUserId}) async {
  List<Item> newStatuses = new List();
  Map<String, dynamic> params = new Map();
  String actionPath;

  if (sinceId == null) {
    params = Map.from({
      "limit": 40,
      "i": authCode,
    });
  } else {
    params = Map.from({
      "limit": 40,
      "i": authCode,
      "SinceId": sinceId,
    });
  }

  switch (timelineName) {
    case "home":
      actionPath = "/api/notes/timeline";
      break;
    case "local":
      actionPath = "/api/notes/local-timeline";
      break;
    case "public":
      actionPath = "/api/notes/global-timeline";
      break;
    case "notifications":
      actionPath = "/api/i/notifications";
      break;
    case "user":
      actionPath = "/api/users/notes";
      params.addAll({"userId": targetUserId});
      break;
    case "user_media":
      actionPath = "/api/users/notes";
      params.addAll({"userId": targetUserId, "withFiles": true});
      break;
    case "user_replies":
      actionPath = "/api/users/notes";
      params.addAll({"userId": targetUserId, "includeReplies": true});
      break;
  }

  final response =
      await http.post(instance.uri + actionPath, body: json.encode(params));

  if (response.statusCode == 200) {
    List<dynamic> returned = json.decode(response.body);

    returned.forEach((v) {
      var status = Item.fromMisskey(v, instance);
      if (status != null && status.id != null) newStatuses.add(status);
    });

    if (currentStatuses != null) {
      return new List<Item>.from(newStatuses)..addAll(currentStatuses);
    }

    return newStatuses;
  } else {
    throw Exception('Failed to load post ' +
        (instance.uri + actionPath + json.encode(params)));
  }
}

Future<List> getMastodonTimeline(
    Instance instance, String authCode, String timelineName,
    {List<Item> currentStatuses, String sinceId, String targetUserId}) async {
  List<Item> newStatuses = new List();
  Map<String, dynamic> params;
  String actionPath;

  if (sinceId == null) {
    params = Map.from({
      "limit": "40",
    });
  } else {
    params = Map.from({
      "limit": "40",
      "since_id": sinceId,
    });
  }

  switch (timelineName) {
    case "home":
      actionPath = "/api/v1/timelines/home";
      break;
    case "local":
      actionPath = "/api/v1/timelines/public";
      params.addAll({"local": "true"});
      break;
    case "public":
      actionPath = "/api/v1/timelines/public";
      break;
    case "notifications":
      actionPath = "/api/v1/notifications";
      break;
    case "user":
      actionPath = "/api/v1/" + targetUserId + "/statuses";
      params.addAll({"exclude_replies": "true"});
      break;
    case "user_media":
      actionPath = "/api/v1/" + targetUserId + "/statuses";
      params.addAll({"only_media": "true"});
      break;
    case "user_replies":
      actionPath = "/api/v1/" + targetUserId + "/statuses";
      params.addAll({"exclude_replies": "false"});
      break;
  }

  final response = await http.get(
      instance.uri + actionPath + "?" + uriEncodeMap(params),
      headers: {"Authorization": "bearer " + authCode});

  if (response.statusCode == 200) {
    List<dynamic> returned = json.decode(response.body);

    returned.forEach((v) {
      var status = Item.fromMastodon(v, instance);
      if (status != null) newStatuses.add(status);
    });

    if (currentStatuses != null) {
      return new List<Item>.from(newStatuses)..addAll(currentStatuses);
    }

    return newStatuses;
  } else {
    throw Exception('Failed to load post ' +
        (instance.uri + actionPath + json.encode(params)));
  }
}
