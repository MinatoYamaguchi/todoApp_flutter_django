import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/item_provider.dart';

class TodoDetail extends ConsumerWidget {
  const TodoDetail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItem = ref.watch(itemProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Todo詳細',
        ),
      ),
      body: Center(
        child: asyncItem.when(
          data: (item) => SizedBox(
            width: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(bottom: 4.0),
                  child: const Text('タイトル'),
                ),
                Card(
                  margin: const EdgeInsets.only(bottom: 40.0),
                  child: Container(
                    margin: const EdgeInsets.only(top: 2.0, left: 3.0),
                    width: 300,
                    height: 40,
                    child: Text(item!.title),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(bottom: 4.0),
                  child: const Text('内容'),
                ),
                Card(
                  margin: const EdgeInsets.only(bottom: 40.0),
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    width: 300,
                    height: 200,
                    child: Text(item.content),
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () {
                      changeTodoList(item, ref);
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      item.isCompleted == false ? '完了にする' : '未完了にする',
                    ),
                  ),
                ),
              ],
            ),
          ),
          error: (error, stackTrace) {
            debugPrint(error.toString());
            return const Text('エラーが発生しました');
          },
          loading: () => const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
