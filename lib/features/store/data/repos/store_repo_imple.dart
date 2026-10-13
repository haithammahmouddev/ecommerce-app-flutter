import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:fit_store/common/errors/failure.dart';
import 'package:fit_store/common/local_storage/loacal_storage_service.dart';
import 'package:fit_store/features/home/domain/entities/product_entity.dart';
import 'package:fit_store/features/store/domain/entities/brand_entity.dart';
import '../../../../utils/helpers/network_manager.dart';
import '../../../home/data/model/product_model.dart';
import '../../domain/repos/store_repo.dart';
import '../models/brand_model.dart';

class StoreRepoImple implements StoreRepo {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const int _whereInBatchSize = 30;

  List<List<T>> _chunk<T>(List<T> items, int size) {
    final List<List<T>> chunks = [];
    for (var i = 0; i < items.length; i += size) {
      chunks.add(items.sublist(i, i + size > items.length ? items.length : i + size));
    }
    return chunks;
  }

  @override
  Future<Either<Failure, List<BrandEntity>>> fetchAllBrands() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
      await _db.collection('Brands').get();

      final List<BrandModel> allBrands = snapshot.docs
          .map((doc) => BrandModel.fromFirebaseJson(doc.data(), doc.id))
          .toList();

      final List<BrandEntity> brandsEntity = allBrands.map((e) => e.toEntity()).toList();

      await LocalStorageService.brandsRepo.saveData(allBrands, customKey: 'all_brands');
      return right(brandsEntity);
    } catch (e) {
      return left(const ServerFailure('Unable to load brands right now. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, List<BrandEntity>>> fetchFeaturedBrands() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _db
          .collection('Brands')
          .where('isFeatured', isEqualTo: true)
          .limit(4)
          .get();

      final List<BrandModel> featuredBrands = snapshot.docs
          .map((doc) => BrandModel.fromFirebaseJson(doc.data(), doc.id))
          .toList();

      final List<BrandEntity> featuredBrandsEntity =
      featuredBrands.map((e) => e.toEntity()).toList();

      await LocalStorageService.brandsRepo.saveData(featuredBrands, customKey: 'featured_brands');
      return right(featuredBrandsEntity);
    } catch (e) {
      return left(
          const ServerFailure('Unable to load featured brands right now. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> fetchProductsForBrand({required String brandId}) async {
    try {
      final snapshot = await _db
          .collection('Products')
          .where('Brand.id', isEqualTo: brandId)
          .get();

      final List<ProductModel> allBrandProducts =
      snapshot.docs.map((e) => ProductModel.fromFirebaseJson(e.data(), e.id)).toList();
      final List<ProductEntity> allBrandProductsEntities =
      allBrandProducts.map((e) => e.toEntity()).toList();

      await LocalStorageService.productsRepo.saveData(allBrandProducts, customKey: 'brand_product_$brandId');
      return right(allBrandProductsEntities);
    } catch (e) {
      return left(
          const ServerFailure('Unable to load products for this brand right now. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, List<BrandEntity>>>
  fetchBrandsForCategory({required String categoryId}) async {
    try {
      final brandCategoryQuery = await _db
          .collection('BrandCategory')
          .where('CategoryId', isEqualTo: categoryId)
          .get();

      final List<String> brandIds =
      brandCategoryQuery.docs.map((doc) => doc.data()['BrandId'] as String).toSet().toList();

      if (brandIds.isEmpty) {
        return const Right([]);
      }

      final List<BrandModel> categoryBrands = [];

      for (final batch in _chunk(brandIds, _whereInBatchSize)) {
        final brandsQuery = await _db
            .collection('Brands')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        final productsQuery = await _db
            .collection('Products')
            .where('Brand.id', whereIn: batch)
            .get();

        final Map<String, int> brandProductCounts = {};
        for (var doc in productsQuery.docs) {
          final brandId = doc.data()['Brand']?['id'] as String?;
          if (brandId != null) {
            brandProductCounts[brandId] = (brandProductCounts[brandId] ?? 0) + 1;
          }
        }

        for (var doc in brandsQuery.docs) {
          final brandId = doc.id;
          final productCount = brandProductCounts[brandId] ?? 0;

          if (productCount > 0) {
            categoryBrands.add(BrandModel.fromFirebaseJson(doc.data(), brandId));
          }
        }
      }

      final List<BrandEntity> categoryBrandsEntities =
      categoryBrands.map((brandModel) => brandModel.toEntity()).toList();

      await LocalStorageService.brandsRepo.saveData(categoryBrands, customKey: 'category_brands_$categoryId');
      return right(categoryBrandsEntities);
    } catch (e) {
      return left(
          const ServerFailure('Unable to load brands for this category right now. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> fetchProductsForCategory({
    required String categoryId,
  }) async {
    final bool isConnected = await NetworkManager.instance.isConnected();

    if (!isConnected) {
      final cachedProducts = LocalStorageService.categoriesProductsRepo.getData(
        customKey: 'products_categories_$categoryId',
      );

      if (cachedProducts != null && cachedProducts.isNotEmpty) {
        return right(cachedProducts.map((e) => e.toEntity()).toList());
      }
      return left(const NetworkFailure('No internet connection, please check your network.'));
    }

    try {
      final Map<String, ProductModel> productsById = {};

      final subCategoriesQuery = await _db
          .collection('categories')
          .where('parentId', isEqualTo: categoryId)
          .get();

      List<String> categoryIdsToQuery = [categoryId];
      for (var doc in subCategoriesQuery.docs) {
        categoryIdsToQuery.add(doc.id);
      }

      for (var i = 0; i < categoryIdsToQuery.length; i += _whereInBatchSize) {
        final chunk = categoryIdsToQuery.sublist(
          i,
          i + _whereInBatchSize > categoryIdsToQuery.length ? categoryIdsToQuery.length : i + _whereInBatchSize,
        );

        final directQuery = await _db
            .collection('Products')
            .where('CategoryId', whereIn: chunk)
            .get();

        for (final doc in directQuery.docs) {
          final model = ProductModel.fromFirebaseJson(doc.data(), doc.id);
          productsById[model.id.isNotEmpty ? model.id : doc.id] = model;
        }

        final linkQuery = await _db
            .collection('ProductCategory')
            .where('categoryId', whereIn: chunk)
            .get();

        final linkedProductIds = linkQuery.docs
            .map((doc) => doc.data()['productId'] as String?)
            .whereType<String>()
            .where((id) => id.isNotEmpty && !productsById.containsKey(id))
            .toSet()
            .toList();

        if (linkedProductIds.isNotEmpty) {
          for (var j = 0; j < linkedProductIds.length; j += _whereInBatchSize) {
            final productChunk = linkedProductIds.sublist(
              j,
              j + _whereInBatchSize > linkedProductIds.length ? linkedProductIds.length : j + _whereInBatchSize,
            );
            final chunkQuery = await _db
                .collection('Products')
                .where(FieldPath.documentId, whereIn: productChunk)
                .get();

            for (final doc in chunkQuery.docs) {
              final model = ProductModel.fromFirebaseJson(doc.data(), doc.id);
              productsById[model.id.isNotEmpty ? model.id : doc.id] = model;
            }
          }
        }
      }

      List<ProductModel> products = productsById.values.toList();

      await LocalStorageService.categoriesProductsRepo.saveData(
        products,
        customKey: 'products_categories_$categoryId',
      );

      if (products.isEmpty) {
        return right(<ProductEntity>[]);
      }

      return right(products.map((e) => e.toEntity()).toList());
    } catch (e) {
      final cachedProducts = LocalStorageService.categoriesProductsRepo.getData(
        customKey: 'products_categories_$categoryId',
      );

      if (cachedProducts != null && cachedProducts.isNotEmpty) {
        return right(cachedProducts.map((e) => e.toEntity()).toList());
      }

      return left(const ServerFailure('Unable to load products for this category right now. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> fetchLimitedProductsForCategory({
    required String categoryId,
  }) async {
    const int limit = 4;
    final bool isConnected = await NetworkManager.instance.isConnected();

    if (!isConnected) {
      final cachedProducts = LocalStorageService.categoriesProductsRepo.getData(
        customKey: 'products_categories_$categoryId',
      );

      if (cachedProducts != null && cachedProducts.isNotEmpty) {
        List<ProductModel> products = cachedProducts;
        if (products.length > limit) {
          products = products.sublist(0, limit);
        }
        return right(products.map((e) => e.toEntity()).toList());
      }
      return left(const NetworkFailure('No internet connection, please check your network.'));
    }

    try {
      final Map<String, ProductModel> productsById = {};

      final subCategoriesQuery = await _db
          .collection('categories')
          .where('parentId', isEqualTo: categoryId)
          .get();

      List<String> categoryIdsToQuery = [categoryId];
      for (var doc in subCategoriesQuery.docs) {
        categoryIdsToQuery.add(doc.id);
      }

      for (var i = 0; i < categoryIdsToQuery.length; i += _whereInBatchSize) {
        if (productsById.length >= limit) break;

        final chunk = categoryIdsToQuery.sublist(
          i,
          i + _whereInBatchSize > categoryIdsToQuery.length ? categoryIdsToQuery.length : i + _whereInBatchSize,
        );

        final directQuery = await _db
            .collection('Products')
            .where('CategoryId', whereIn: chunk)
            .get();

        for (final doc in directQuery.docs) {
          if (productsById.length >= limit) break;
          final model = ProductModel.fromFirebaseJson(doc.data(), doc.id);
          productsById[model.id.isNotEmpty ? model.id : doc.id] = model;
        }

        if (productsById.length >= limit) break;

        final linkQuery = await _db
            .collection('ProductCategory')
            .where('categoryId', whereIn: chunk)
            .get();

        final linkedProductIds = linkQuery.docs
            .map((doc) => doc.data()['productId'] as String?)
            .whereType<String>()
            .where((id) => id.isNotEmpty && !productsById.containsKey(id))
            .toSet()
            .toList();

        if (linkedProductIds.isNotEmpty) {
          for (var j = 0; j < linkedProductIds.length; j += _whereInBatchSize) {
            if (productsById.length >= limit) break;
            final productChunk = linkedProductIds.sublist(
              j,
              j + _whereInBatchSize > linkedProductIds.length ? linkedProductIds.length : j + _whereInBatchSize,
            );
            final chunkQuery = await _db
                .collection('Products')
                .where(FieldPath.documentId, whereIn: productChunk)
                .get();

            for (final doc in chunkQuery.docs) {
              if (productsById.length >= limit) break;
              final model = ProductModel.fromFirebaseJson(doc.data(), doc.id);
              productsById[model.id.isNotEmpty ? model.id : doc.id] = model;
            }
          }
        }
      }

      List<ProductModel> products = productsById.values.toList();

      if (products.length > limit) {
        products = products.sublist(0, limit);
      }

      if (products.isEmpty) {
        return right(<ProductEntity>[]);
      }

      return right(products.map((e) => e.toEntity()).toList());
    } catch (e) {
      final cachedProducts = LocalStorageService.categoriesProductsRepo.getData(
        customKey: 'products_categories_$categoryId',
      );

      if (cachedProducts != null && cachedProducts.isNotEmpty) {
        List<ProductModel> products = cachedProducts;
        if (products.length > limit) {
          products = products.sublist(0, limit);
        }
        return right(products.map((e) => e.toEntity()).toList());
      }

      return left(const ServerFailure('Unable to load products for this category right now. Please try again.'));
    }
  }
}