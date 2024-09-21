import 'package:librairian/models/item.dart';
import 'package:librairian/repositories/item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;

part 'item.g.dart';

@riverpod
ItemRepository itemRepository(ItemRepositoryRef ref) {
  return ItemRepository(http.Client());
}

@riverpod
class ItemController extends _$ItemController {
  @override
  Future<Item?> build(String? id) async {
    if (id == null) {
      return null;
    }
    Item? newItem = await ref.watch(itemRepositoryProvider).getItem(id);
    return newItem;
  }

  Future<void> delete(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      ref.watch(itemRepositoryProvider).deleteItem(id);
      return Item();
    });
  }

  FutureOr<Item?> patch(Item item) async {
    item.id = state.value!.id;
    var newItem = await ref.read(itemRepositoryProvider).patchItem(item);
    state = AsyncValue.data(newItem);
    return newItem;
  }

  Future<Item?> add(Item item) async {
    Item? newItem = await ref.read(itemRepositoryProvider).postItem(item);
    state = AsyncValue.data(newItem);
    return newItem;
  }

  Future<Item?> save(Item item) async {
    if (item.id == null) {
      return add(item);
    } else {
      return patch(item);
    }
  }
}
