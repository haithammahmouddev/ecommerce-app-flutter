import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../common/errors/failure.dart';
import '../../../../common/local_storage/loacal_storage_service.dart';
import '../../domain/entities/categories_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repos/category_repo.dart';
import '../model/category_model.dart';
import '../model/product_model.dart';

class CategoryRepoImpl implements CategoryRepo {
  @override
  Future<Either<Failure, List<CategoryEntity>>> fetchAllCategories() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('categories')
              .where('parentId', isEqualTo: "")
              .get();
      final List<CategoryModel> categoryModelList = querySnapshot.docs
          .map(
            (category) =>
                CategoryModel.fromFirebaseJson(category.data(), category.id),
          )
          .toList();
      final List<CategoryEntity> categoryEntityList = categoryModelList
          .map((e) => e.toEntity())
          .toList();
      await LocalStorageService.categoriesRepo.saveData(categoryModelList);
      return right(categoryEntityList);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getSubCategories({
    required String categoryId,
  }) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('categories')
          .where('parentId', isEqualTo: categoryId)
          .get();
      final List<CategoryModel> subCategoriesModel = querySnapshot.docs
          .map((doc) => CategoryModel.fromFirebaseJson(doc.data(), doc.id))
          .toList();
      final List<CategoryEntity> subCategories = subCategoriesModel
          .map((e) => e.toEntity())
          .toList();
      await LocalStorageService.subCategoriesRepo.saveData(
        subCategoriesModel,
        customKey: categoryId,
      );

      return right(subCategories);
    } catch (e) {
      return left(
        const ServerFailure('Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> fetchProductsForCategory({
    required String categoryId,
  }) async {
    try {
      final Map<String, ProductModel> productsById = {};
      final directQuery = await FirebaseFirestore.instance
          .collection('Products')
          .where('CategoryId', isEqualTo: categoryId)
          .get();

      for (final doc in directQuery.docs) {
        final model = ProductModel.fromFirebaseJson(doc.data(), doc.id);
        productsById[model.id.isNotEmpty ? model.id : doc.id] = model;
      }
      final linkQuery = await FirebaseFirestore.instance
          .collection('ProductCategory')
          .where('categoryId', isEqualTo: categoryId)
          .get();

      final linkedProductIds = linkQuery.docs
          .map((doc) => doc.data()['productId'] as String?)
          .whereType<String>()
          .where((id) => id.isNotEmpty && !productsById.containsKey(id))
          .toSet()
          .toList();
      for (var i = 0; i < linkedProductIds.length; i += 30) {
        final chunk = linkedProductIds.sublist(
          i,
          i + 30 > linkedProductIds.length ? linkedProductIds.length : i + 30,
        );
        final chunkQuery = await FirebaseFirestore.instance
            .collection('Products')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        for (final doc in chunkQuery.docs) {
          final model = ProductModel.fromFirebaseJson(doc.data(), doc.id);
          productsById[model.id.isNotEmpty ? model.id : doc.id] = model;
        }
      }

      final List<ProductModel> products = productsById.values.toList();

      if (products.isEmpty) {
        return right(<ProductEntity>[]);
      }

      final List<ProductEntity> productsEntity = products
          .map((e) => e.toEntity())
          .toList();

      await LocalStorageService.categoriesProductsRepo.saveData(
        products,
        customKey: 'category_products_$categoryId',
      );

      return right(productsEntity);
    } on FirebaseException catch (e) {
      return left(
        ServerFailure(e.message ?? 'حدث خطأ أثناء جلب البيانات من الخادم.'),
      );
    } catch (e) {
      return left(
        const ServerFailure('Something went wrong. Please try again.'),
      );
    }
  }
}
