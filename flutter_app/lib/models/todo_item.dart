import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_item.freezed.dart';
part 'todo_item.g.dart';

@freezed
class TodoItem with _$TodoItem {
  factory TodoItem({
    int? id,
    required String title,
    required String content,
    @Default(false) bool isCompleted,
  }) = _TodoItem;
  factory TodoItem.fromJson(Map<String, dynamic> json) =>
      _$TodoItemFromJson(json);
}
