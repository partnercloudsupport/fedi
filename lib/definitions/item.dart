import 'package:fedi/definitions/user.dart';
import 'package:fedi/definitions/file.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import 'package:fedi/definitions/instance.dart';

part 'item.g.dart';

@JsonSerializable()
class Item {
  String id;
  String date;
  User author;
  String url;
  String contentWarning;
  String body;
  String visibility;
  bool favourited;
  int favCount;
  String myReaction;
  int renoteCount;
  int replyCount;
  List<File> files;
  Item renote;
  String notificationType;
  bool isRead;
  Item notificationNote;

  Item(
      id,
      date,
      author,
      url,
      contentWarning,
      body,
      visibility,
      favourited,
      favCount,
      myReaction,
      renoteCount,
      replyCount,
      files,
      renote,
      notificationType,
      isRead,
      notificationNote) {
    this.id = id;
    this.date = date;
    this.author = author;
    this.url = url;
    this.contentWarning = contentWarning;
    this.body = body;
    this.visibility = visibility.toLowerCase();
    this.favourited = favourited;
    this.favCount = favCount;
    this.myReaction = myReaction;
    this.renoteCount = renoteCount;
    this.replyCount = replyCount;
    this.files = files;
    this.renote = renote;
    this.notificationType = notificationType;
    this.isRead = isRead;
    this.notificationNote = notificationNote;
  }

  Item.fromJson(Map json) {
    this.id = json['id'];
    this.date = json['date'];
    this.author = json['author'];
    this.url = json['url'];
    this.contentWarning = json['cw'];
    this.body = json['body'];
    this.visibility = json['visibility'].toString().toLowerCase();
    this.favourited = json['favourited'];
    this.favCount = json['favCount'];
    this.myReaction = json['reaction'];
    this.renoteCount = json['renoteCount'];
    this.replyCount = json['replyCount'];
    this.files = json['files'];
    this.renote = json['renote'];
    this.notificationType = json['notificationType'];
    this.isRead = json['isRead'];
    this.notificationNote = json['notificationNote'];
  }

// TODO: status from mastodon return
  Item.fromMisskey(Map v, Instance instance) {
    int countreacts(Map r) {
      int reactions = 0;
      if (r != null) {
        r.forEach((react, number) => reactions += number);
      }
      return reactions;
    }

    if (v["user"] != null &&
        v["id"] != null &&
        v["deletedAt"] == null &&
        !v.containsKey("deletedAt")) {
      try {
        List<File> files = new List();

        if (v["files"] != null) {
          for (var fileJson in v["files"]) {
            if (fileJson != null) {
              File newFile = File.fromMisskey(fileJson);
              files.add(newFile);
            }
          }
        }

        if (v["renoteId"] != null && v["deletedAt"] == null) {
          this.renote = Item.fromMisskey(v["renote"], instance);
        }

        if (v["user"] != null) {
          User user = new User.fromMisskey(v["user"], instance);
          this.author = user;
        }

        this.id = v["id"];
        this.date = v["createdAt"];
        this.body = v["text"] ?? "";
        this.renoteCount = v["renoteCount"] ?? 0;
        this.replyCount = v["repliesCount"] ?? 0;
        this.files = files;
        this.myReaction = v["myReaction"] ?? null;
        this.visibility = v["visibility"] ?? null;
        this.url = v["uri"];
        this.files = files;
        this.favourited =
            v["isFavorited"] ?? (v["myReaction"] ?? false) ?? false;
        this.favCount = countreacts(v["reactionCounts"]) ?? null;
        this.contentWarning = v["cw"] ?? null;

        if (v["type"] != null && v["deletedAt"] == null) {
          this.isRead = v["isRead"];
          this.notificationType = v["type"];
          if (v["note"] != null) {
            this.notificationNote = Item.fromMisskey(v["note"], instance);
          }
        }
      } catch (e) {
        throw Exception(e);
      }
    }
  }

  Widget statusFiles() {
    switch (this.files.length) {
      case 0:
        return null;
      case 1:
        return Container(
          child: Image.network(
            this.files[0].thumbnailUrl,
            fit: BoxFit.contain,
          ),
        );
      case 2:
        return FittedBox(
            child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Image.network(
              this.files[0].thumbnailUrl,
              fit: BoxFit.contain,
            ),
            Image.network(
              this.files[1].thumbnailUrl,
              fit: BoxFit.contain,
            ),
          ],
        ));
      case 3:
        return Column(children: <Widget>[
          FittedBox(
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Image.network(
                this.files[0].thumbnailUrl,
                fit: BoxFit.contain,
              ),
              Image.network(
                this.files[1].thumbnailUrl,
                fit: BoxFit.contain,
              ),
            ],
          )),
          Container(
            child: Image.network(
              this.files[2].thumbnailUrl,
              fit: BoxFit.contain,
            ),
          ),
        ]);
      case 4:
        return Column(children: <Widget>[
          FittedBox(
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Image.network(
                this.files[0].thumbnailUrl,
                fit: BoxFit.contain,
              ),
              Image.network(
                this.files[1].thumbnailUrl,
                fit: BoxFit.contain,
              ),
            ],
          )),
          FittedBox(
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Image.network(
                this.files[2].thumbnailUrl,
                fit: BoxFit.contain,
              ),
              Image.network(
                this.files[3].thumbnailUrl,
                fit: BoxFit.contain,
              ),
            ],
          )),
        ]);
      default:
        return Column(children: <Widget>[
          FittedBox(
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Image.network(
                this.files[0].thumbnailUrl,
                fit: BoxFit.contain,
              ),
              Image.network(
                this.files[1].thumbnailUrl,
                fit: BoxFit.contain,
              ),
            ],
          )),
          FittedBox(
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Image.network(
                this.files[2].thumbnailUrl,
                fit: BoxFit.contain,
              ),
              Image.network(
                this.files[3].thumbnailUrl,
                fit: BoxFit.contain,
              ),
            ],
          )),
          Container(
            width: double.infinity,
            child: FlatButton(
              color: Colors.grey,
              onPressed: () => {},
              child: Center(child: Text("More")),
            ),
          ),
        ]);
    }
  }

  Map<String, dynamic> toJson() => _$ItemToJson(this);
}

IconData visIcon(String visibility) {
  switch (visibility) {
    case "public":
      return Icons.public;
    case "home":
      return Icons.home;
    case "followers":
      return Icons.group;
    case "specified":
      return Icons.message;
  }
  return Icons.language;
}

Icon notificationTypeIcon(String notificationType) {
  switch (notificationType) {
    case "reply":
      return Icon(Icons.reply);
    case "renote":
      return Icon(Icons.repeat);
    case "reaction":
      return Icon(Icons.star);
    case "mention":
      return Icon(Icons.alternate_email);
    case "follow":
      return Icon(Icons.person_add);
  }
}

String notificationTypeString(String notificationType) {
  switch (notificationType) {
    case "reply":
      return " replied to your status.";
    case "renote":
      return " renoted your status.";
    case "reaction":
      return " favourited your status.";
    case "mention":
      return " mentioned you";
    case "follow":
      return " followed you";
  }
  return "";
}