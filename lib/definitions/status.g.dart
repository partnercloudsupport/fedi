// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Status _$StatusFromJson(Map<String, dynamic> json) {
  return Status(
      json['id'],
      json['date'],
      json['author'],
      json['url'],
      json['title'],
      json['body'],
      json['visibility'],
      json['favourited'],
      json['favCount'],
      json['myReaction'],
      json['renoteCount'],
      json['files']);
}

Map<String, dynamic> _$StatusToJson(Status instance) => <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'author': instance.author,
      'url': instance.url,
      'title': instance.title,
      'body': instance.body,
      'visibility': instance.visibility,
      'favourited': instance.favourited,
      'favCount': instance.favCount,
      'myReaction': instance.myReaction,
      'renoteCount': instance.renoteCount,
      'files': instance.files
    };
