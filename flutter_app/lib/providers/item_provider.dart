import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/todo_item.dart';
import 'detail_todo_id_provider.dart';

Future<void> addTodoList(TodoItem item, WidgetRef ref) async {
  try {
    final response = await http.post(
      Uri.http('10.0.2.2:8000', 'api/todo_item/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(item.toJson()),
    );
    if (response.statusCode == 201) {
      // ignore: unused_result
      ref.refresh(unCompletedListProvider);
    } else {
      debugPrint(response.body);
    }
  } catch (error) {
    debugPrint(error.toString());
  }
}

Future<void> changeTodoList(TodoItem item, WidgetRef ref) async {
  try {
    final newItem = item.copyWith(isCompleted: !item.isCompleted);
    final response = await http.patch(
      Uri.http('10.0.2.2:8000', '/api/todo_item/${item.id}/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newItem.toJson()),
    );
    if (response.statusCode == 200) {
      ref
        // ignore: unused_result
        ..refresh(unCompletedListProvider)
        // ignore: unused_result
        ..refresh(completedListProvider);
    } else {
      debugPrint(response.toString());
    }
  } catch (error) {
    debugPrint(error.toString());
  }
}

final completedListProvider =
    FutureProvider.autoDispose<List<TodoItem>>((_) async {
  final response = await http.get(
    Uri.http('10.0.2.2:8000', 'api/todo_item/', {'isCompleted': 'true'}),
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body) as List;
    return data.map((json) => TodoItem.fromJson(json)).toList();
  }
  return <TodoItem>[];
});

final unCompletedListProvider =
    FutureProvider.autoDispose<List<TodoItem>>((_) async {
  final response = await http.get(
    Uri.http('10.0.2.2:8000', 'api/todo_item/', {'isCompleted': 'false'}),
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body) as List;
    return data.map((json) => TodoItem.fromJson(json)).toList();
  }
  return <TodoItem>[];
});

final itemProvider = FutureProvider.autoDispose<TodoItem?>((ref) async {
  final todoId = ref.watch(todoIdProvider);
  final id = int.parse(todoId.toString());
  final response = await http
      .get(Uri.http('10.0.2.2:8000', 'api/todo_item/', {'id': id.toString()}));
  if (response.statusCode == 200) {
    final data = json.decode(response.body) as List;
    final itemList = data.map((json) => TodoItem.fromJson(json)).toList();
    debugPrint(response.body);
    return itemList[0];
  }
  return null;
});
