import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_item.dart';
import '../providers/item_provider.dart';

class TodoAddPage extends ConsumerStatefulWidget {
  const TodoAddPage({super.key});
  @override
  ConsumerState<TodoAddPage> createState() => _TodoAddPageState();
}

class _TodoAddPageState extends ConsumerState<TodoAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _contentKey = GlobalKey<FormFieldState>();
  final _titleKey = GlobalKey<FormFieldState>();
  Map<String, String> formValue = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Todo追加',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 40.0),
                width: 300,
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'タイトル',
                  ),
                  maxLength: 30,
                  keyboardType: TextInputType.multiline,
                  key: _titleKey,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '入力してください';
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 40.0),
                width: 300,
                child: TextFormField(
                  minLines: 6,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: '内容',
                  ),
                  keyboardType: TextInputType.multiline,
                  key: _contentKey,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '入力してください';
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              SizedBox(
                width: 300,
                child: ElevatedButton(
                  onPressed: () {
                    if (!(_formKey.currentState!.validate())) return;
                    _formKey.currentState?.save();
                    NonIdTodoItem item;
                    item = NonIdTodoItem(
                      title: _titleKey.currentState?.value ?? '',
                      content: _contentKey.currentState?.value ?? '',
                      isCompleted: false,
                    );
                    ref.watch(todoItemProvider.notifier).addTodoList(item);
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Todoを追加',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
