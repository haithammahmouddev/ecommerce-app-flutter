import 'package:hive_ce_flutter/adapters.dart';

class LocalRepository<T> {
  final String boxName;
  final String key;


  final T Function(dynamic raw)? fromStorage;

  LocalRepository({
    required this.boxName,
    required this.key,
    this.fromStorage,
  });

  late final Box<dynamic> _box;

  Future<void> init<A>({
    required TypeAdapter<A> adapter,
    required int typeId,
  }) async {
    if (!Hive.isAdapterRegistered(typeId)) {
      Hive.registerAdapter<A>(adapter);
    }

    try {
      _box = await Hive.openBox<dynamic>(boxName);
    } catch (e) {
      try {
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box(boxName).close();
        }
        await Hive.deleteBoxFromDisk(boxName);
      } catch (_) {
      }
      _box = await Hive.openBox<dynamic>(boxName);
    }
  }

  Future<void> initRaw() async {
    try {
      _box = await Hive.openBox<dynamic>(boxName);
    } catch (e) {
      try {
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box(boxName).close();
        }
        await Hive.deleteBoxFromDisk(boxName);
      } catch (_) {
      }
      _box = await Hive.openBox<dynamic>(boxName);
    }
  }

  T? getData({String? customKey}) {
    final activeKey = customKey ?? key;
    final data = _box.get(activeKey);
    if (data == null) return null;
    return fromStorage != null ? fromStorage!(data) : data as T;
  }

  Future<void> saveData(T data, {String? customKey}) async {
    final activeKey = customKey ?? key;
    await _box.put(activeKey, data);
  }

  Future<void> updateData(T Function(T currentData) onUpdate, {String? customKey}) async {
    final activeKey = customKey ?? key;
    final currentData = getData(customKey: activeKey);
    if (currentData == null) return;
    await saveData(onUpdate(currentData), customKey: activeKey);
  }

  Future<void> clearData({String? customKey}) async {
    final activeKey = customKey ?? key;
    await _box.delete(activeKey);
  }

  Future<void> clearBox() async {
    await _box.clear();
  }
}