import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_item.dart';
import '../providers/bottom_index_provider.dart';
import '../providers/detail_todo_id_provider.dart';
import '../providers/item_provider.dart';

class TodoList extends ConsumerWidget {
  const TodoList({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedList = ref.watch(completedListProvider).when(
          data: (data) => data,
          error: (error, stackTrace) => <TodoItem>[],
          loading: () => <TodoItem>[],
        );
    final unCompletedList = ref.watch(unCompletedListProvider).when(
          data: (data) => data,
          error: (error, stackTrace) => <TodoItem>[],
          loading: () => <TodoItem>[],
        );

    final bottomIndex = ref.watch(bottomIndexProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          bottomIndex == 0
              ? 'Todo一覧 (未完了${unCompletedList.length}/${completedList.length + unCompletedList.length})'
              : 'Todo一覧 (完了済${completedList.length}/${completedList.length + unCompletedList.length})',
        ),
      ),
      body: _ListBuilder(
        todoList: bottomIndex == 0 ? unCompletedList : completedList,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(
            '/add',
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: bottomIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: '未完了',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.done),
            label: '完了',
          ),
        ],
        onTap: (value) {
          ref.watch(bottomIndexProvider.notifier).update((state) => value);
        },
      ),
    );
  }
}

class _ListBuilder extends ConsumerWidget {
  const _ListBuilder({required this.todoList});
  final List<TodoItem> todoList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoId = ref.watch(todoIdProvider);
    return Center(
      child: ListView.builder(
        itemCount: todoList.length,
        itemBuilder: (context, index) {
          final todo = todoList[index];
          return Card(
            child: ListTile(
              title: Text(
                '${index + 1} ${todo.title}',
              ),
              onTap: () {
                ref.watch(todoIdProvider.notifier).update((state) => todoId);
                Navigator.of(context).pushNamed(
                  '/detail',
                );
              },
            ),
          );
        },
      ),
    );
  }
}
