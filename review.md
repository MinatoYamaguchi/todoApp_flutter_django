# Todo アプリレビュー

## 全体・改善

- Flutter で TodoList の制御をしている部分を DRF 側に押し付けたい

  今は TodoItem を DRF 側に保存するだけになってしまっているので勿体無い

  - たとえば、全権取得してから `completedList` と `unCompletedList` に分けていると思います。
    クエリーパラメータなどを使って DRF で filter するようにしたいですね。その方が、ソートが入った時やキーワード検索の要件があっても柔軟に対応できるようになります。

  - 作成や編集時も、作成時に ID だけを取得してリストに追加する実装になっているので、リスト自体を DRF から再取得して最新状態に更新するようにしたいですね。作成・編集後はリストを取得し直す処理が必要。

  - 詳細画面の際も、リストからそのまま渡すのではなく DRF から TodoItem の詳細を取得するようにしたいです。業務だと、リスト表示では渡さないけど、詳細では集計するみたいなこともありうるし（リストの TodoItem をそのまま渡すだけでは不十分）、最新情報を表示した方がいいのでその都度取得するようにしましょう。

- pre-commit がおそらく入っていない。

  業務では必須なので、忘れないようにしてほしい。
  特に VSCode を起動した際の、terminal の隣にある `PROBLEMS` タブは見る癖をつけて欲しいです。
  ここに出る warning は基本的には消すようにしましょう。

  ```console
  $ pre-commit install
  ```

## Flutter

### 全体を通して気になった点

  - 不必要な変数宣言、際代入がない場合は `final` を使うのが安全
  - 不必要な `dynamic` 型の使用

### 詳細

- `dynamic` 型は基本的には使わないようにしたい。

  `dynamic` はデータ型による制限を無視してしまうので、Dart の静的型付け言語の良さが半減してしまう。
  リンターによるエラーが出ないので、実行時によくわからないエラーになりがち。汎用的なデータ型を使いたい場合は `Object` 型を使うと良いです、全てのデータ型の祖先にあたるので。

  ```diff:main.dart
  - int getDetailPageArguments(dynamic todoId) => todoId;
  + int getDetailPageArguments(int todoId) => todoId;
  ```

- riverpod の `Provider` には基本的に `autoDispose` をつける。

  `autoDispose` をつけることで、`Provider` が使われていない時は、データを破棄してくれるのでアプリのパフォーマンスがよくなります。
  このデータの規模だとあんまりですが、`Provider` で保持するデータが多いとその分メモリも食うので不要なデータは破棄しておきたいですね。

  ```diff:providers/bottom_index.dart
  - final bottomIndexProvider = StateProvider<int>((ref) => 0);
  + final bottomIndexProvider = StateProvider.autoDispose<int>((_) => 0);
  ```

- 非同期なデータ `Future` を扱う場合は [`FutureProvider`](https://riverpod.dev/docs/providers/future_provider) を使う。

  これは業務で一番と言って良いほど使う使い方なので覚えておくと良いともいます。riverpod は `FutureProvider` と `StateProvider` が使えればほぼほぼなんとかなります。`StateNotifierProvider` はほぼ出番なしです。
  下に、`FutureProvider` を使って、`TodoItem` を取得する例を書いておきます。

  ```dart:providers/item_provider.dart
  final todoListProvider = FutureProvider.autoDispose<List<TodoItem>>(
    (_) async {
        final response = await http.get(
            Uri.parse('http://10.0.2.2:8000/api/todo_item'),
        );
        if (response.statusCode == 200) {
            final data = json.decode(response.body) as List;
            // この書き方は上手
            return data.map((json) => TodoItem.fromJson(json)).toList();
        }
        return <TodoItem>[];
    }
  )
  ```

  データを取得する時はこんな感じ、`todoList` には `TodoItem` のリストが保存されて、データ取得時のステータス(完了時は `data`、エラー時は `error`、取得中は `loading`) のデータが返されるようになっている。こ
  ```dart
  final todoList = ref.watch(todoListProvider).when(
    data: (data) => data,
    error: (error, stackTrace) => <TodoItem>[];
    loading: () => <TodoItem>[];
  );
  ```

- `Uri.parse` よりは `Uri.http` or `Uri.https` を使いたい。

  Dart では `Uri` クラスに `Uri.http` や `Uri.https` コンストラクタあるので、これを使った方がいいです。
  引数には、ドメイン・ポートとパスを指定してあげればいいです。

  ```diff:providers/item_provider.dart
  - final response = await http.get(
  -   Uri.parse('http://10.0.2.2:8000/api/todo_item'),
  - );
  + final response = await http.get(
  +   Uri.http('10.0.2.2:8000', 'api/todo_item'),
  + );
  ```

- Dart に Python でいう `pass` キーワードに相当するものはないです。`Path` は Fluter の描画のためのクラスです。

  ```diff:providers/item_provider.dart
  Future<void> getTodoList() async {
    try {
        final response = await http.get(
            Uri.parse('http://10.0.2.2:8000/api/todo_item'),
        );
        Uri.http('10.0.2.2:8000', 'api/todo_item');
        if (response.statusCode == 200) {
            final data = json.decode(response.body) as List<dynamic>;
            state.todoList = data.map((json) => TodoItem.fromJson(json)).toList();
  -     } else {
  -         Path;
        }
    } catch (error) {
        debugPrint(error.toString());
    }
  }
  ```

- 再代入したいものは基本的に `final` で宣言する。

  実装されているものだと、変数扱いになってしまう。`final TodoItem oldItem = state.todoList.firstWhere((e) => e.id == item.id);` のようにすれば、型明示はできますが `final` で初期値を与える場合は、データ型が決定してしまうのでデータ型の明示は基本的には不要です（過剰なコードになります）。

  ```diff:providers/item_provider.dart
  - TodoItem oldItem = state.todoList.firstWhere((e) => e.id == item.id);
  + final oldItem = state.todoList.firstWhere((e) => e.id == item.id);
  ```

- `completedList` と `unCompletedList` はデータ内で管理する必要はないです。

  下みたいな getter を準備すれば管理対象は `todoList` 一つで十分になります。`completedList` と `unCompletedList` のように分けて管理してしまうと、どうしてもデータの整合性が取れなくなりがちなので管理場所は 1 箇所の方がいいですね。

  ```diff:providers/item_provider.dart
  - List<TodoItem> completedList = [];
  - List<TodoItem> unCompletedList = [];
  + List<TodoItem> get completedList => todoList.where((element) => element.isCompleted).toList();
  + List<TodoItem> get unCompletedList => todoList.where((element) => !element.isCompleted).toList();
  ```

- モデルの定義は [Freezed](https://pub.dev/packages/freezed) を使う。

  業務では `toJson` や `fromJson` が必要な場合は Freezed パッケージを使います。
  クラスを定義しておけば、自動でコード生成してくれるので楽です。あと、`copyWith` メソッドも生成してくれるのは嬉しいところ。`copyWith` メソッドは特定のプロパティだけを書き換えた新しいインスタンスを生成してくれるメソッド。たとえば、タイトルだけを上書きしたいみたいなことが可能。

- `id` は nullable にしてあげれば、`NonIdTodoItem` は不要になります。

  ```diff:models/todo_item.dart
  - final int id;
  + final int? id;
  ```

  編集画面と作成画面は基本的に同じ画面を使い回すことがほとんどです。そのため、`TodoItem` を作成画面に渡すようにしておけば、作成か編集か判定できるようになります。
  「保存」みたいなボタンを押した際に編集か作成化は `TodoItem.id` が `null` かどうかで分岐できます。

  ```dart
  // todoItem は画面引数として受け取ったもの
  if (todoItem == null) {
    // 作成
  } else {
    // 編集
  }
  ```

- 不要な `Widget` の切り分け

  `TodoList` 内での `final todoLists = ref.watch(todoItemProvider);` で `Todo` アイテムの状態は `watch` できているので、`todoLists.unCompletedList` や `todoLists.completedList` のようにすることで参照できます。

  ```diff:pages/todo_list.dart
  - body: bottomIndex == 0
  -   ? const UnCompletedListBuilder()
  -   : const CompletedListBuilder(),
  + body: ListBuilder(
  +   todoList: bottomIndex == 0 ? todoLists.unCompletedList: todoLists.completedList,
  + ),
  ```

- 不要な `ConsumerWidget`

  `WidgetRef` が必要ない場合は `StatelessWidget` で大丈夫です。あと、このファイル内でしか使用していない場合はプライベートな `Widget` にしておいた方が安全です。Dart ではクラスや変数・プロパティを `_` で始めることでプライベートな変数やクラスにすることができます。プライベートにするとほかのファイルとのクラスや変数の衝突、予期していない参照を避けることができるのでより安全です。

  ```diff:pages/todo_list.dart
  - class ListBuilder extends ConsumerWidget {
  -   const ListBuilder({required this.todoList, super.key});
  -
  -   final List<TodoItem> todoList;
  -
  -   @override
  -   Widget build(BuildContext context, WidgetRef ref) {
  -       return Center(
  -           child: ListView.builder(
  -               itemCount: todoList.length,
  -               itemBuilder: (context, index) {
  -                   return Card(
  -                       child: ListTile(
  -                           title: Text(
  -                               '${index + 1} ${todoList[index].title}',
  -                           ),
  -                           onTap: () {
  -                               Navigator.of(context).pushNamed(
  -                                   '/detail',
  -                                   arguments: todoList[index].id,
  -                               );
  -                           },
  -                       ),
  -                   );
  -               },
  -           ),
  -       );
  -   }
  - }
  + class _ListBuilder extends StatelessWidget {
  +   const _ListBuilder({required this.todoList, super.key});
  +
  +   final List<TodoItem> todoList;
  +
  +   @override
  +   Widget build(BuildContext context) {
  +       return Center(
  +           child: ListView.builder(
  +               itemCount: todoList.length,
  +               itemBuilder: (context, index) {
  +                   // 細かいですが、一回変数に入れておくと修正も楽だし、間違って違う TodoItem を参照してしまったみたいな事故も防げます
  +                   final todo = todoList[index];
  +                   return Card(
  +                       child: ListTile(
  +                           title: Text(
  +                               '${index + 1} ${todo.title}',
  +                           ),
  +                           onTap: () {
  +                               Navigator.of(context).pushNamed(
  +                                   '/detail',
  +                                   arguments: todo.id,
  +                               );
  +                           },
  +                       ),
  +                   );
  +               },
  +           ),
  +       );
  +   }
  + }
  ```

## Django

### 全体を通して気になった点

  - リンターやフォーマッターが入っていない、Python だと black なんかを使っていると思います。
  - `requirements.txt`(pip) や `pyproject.toml`(poetry) などの、パッケージ管理ファイルがないです。業務では poetry を使用します。
  - 使用していないインポート等は消しましょう。
  - .gitignore ファイルとがない。仮想環境のファイル(`.venv`)やデータベースのファイル(sqlite)、`__pycache__` などは git で管理する必要はないので外しておくようにしてください。

### 詳細

- 命名規則

  Python ではクラスは PascalCase を使用します。単語の頭を大文字にしてつなげる命名規則。

  ```diff:flutter_api/models.py
  - class Todo_Item(models.Model):
  + class TodoItem(models.Model):
  ```

  また、変数やプロパティは snake_case を使用します。全て小文字にして、単語の間をアンダースコア `_` を使用してつなげる命名規則。
  ```diff:flutter_api/models.py
  - isCompleted = models.BooleanField(default=False)
  + is_completed = models.BooleanField(default=False)
  ```

- `ModelViewSet` の仕様は避ける

  `ModelViewSet` は個人開発などで、使う分には早いし、記述量も減って楽だと思います。
  ただ、CRUD 全てのエンドポイントが自動でホスティングされてしまいます。
  今回の例だと、削除用のエンドポイントも建てられているので、モバイル外からエンドポイントを直接叩くことで `TodoItem` を削除することができてしまうのでセキュリティ的に良くありません。

  以下みたいな感じで、必要なものだけ継承するようにします。

  ```python
  from rest_framework.viewsets import GenericViewSet, mixins

  class TodoView(mixins.CreateModelMixin, mixins.ListModelMixin, mixins.UpdateModelMixin, GenericViewSet):
  ```

  ソースコード見てもらえればわかりますが、`ModelViewSet` は `GenericViewSet` と全ての `mixins` を継承しているだけです。

  ```python:rest_framework/viewsets.py
  class ModelViewSet(mixins.CreateModelMixin,
                   mixins.RetrieveModelMixin,
                   mixins.UpdateModelMixin,
                   mixins.DestroyModelMixin,
                   mixins.ListModelMixin,
                   GenericViewSet):
  ```
