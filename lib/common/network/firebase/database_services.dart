
abstract class DatabaseServices {
  Future<void> addData({required String path, required Map<String, dynamic> data});
  Future<void> setData({required String path, required String docId, required Map<String, dynamic> data});
  Future<void> updateData({required String path, required String docId
    , required Map<String, dynamic> data});
  Future<void> deleteData({required String path, required String docId});
  Future<dynamic> getData({required String path, String? docId, Map<String, dynamic>? query});
}