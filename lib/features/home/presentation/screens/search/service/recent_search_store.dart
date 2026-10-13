import '../../../../../../common/local_storage/loacal_storage_service.dart';

class RecentSearchesStore {
  static const int maxItems = 8;

  Future<List<String>> load() async {
    try {
      return LocalStorageService.recentSearchesRepo.getData() ?? <String>[];
    } catch (_) {
      return <String>[];
    }
  }

  Future<List<String>> add(String query) async {
    final q = query.trim();
    if (q.isEmpty) return load();
    final items = await load();
    items.removeWhere((e) => e.toLowerCase() == q.toLowerCase());
    items.insert(0, q);
    if (items.length > maxItems) items.removeRange(maxItems, items.length);
    return _save(items);
  }

  Future<List<String>> remove(String query) async {
    final items = await load();
    items.removeWhere((e) => e.toLowerCase() == query.toLowerCase());
    return _save(items);
  }

  Future<List<String>> clear() => _save(<String>[]);

  Future<List<String>> _save(List<String> items) async {
    try {
      await LocalStorageService.recentSearchesRepo.saveData(items);
    } catch (_) {}
    return items;
  }
}