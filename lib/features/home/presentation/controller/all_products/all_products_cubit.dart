import 'package:bloc/bloc.dart';
import 'package:fit_store/features/home/domain/entities/product_entity.dart';
import 'package:fit_store/features/home/domain/repos/home_repo.dart';
import 'package:fit_store/features/store/domain/repos/store_repo.dart';
import 'package:hive_ce_flutter/adapters.dart';

import '../../../../../common/local_storage/loacal_storage_service.dart';
import '../../../../../utils/helpers/network_manager.dart';
import '../../../data/model/product_model.dart';

part 'all_products_state.dart';

class AllProductsCubit extends Cubit<AllProductsState> {
  final HomeRepo _homeRepo;
  final StoreRepo _storeRepo;

  AllProductsCubit({
    required HomeRepo homeRepo,
    required StoreRepo storeRepo,
  })  : _homeRepo = homeRepo,
        _storeRepo = storeRepo,
        super(AllProductsState());

  static const String _noConnectionMessage = 'No internet connection, please check your network.';

   Future<void> fetchAllProducts() async {

    emit(state.copyWith(status: AllProductsStatus.loading));

    final bool isConnected = await NetworkManager.instance.isConnected();

    if (isConnected) {
      final result = await _homeRepo.fetchAllProducts();

      result.fold(
            (failure) {
          emit(state.copyWith(
            status: AllProductsStatus.error,
            errorMessage: failure.message,
          ));
        },
            (successProducts) {
          emit(state.copyWith(
            status: AllProductsStatus.success,
            products: successProducts,
          ));
        },
      );
    } else {
      emit(state.copyWith(
        status: AllProductsStatus.error,
        errorMessage: _noConnectionMessage,
      ));
    }
   }

   Future<void> fetchProductsByQuery(Map<String, dynamic>? query) async {
    if (query == null || query.isEmpty) {
      emit(state.copyWith(
        status: AllProductsStatus.error,
        errorMessage: 'Invalid query parameters',
      ));
      return;
    }

    emit(state.copyWith(status: AllProductsStatus.loading));

    final bool isConnected = await NetworkManager.instance.isConnected();

    if (isConnected) {
      final result = await _homeRepo.fetchProductsByQuery(query: query);

      result.fold(
            (failure) {
          emit(state.copyWith(
            status: AllProductsStatus.error,
            errorMessage: failure.message,
          ));
        },
            (successProducts) {
          emit(state.copyWith(
            status: AllProductsStatus.success,
            products: successProducts,
          ));
        },
      );
    } else {
      emit(state.copyWith(
        status: AllProductsStatus.error,
        errorMessage: _noConnectionMessage,
      ));
    }
  }

   Future<void> fetchProductsForCategory({
    required String categoryId,
  }) async {

    emit(state.copyWith(status: AllProductsStatus.loading));

    final bool isConnected = await NetworkManager.instance.isConnected();

    if (isConnected) {
      final result = await _storeRepo.fetchProductsForCategory(
        categoryId: categoryId,
      );

      result.fold(
            (failure) {
          _fetchCategoryProductsFromCache(categoryId: categoryId);
        },
            (successProducts) {
          emit(state.copyWith(
            status: AllProductsStatus.success,
            products: successProducts,
          ));
        },
      );
    } else {
       _fetchCategoryProductsFromCache(categoryId: categoryId);
    }
   }

  void _fetchCategoryProductsFromCache({required String categoryId}) {
    final List<ProductModel>? cachedProducts =
    LocalStorageService.categoriesProductsRepo.getData(customKey: 'products_categories_$categoryId');

    if (cachedProducts != null && cachedProducts.isNotEmpty) {
      final List<ProductEntity> productEntities = cachedProducts.map((e) => e.toEntity()).toList();

      emit(state.copyWith(
        status: AllProductsStatus.success,
        products: productEntities,
        errorMessage: null,
      ));
     } else {
       emit(state.copyWith(
        status: AllProductsStatus.error,
        errorMessage: _noConnectionMessage,
      ));
    }
  }

   void sortProducts(String sortOption) {
    final List<ProductEntity> sortedProducts = List<ProductEntity>.from(state.products);

    switch (sortOption) {
      case 'Name':
        sortedProducts.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Higher Price':
        sortedProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Lower Price':
        sortedProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Newest':
        sortedProducts.sort((a, b) => b.id.compareTo(a.id));
        break;
      case 'Sale':
        sortedProducts.sort((a, b) {
          double bSale = b.salePrice ?? 0.0;
          double aSale = a.salePrice ?? 0.0;

          if (bSale > 0) {
            return bSale.compareTo(aSale);
          } else if (aSale > 0) {
            return -1;
          } else {
            return 1;
          }
        });
        break;
      default:
        sortedProducts.sort((a, b) => a.title.compareTo(b.title));
    }

    emit(state.copyWith(
      status: AllProductsStatus.success,
      products: sortedProducts,
      selectedSortOption: sortOption,
    ));
  }

   void assignProducts(List<ProductEntity> products) {
    emit(state.copyWith(
      status: AllProductsStatus.success,
      products: products,
    ));
    sortProducts('Name');
  }
}