import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:fit_store/features/home/domain/entities/banners_entity.dart';
import 'package:fit_store/features/home/domain/entities/product_entity.dart';
import 'package:fit_store/features/home/domain/repos/home_repo.dart';
import 'package:fit_store/features/home/data/model/product_model.dart';
import '../../../../common/errors/failure.dart';
import '../../../../common/network/firebase/database_services.dart';
import '../../../../common/local_storage/loacal_storage_service.dart';
import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/search/search_utils.dart';
import '../../domain/entities/categories_entity.dart';
import '../model/category_model.dart';
import '../model/banners_model.dart';

class HomeRepoImple implements HomeRepo {
  final DatabaseServices _databaseServices;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  HomeRepoImple({required this._databaseServices});

  @override
  Future<Either<Failure, List<BannerEntity>>> fetchBanners() async {
    try {
      final List<Map<String, dynamic>> banners =
      await _databaseServices.getData(path: 'Banners');
      final List<BannerModel> bannerModelList = banners
          .map((banner) => BannerModel.fromFirebaseJson(banner))
          .toList();
      await LocalStorageService.bannersRepo.saveData(bannerModelList);
      final bannerEntities = bannerModelList
          .where((b) => b.isActive)
          .map((e) => e.toEntity())
          .toList();
      return right(bannerEntities);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(String id) async {
    final productId = id.trim();
    if (productId.isEmpty) {
      return left(const ServerFailure('Invalid product id.'));
    }

    try {
      final List<ProductModel> cached = [
        ...(LocalStorageService.productsRepo.getData() ?? <ProductModel>[]),
        ...(LocalStorageService.featuredProductsRepo.getData() ??
            <ProductModel>[]),
      ];
      for (final p in cached) {
        if (p.id == productId) return right(p.toEntity());
      }

      if (!await NetworkManager.instance.isConnected()) {
        return left(const NetworkFailure(
            'لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة.'));
      }

      final doc = await _db.collection('Products').doc(productId).get();
      final data = doc.data();
      if (!doc.exists || data == null) {
        return left(const ServerFailure('Product not found.'));
      }

      return right(ProductModel.fromFirebaseJson(data, doc.id).toEntity());
    } on FirebaseException catch (e) {
      return left(
          ServerFailure(e.message ?? 'حدث خطأ أثناء جلب البيانات من الخادم.'));
    } catch (e) {
      return left(const ServerFailure('Something went wrong. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> getCategoryById(String id) async {
    final categoryId = id.trim();
    if (categoryId.isEmpty) {
      return left(const ServerFailure('Invalid category id.'));
    }

    try {
      final List<CategoryModel>? cachedCategories =
      LocalStorageService.categoriesRepo.getData();
      if (cachedCategories != null && cachedCategories.isNotEmpty) {
        for (final cat in cachedCategories) {
          if (cat.id == categoryId) {
            return right(cat.toEntity());
          }
        }
      }

      if (!await NetworkManager.instance.isConnected()) {
        return left(const NetworkFailure(
            'لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة.'));
      }

      final doc = await _db.collection('categories').doc(categoryId).get();
      final data = doc.data();
      if (!doc.exists || data == null) {
        return left(const ServerFailure('Category not found.'));
      }

      return right(CategoryModel.fromFirebaseJson(data, doc.id).toEntity());
    } on FirebaseException catch (e) {
      return left(
          ServerFailure(e.message ?? 'حدث خطأ أثناء جلب البيانات من الخادم.'));
    } catch (e) {
      return left(const ServerFailure('Something went wrong. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> fetchFeaturedProducts() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _db
          .collection('Products')
          .where('IsFeatured', isEqualTo: true)
          .limit(4)
          .get();

      final List<ProductModel> featuredProducts = snapshot.docs
          .map((doc) => ProductModel.fromFirebaseJson(doc.data(), doc.id))
          .toList();
      final List<ProductEntity> featuredProductsEntity =
      featuredProducts.map((e) => e.toEntity()).toList();
      await LocalStorageService.featuredProductsRepo.saveData(featuredProducts);
      return right(featuredProductsEntity);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> fetchAllProducts() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
      await _db.collection('Products').get();

      final List<ProductModel> allProducts = snapshot.docs
          .map((doc) => ProductModel.fromFirebaseJson(doc.data(), doc.id))
          .toList();
      final List<ProductEntity> allProductsEntity =
      allProducts.map((e) => e.toEntity()).toList();
      await LocalStorageService.productsRepo.saveData(allProducts);
      return right(allProductsEntity);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> fetchProductsByQuery({
    required Map<String, dynamic> query,
  }) async {
    final bool isConnected = await NetworkManager.instance.isConnected();

    if (!isConnected) {
      return left(const NetworkFailure(
          'لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة.'));
    }

    try {
      Query<Map<String, dynamic>> queryRef = _db.collection('Products');

      query.forEach((key, value) {
        if (value != null) {
          if (value is List) {
            if (value.isNotEmpty) {
              queryRef = queryRef.where(key, whereIn: value);
            }
          } else {
            queryRef = queryRef.where(key, isEqualTo: value);
          }
        }
      });

      final QuerySnapshot<Map<String, dynamic>> snapshot = await queryRef.get();

      final List<ProductModel> productModels = snapshot.docs.map((doc) {
        return ProductModel.fromFirebaseJson(doc.data(), doc.id);
      }).toList();

      final List<ProductEntity> productEntities =
      productModels.map((e) => e.toEntity()).toList();

      return right(productEntities);
    } on FirebaseException catch (e) {
      return left(
          ServerFailure(e.message ?? 'حدث خطأ أثناء جلب البيانات من الخادم.'));
    } catch (e) {
      return left(const ServerFailure('Something went wrong. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsForBrand({
    required String brandId,
    int limit = -1,
  }) async {
    if (!await NetworkManager.instance.isConnected()) {
      return left(const NetworkFailure(
          'لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة.'));
    }

    try {
      Query query = FirebaseFirestore.instance
          .collection('Products')
          .where('Brand.Id', isEqualTo: brandId);

      if (limit != -1) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      final List<ProductEntity> products = querySnapshot.docs
          .map((doc) => ProductModel.fromFirebaseJson(
          doc.data() as Map<String, dynamic>, doc.id))
          .map((e) => e.toEntity())
          .toList();

      return right(products);
    } on FirebaseException catch (e) {
      return left(
          ServerFailure(e.message ?? 'حدث خطأ أثناء جلب البيانات من الخادم.'));
    } catch (e) {
      return left(const ServerFailure('Something went wrong. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getFavouriteProducts({
    required List<String> productIds,
  }) async {
    final validIds =
    productIds.where((id) => id.trim().isNotEmpty).toSet().toList();
    if (validIds.isEmpty) return right([]);

    try {
      late final List<ProductModel> allCachedProducts;
      final List<ProductModel> cachedAllProducts =
          LocalStorageService.productsRepo.getData() ?? [];
      final List<ProductModel> cachedFeaturedProducts =
          LocalStorageService.featuredProductsRepo.getData() ?? [];

      if (cachedAllProducts.isNotEmpty) {
        allCachedProducts = cachedAllProducts;
      } else if (cachedFeaturedProducts.isNotEmpty) {
        allCachedProducts = cachedFeaturedProducts;
      } else {
        return const Right([]);
      }

      final idsSet = validIds.toSet();
      final List<ProductModel> favoriteProductModels = allCachedProducts
          .where((product) => idsSet.contains(product.id))
          .toList();

      await LocalStorageService.favoritesRepo.saveData(favoriteProductModels);

      final List<ProductEntity> favoriteProducts =
      favoriteProductModels.map((e) => e.toEntity()).toList();

      return right(favoriteProducts);
    } catch (e) {
      return left(const ServerFailure('Something went wrong. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> searchProducts({
    required String query,
  }) async {
    final q = query.trim();
    if (q.isEmpty) return right([]);

    try {
      List<ProductModel> candidates =
          LocalStorageService.productsRepo.getData() ?? [];

      if (candidates.isEmpty) {
        if (!await NetworkManager.instance.isConnected()) {
          return left(const NetworkFailure(
              'لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة.'));
        }
        final List<Map<String, dynamic>> raw =
        await _databaseServices.getData(path: 'Products');
        candidates = raw
            .map((m) => ProductModel.fromFirebaseJson(m, m['id'] as String))
            .toList();
        await LocalStorageService.productsRepo.saveData(candidates);
      }

      final entities = candidates.map((e) => e.toEntity()).toList();

      final docs = entities
          .map((p) => SearchDoc.build(
        p,
        title: p.title,
        brand: p.brand?.name ?? '',
      ))
          .toList();

      final results = SearchUtils.searchIndex(docs, q);

      return right(results);
    } on FirebaseException catch (e) {
      return left(
          ServerFailure(e.message ?? 'حدث خطأ أثناء جلب البيانات من الخادم.'));
    } catch (e) {
      return left(const ServerFailure('Something went wrong. Please try again.'));
    }
  }
}