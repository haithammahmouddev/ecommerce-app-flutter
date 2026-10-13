import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fit_store/common/local_storage/loacal_storage_service.dart';
import 'package:fit_store/features/store/domain/entities/brand_entity.dart';
import 'package:fit_store/features/store/domain/repos/store_repo.dart';
import '../../../../../utils/helpers/network_manager.dart';
import '../../../../home/domain/entities/product_entity.dart';
import '../../../data/models/brand_model.dart';
import '../../../../home/data/model/product_model.dart';

part 'brand_state.dart';

class BrandCubit extends Cubit<BrandState> {
  final StoreRepo _storeRepo;
  BrandCubit({required this._storeRepo}) : super(const BrandState()) {
    fetchFeaturedBrands();
  }

  static const String _noConnectionMessage = 'No internet connection, please check your network.';

  Future<void> fetchFeaturedBrands() async {
    print('>>> BrandCubit: fetchFeaturedBrands called');
    if (state.featuredBrands.isNotEmpty && state.featuredStatus == FeaturedBrandsStatus.success) {
      return;
    }

    emit(state.copyWith(featuredStatus: FeaturedBrandsStatus.loading));
    final bool isConnected = await NetworkManager.instance.isConnected();

    if (isConnected) {
      final result = await _storeRepo.fetchFeaturedBrands();
      result.fold(
            (failure) => emit(state.copyWith(
          featuredStatus: FeaturedBrandsStatus.error,
          errorMessage: failure.message,
        )),
            (successBrands) => emit(state.copyWith(
          featuredStatus: FeaturedBrandsStatus.success,
          featuredBrands: successBrands,
          errorMessage: null,
        )),
      );
      return;
    }

    final List<BrandModel>? featuredBrandsCache =
    LocalStorageService.brandsRepo.getData(customKey: 'featured_brands');

    if (featuredBrandsCache != null && featuredBrandsCache.isNotEmpty) {
      emit(state.copyWith(
        featuredStatus: FeaturedBrandsStatus.success,
        featuredBrands: featuredBrandsCache.map((e) => e.toEntity()).toList(),
        errorMessage: null,
      ));
    } else {
      emit(state.copyWith(
        featuredStatus: FeaturedBrandsStatus.error,
        errorMessage: _noConnectionMessage,
      ));
    }
  }

  Future<void> fetchAllBrands() async {
    if (state.allBrands.isNotEmpty && state.allBrandsStatus == AllBrandsStatus.success) return;

    emit(state.copyWith(allBrandsStatus: AllBrandsStatus.loading));
    final bool isConnected = await NetworkManager.instance.isConnected();

    if (isConnected) {
      final result = await _storeRepo.fetchAllBrands();
      result.fold(
            (failure) => emit(state.copyWith(
          allBrandsStatus: AllBrandsStatus.error,
          errorMessage: failure.message,
        )),
            (successBrands) => emit(state.copyWith(
          allBrandsStatus: AllBrandsStatus.success,
          allBrands: successBrands,
          errorMessage: null,
        )),
      );
      return;
    }

    final List<BrandModel>? allBrandsCache = LocalStorageService.brandsRepo.getData(customKey: 'all_brands');
    if (allBrandsCache != null && allBrandsCache.isNotEmpty) {
      emit(state.copyWith(
        allBrandsStatus: AllBrandsStatus.success,
        allBrands: allBrandsCache.map((e) => e.toEntity()).toList(),
        errorMessage: null,
      ));
    } else {
      emit(state.copyWith(
        allBrandsStatus: AllBrandsStatus.error,
        errorMessage: _noConnectionMessage,
      ));
    }
  }

  Future<void> fetchBrandProducts({required String brandId}) async {
    emit(state.copyWith(brandProductsStatus: BrandProductsStatus.loading));
    final bool isConnected = await NetworkManager.instance.isConnected();

    if (isConnected) {
      final result = await _storeRepo.fetchProductsForBrand(brandId: brandId);
      result.fold(
            (failure) => emit(state.copyWith(
          brandProductsStatus: BrandProductsStatus.error,
          errorMessage: failure.message,
        )),
            (successProducts) => emit(state.copyWith(
          brandProductsStatus: BrandProductsStatus.success,
          brandProducts: successProducts,
          errorMessage: null,
        )),
      );
      return;
    }

    final List<ProductModel>? cachedProducts =
    LocalStorageService.productsRepo.getData(customKey: 'brand_product_$brandId');

    if (cachedProducts != null && cachedProducts.isNotEmpty) {
      emit(state.copyWith(
        brandProductsStatus: BrandProductsStatus.success,
        brandProducts: cachedProducts.map((e) => e.toEntity()).toList(),
        errorMessage: null,
      ));
    } else {
      emit(state.copyWith(
        brandProductsStatus: BrandProductsStatus.error,
        errorMessage: _noConnectionMessage,
      ));
    }
  }

  Future<void> fetchBrandsForCategory({required String categoryId}) async {
    if (state.categoryBrandsMap.containsKey(categoryId)) return;

    emit(state.copyWith(categoryBrandsStatus: CategoryBrandsStatus.loading));
    final bool isConnected = await NetworkManager.instance.isConnected();

    if (isConnected) {
      final result = await _storeRepo.fetchBrandsForCategory(categoryId: categoryId);
      result.fold(
            (failure) => emit(state.copyWith(
          categoryBrandsStatus: CategoryBrandsStatus.error,
          errorMessage: failure.message,
        )),
            (successBrands) => emit(state.copyWith(
          categoryBrandsStatus: CategoryBrandsStatus.success,
          categoryBrandsMap: {
            ...state.categoryBrandsMap,
            categoryId: successBrands,
          },
          errorMessage: null,
        )),
      );
      return;
    }

    final List<BrandModel>? cachedBrands =
    LocalStorageService.brandsRepo.getData(customKey: 'category_brands_$categoryId');

    if (cachedBrands != null && cachedBrands.isNotEmpty) {
      emit(state.copyWith(
        categoryBrandsStatus: CategoryBrandsStatus.success,
        categoryBrandsMap: {
          ...state.categoryBrandsMap,
          categoryId: cachedBrands.map((e) => e.toEntity()).toList(),
        },
        errorMessage: null,
      ));
    } else {
      emit(state.copyWith(
        categoryBrandsStatus: CategoryBrandsStatus.error,
        errorMessage: _noConnectionMessage,
      ));
    }
  }

  Future<void> fetchProductsForCategoryBrand({required String brandId}) async {
    if (state.categoryBrandProducts.containsKey(brandId)) return;

    final bool isConnected = await NetworkManager.instance.isConnected();
    if (isConnected) {
      final result = await _storeRepo.fetchProductsForBrand(brandId: brandId);
      result.fold((l) {}, (successProducts) {
        emit(state.copyWith(
          categoryBrandProducts: {
            ...state.categoryBrandProducts,
            brandId: successProducts,
          },
        ));
      });
      if (state.categoryBrandProducts.containsKey(brandId)) return;
    }

    final List<ProductModel>? cachedProducts =
    LocalStorageService.productsRepo.getData(customKey: 'brand_product_$brandId');

    if (cachedProducts != null && cachedProducts.isNotEmpty) {
      emit(state.copyWith(
        categoryBrandProducts: {
          ...state.categoryBrandProducts,
          brandId: cachedProducts.map((e) => e.toEntity()).toList(),
        },
      ));
    }
  }

  Future<void> fetchLimitedProductsForCategory({required String categoryId}) async {
     if (state.categoryProductsMap.containsKey(categoryId)) return;

    final result = await _storeRepo.fetchLimitedProductsForCategory(categoryId: categoryId);
    result.fold(
          (failure) {
       },
          (successProducts) {
         emit(state.copyWith(
          categoryProductsMap: {
            ...state.categoryProductsMap,
            categoryId: successProducts,
          },
        ));
      },
    );
  }

   Future<void> fetchProductsForCategory({required String categoryId}) async {
     if (state.categoryProductsMap.containsKey(categoryId)) return;

    final result = await _storeRepo.fetchProductsForCategory(categoryId: categoryId);
    result.fold(
          (failure) {
       },
          (successProducts) {
         emit(state.copyWith(
          categoryProductsMap: {
            ...state.categoryProductsMap,
            categoryId: successProducts,
          },
        ));
      },
    );
  }
}