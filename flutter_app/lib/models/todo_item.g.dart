// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TodoItemImpl _$$TodoItemImplFromJson(Map<String, dynamic> json) =>
    _$TodoItemImpl(
      id: json['id'] as int?,
      title: json['title'] as String,
      content: json['content'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$TodoItemImplToJson(_$TodoItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'isCompleted': instance.isCompleted,
    };
