import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_item.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TodoItemState {
  TodoItemState(this.todoList, this.completedList, this.unCompletedList) {
    initializeData();
  }
  List<TodoItem> todoList = [];
  List<TodoItem> completedList = [];
  List<TodoItem> unCompletedList = [];
  Future<void> initializeData() async {
    await getTodoList();
    completedList = todoList.where((e) => e.isCompleted).toList();
    unCompletedList = todoList.where((e) => !e.isCompleted).toList();
  }

  Future<void> getTodoList() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/todo_item'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        todoList =
            data.map<TodoItem>((json) => TodoItem.fromJson(json)).toList();
      } else {
        todoList = todoList;
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}

final todoItemProvider =
    StateNotifierProvider<TodoNotifier, TodoItemState>((ref) {
  return TodoNotifier();
});

class TodoNotifier extends StateNotifier<TodoItemState> {
  TodoNotifier() : super(TodoItemState([], [], []));
  Future<void> getTodoList() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/todo_item'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        state.todoList =
            data.map<TodoItem>((json) => TodoItem.fromJson(json)).toList();
      } else {
        Path;
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<void> addTodoList(NonIdTodoItem item) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/todo_item'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(item.toJson()),
      );
      if (response.statusCode == 201) {
        TodoItem newItem;
        final newId = json.decode(response.body)['id'];
        newItem = TodoItem(
          id: newId,
          title: item.title,
          content: item.content,
          isCompleted: false,
        );
        state = TodoItemState(
          state.todoList + [newItem],
          state.completedList,
          state.unCompletedList + [newItem],
        );
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<void> changeTodoList(TodoItem item) async {
    try {
      item.toggleIsCompleted();
      final response = await http.patch(
        Uri.parse('http://10.0.2.2:8000/api/todo_item/${item.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(item.toJson()),
      );
      if (response.statusCode == 200) {
        if (item.isCompleted == true) {
          TodoItem newItem;
          newItem = TodoItem(
            id: item.id,
            title: item.title,
            content: item.content,
            isCompleted: true,
          );
          TodoItem oldItem = state.todoList.firstWhere((e) => e.id == item.id);
          ;
          // oldItem = TodoItem(
          //   id: item.id,
          //   title: item.title,
          //   content: item.content,
          //   isCompleted: false,
          // );
          state.unCompletedList.remove(oldItem);
          state = TodoItemState(
            state.todoList,
            state.completedList + [newItem],
            state.unCompletedList,
          );
        } else {
          TodoItem newItem;
          newItem = TodoItem(
            id: item.id,
            title: item.title,
            content: item.content,
            isCompleted: false,
          );
          TodoItem oldItem = state.todoList.firstWhere((e) => e.id == item.id);
          // oldItem = TodoItem(
          //   id: item.id,
          //   title: item.title,
          //   content: item.content,
          //   isCompleted: true,
          // );
          state.completedList.remove(oldItem);
          state = TodoItemState(
            state.todoList,
            state.completedList,
            state.unCompletedList + [newItem],
          );
        }
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}
