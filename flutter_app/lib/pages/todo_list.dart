import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_item.dart';
import '../providers/bottom_index_provider.dart';
import '../providers/item_provider.dart';

class TodoList extends ConsumerWidget {
  const TodoList({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoLists = ref.watch(todoItemProvider);
    int bottomIndex = ref.watch(bottomIndexProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          bottomIndex == 0
              ? 'Todo一覧 (未完了${todoLists.unCompletedList.length}/${todoLists.todoList.length})'
              : 'Todo一覧 (完了済${todoLists.completedList.length}/${todoLists.todoList.length})',
        ),
      ),
      body: bottomIndex == 0
          ? const UnCompletedListBuilder()
          : const CompletedListBuilder(),
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

class CompletedListBuilder extends ConsumerWidget {
  const CompletedListBuilder({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedList = ref.watch(todoItemProvider).completedList;
    return ListBuilder(todoList: completedList);
  }
}

class UnCompletedListBuilder extends ConsumerWidget {
  const UnCompletedListBuilder({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unCompletedList = ref.watch(todoItemProvider).unCompletedList;
    return ListBuilder(todoList: unCompletedList);
  }
}

class ListBuilder extends ConsumerWidget {
  const ListBuilder({required this.todoList, super.key});
  final List<TodoItem> todoList;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ListView.builder(
        itemCount: todoList.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(
                '${index + 1} ${todoList[index].title}',
              ),
              onTap: () {
                Navigator.of(context).pushNamed(
                  '/detail',
                  arguments: todoList[index].id,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
