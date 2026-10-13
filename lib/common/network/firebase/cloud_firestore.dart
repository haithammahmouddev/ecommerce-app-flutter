import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_services.dart';

class CloudFirestore implements DatabaseServices {
  final FirebaseFirestore firestore;
  CloudFirestore(this.firestore);

  @override
  Future<void> addData({required String path, required Map<String, dynamic> data}) async =>
      await firestore.collection(path).add(data);

  @override
  Future<void> setData({required String path, required String docId, required Map<String, dynamic> data}) async =>
      await firestore.collection(path).doc(docId).set(data);

  @override
  Future<void> updateData({required String path, required String docId, required Map<String, dynamic> data}) async =>
      await firestore.collection(path).doc(docId).update(data);

  @override
  Future<void> deleteData({required String path, required String docId}) async =>
      await firestore.collection(path).doc(docId).delete();

  @override
  Future<dynamic> getData({required String path, String? docId, Map<String, dynamic>? query}) async {
    if (docId != null) {
      final data = await firestore.collection(path).doc(docId).get();
      return data.data();
    }

    Query<Map<String, dynamic>> q = firestore.collection(path);

    if (query != null) {
      if (query['where'] != null) {
        final whereClause = query['where'] as Map<String, dynamic>;
        q = q.where(whereClause['field'], isEqualTo: whereClause['value']);
      }
      if (query['orderBy'] != null) {
        q = q.orderBy(query['orderBy'], descending: query['descending'] ?? true);
      }
      if (query['limit'] != null) q = q.limit(query['limit']);
    }

    final result = await q.get();

    return result.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }





}