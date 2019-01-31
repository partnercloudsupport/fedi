import 'package:fedi/definitions/instance.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

favouritePost(Instance instance, String authCode, String postId) async {
  bool favourited;

  switch (instance.type) {
    case "misskey":
      {
        favourited = await favouriteMisskeyPost(instance, authCode, postId);
        break;
      }
    default:
      {
        favourited = await favouriteMastodonPost(instance, authCode, postId);
        break;
      }
  }
  return favourited;
}

Future<bool> favouriteMisskeyPost(
    Instance instance, String authCode, String postId) async {
  Map<String, dynamic> params;
  String actionPath = "/api/notes/favorites/create";

  params = Map.from({"i": authCode, "noteId": postId});

  final response =
      await http.post(instance.uri + actionPath, body: json.encode(params));

  if (response.statusCode == 204) {
    String actionPath = "/api/notes/reactions/create";
    params = Map.from({"i": authCode, "noteId": postId, "reaction": "like"});
    final response =
        await http.post(instance.uri + actionPath, body: json.encode(params));
    if (response.statusCode == 204) {
      return true;
    } else {
      throw Exception('Failed to load post ' +
          (instance.uri + actionPath + json.encode(params)));
    }
  } else {
    throw Exception('Failed to load post ' +
        (instance.uri + actionPath + json.encode(params)));
  }
}

Future<bool> favouriteMastodonPost(
    Instance instance, String authCode, String postId) async {
  Map<String, dynamic> params;
  String actionPath = "/api/v1/statuses/" + postId + "/favourite";

  final response = await http.post(instance.uri + actionPath,
      headers: {"Authorization": "bearer " + authCode});

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception('Failed to load post ' +
        (instance.uri + actionPath + json.encode(params)));
  }
}
