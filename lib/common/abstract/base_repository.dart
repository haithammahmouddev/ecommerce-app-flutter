import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit_store/common/errors/exceptions.dart';
import 'package:get/get.dart';


 abstract class BaseRepositoryController<T> extends GetxController {
  final FirebaseFirestore db = FirebaseFirestore.instance;

   QueryDocumentSnapshot? lastFetchedDocument;

   Future<List<T>> fetchAllItems();

   Future<T> fetchSingleItem(String id);

   Future<String> addItem(T item);

   Future<void> updateItem(T item);

   Future<void> updateSingleField(String id, Map<String, dynamic> json);

   Future<void> deleteItem(T item);

   Future<List<T>> getAllItems() async {
    return await _handleFirestoreOperation(() => fetchAllItems());
  }

   Future<T> getSingleItem(String id) async {
    return await _handleFirestoreOperation(() => fetchSingleItem(id));
  }

   Future<String> addNewItem(T item) async {
    return await _handleFirestoreOperation(() => addItem(item));
  }

   Future<void> updateItemRecord(T item) async {
    await _handleFirestoreOperation(() => updateItem(item));
  }

   Future<void> updateSingleItemRecord(String id, Map<String, dynamic> json) async {
    await _handleFirestoreOperation(() => updateSingleField(id, json));
  }

   Future<void> deleteItemRecord(T item) async {
    await _handleFirestoreOperation(() => deleteItem(item));
  }

   Future<List<T>> fetchPaginatedItems(int limit) async {
    return await _handleFirestoreOperation(() async {
      Query query = getPaginatedQuery(limit);

       if (lastFetchedDocument != null) {
        query = query.startAfterDocument(lastFetchedDocument!);
      }

       final querySnapshot = await query.get();

       if (querySnapshot.docs.isNotEmpty) {
        lastFetchedDocument = querySnapshot.docs.last;
      }

       return querySnapshot.docs.map((doc) => fromQueryDocSnapshot(doc)).toList();
    });
  }

   Query getPaginatedQuery(int limit);

   T fromQueryDocSnapshot(QueryDocumentSnapshot<Object?> doc);

   Future<R> _handleFirestoreOperation<R>(Future<R> Function() operation) async {
    try {
      return await operation();
    } on FirebaseException catch (e) {
       throw ServerException(e.code).message;
    } catch (e) {
       throw 'Something went wrong. Please try again';
    }
  }
}
