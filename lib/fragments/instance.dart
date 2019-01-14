import 'package:json_annotation/json_annotation.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

part 'instance.g.dart';

@JsonSerializable()
class Instance {
  String type;
  String uri;
  String title;
  String description;
  String version;
  String protocol;
  String host;

  Instance(this.uri, this.protocol, this.host, this.title, this.description,
      this.version,
      [this.type]) {
    if (this.type == null) {
      if (this.version.contains("misskey")) {
        this.type = "misskey";
      } else if (this.version.contains("Pleroma")) {
        this.type = "pleroma";
      } else {
        this.type = "mastodon";
      }
    }
  }

  static Future<Instance> fromUrl(String instanceUrl) async {
    try {
      String protocol;
      if (instanceUrl.startsWith('http://')) {
        protocol = "http://";
      } else {
        protocol = "https://";
      }

      Uri instanceUri = Uri.parse(protocol + instanceUrl);

      final response =
          await http.get(instanceUri.toString() + "/api/v1/instance");

      if (response.statusCode == 200) {
        Map<String, dynamic> returned = json.decode(response.body);
        returned.addAll({
          "protocol": instanceUri.scheme,
          "uri": instanceUri.toString(),
          "host": instanceUri.host
        });
        // If server returns an OK response, parse the JSON
        return Instance.fromJson(returned);
      } else {
        throw Exception('Failed to load post');
      }
    } catch (exception) {
      throw exception;
    }
  }

  factory Instance.fromJson(Map<String, dynamic> json) =>
      _$InstanceFromJson(json);

  Map<String, dynamic> toJson() => _$InstanceToJson(this);
}