// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Instance _$InstanceFromJson(Map<String, dynamic> json) {
  return Instance(
      json['uri'] as String,
      json['title'] as String,
      json['description'] as String,
      json['version'] as String,
      json['type'] as String);
}

Map<String, dynamic> _$InstanceToJson(Instance instance) => <String, dynamic>{
      'type': instance.type,
      'uri': instance.uri,
      'title': instance.title,
      'description': instance.description,
      'version': instance.version
    };
