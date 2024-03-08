class TodoItem {
  TodoItem({
    required this.id,
    required this.title,
    required this.content,
    required this.isCompleted,
  });
  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      isCompleted: json['isCompleted'],
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'isCompleted': isCompleted,
      };
  final int id;
  final String title;
  final String content;
  bool isCompleted = false;

  void toggleIsCompleted() {
    isCompleted = !isCompleted;
  }
}

// idのないjson形式をあつかうため
class NonIdTodoItem {
  NonIdTodoItem({
    required this.title,
    required this.content,
    required this.isCompleted,
  });
  factory NonIdTodoItem.fromJson(Map<String, dynamic> json) {
    return NonIdTodoItem(
      title: json['title'],
      content: json['content'],
      isCompleted: json['isCompleted'],
    );
  }
  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'isCompleted': isCompleted,
      };

  final String title;
  final String content;
  bool isCompleted;
}
