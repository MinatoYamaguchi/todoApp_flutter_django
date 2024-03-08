import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../pages/todo_add.dart';
import '../pages/todo_detail.dart';
import '../pages/todo_list.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  int getDetailPageArguments(dynamic todoId) => todoId;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'todo app',
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          )),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const TodoList(),
          '/add': (context) => const TodoAddPage(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/detail') {
            return MaterialPageRoute(builder: (context) {
              return TodoDetail(
                todoId: getDetailPageArguments(settings.arguments),
              );
            });
          }
        });
  }
}
