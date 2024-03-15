import 'package:flutter_riverpod/flutter_riverpod.dart';

final todoIdProvider = StateProvider.autoDispose<int>((ref) => 1);
