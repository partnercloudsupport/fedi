import 'package:fedi/definitions/instance.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:fedi/definitions/item.dart';

getContext(Instance instance, String authCode, String statusId,
    Item originalStatus) async {
  List<Item> statuses;

  switch (instance.type) {
    case "misskey":
      {
        statuses = await getMisskeyContext(
            instance, authCode, statusId, originalStatus);
        break;
      }
    case "mastodon":
      {
        statuses = await getMastodonContext(
            instance, authCode, statusId, originalStatus);
        break;
      }
    default:
      {
        throw (instance.type + "not supported");
      }
  }
  return statuses;
}

Future<List> getMisskeyContext(Instance instance, String authCode,
    String statusId, Item originalStatus) async {
  List<Item> newStatuses = new List();
  Map<String, dynamic> params;
  String actionPath = "/api/notes/conversation";

  params = Map.from({
    "limit": 40,
    "i": authCode,
    "noteId": statusId,
  });

  final response =
      await http.post(instance.uri + actionPath, body: json.encode(params));

  if (response.statusCode == 200) {
    List<dynamic> returned = json.decode(response.body);

    newStatuses.add(originalStatus);

    returned.forEach((v) {
      var status = Item.fromMisskey(v, instance);
      if (status != null) newStatuses.add(status);
    });

    return newStatuses;
  } else {
    throw Exception('Failed to load post ' +
        (instance.uri + actionPath + json.encode(params)));
  }
}

Future<List> getMastodonContext(Instance instance, String authCode,
    String statusId, Item originalStatus) async {
  List<Item> newStatuses = new List();
  Map<String, dynamic> params;
  String actionPath = "/api/v1/statuses/" + statusId + "/context";

  final response = await http.get(instance.uri + actionPath,
      headers: {"Authorization": "bearer " + authCode});

  if (response.statusCode == 200) {
    Map<String, dynamic> returned = json.decode(response.body);

    returned["descendants"].reversed.forEach((v) {
      var status = Item.fromMastodon(v, instance);
      if (status != null) newStatuses.add(status);
    });

    newStatuses.add(originalStatus);

    returned["ancestors"].reversed.forEach((v) {
      var status = Item.fromMastodon(v, instance);
      if (status != null) newStatuses.add(status);
    });

    return newStatuses;
  } else {
    throw Exception('Failed to load post ' +
        (instance.uri + actionPath + json.encode(params)));
  }
}
