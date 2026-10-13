import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fit_store/features/home/domain/entities/categories_entity.dart';
import 'package:fit_store/features/home/domain/entities/product_entity.dart';
import 'package:fit_store/features/home/domain/repos/category_repo.dart';
import '../../../../../common/local_storage/loacal_storage_service.dart';
import '../../../../../utils/helpers/network_manager.dart';

part 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final CategoryRepo categoryRepo;
  CategoriesCubit({required this.categoryRepo}) : super(const CategoriesState()) {
    fetchAllCategories();
  }

  Future<void> fetchAllCategories() async {
    emit(state.copyWith(status: CategoriesStatus.loading));
    final categoriesCached = LocalStorageService.categoriesRepo.getData();
    final bool isConnectedInternet = await NetworkManager.instance.isConnected();
    if (isConnectedInternet) {
      final result = await categoryRepo.fetchAllCategories();

      result.fold(
            (failure) {
          emit(state.copyWith(
            status: CategoriesStatus.error,
            errorMessage: failure.message,
          ));
        },
            (success) {
          emit(state.copyWith(
            status: CategoriesStatus.success,
            categoryEntityList: success,
          ));
        },
      );
    } else {
      if (categoriesCached != null && categoriesCached.isNotEmpty) {
        emit(state.copyWith(
          status: CategoriesStatus.success,
          categoryEntityList: categoriesCached.map((e) => e.toEntity()).toList(),
        ));
      } else {
        emit(state.copyWith(
          status: CategoriesStatus.error,
          errorMessage: "No internet connection, please check your network.",
        ));
      }
    }
  }

  Future<void> getSubcategories({required String categoryId}) async {
    emit(state.copyWith(subCategoriesStatus: SubCategoriesStatus.loading));

    final subCategoriesCached =
    LocalStorageService.subCategoriesRepo.getData(customKey: categoryId);
    final bool isConnectedInternet = await NetworkManager.instance.isConnected();

    if (isConnectedInternet) {
      final result = await categoryRepo.getSubCategories(categoryId: categoryId);

      result.fold(
            (failure) {
          emit(state.copyWith(
            subCategoriesStatus: SubCategoriesStatus.error,
            errorMessage: failure.message,
          ));
        },
            (success) {
          emit(state.copyWith(
            subCategoriesStatus: SubCategoriesStatus.success,
            subCategories: success,
          ));
          for (final sub in success) {
            fetchProductsForSubCategory(subCategoryId: sub.id);
          }
        },
      );
    } else {
      if (subCategoriesCached != null && subCategoriesCached.isNotEmpty) {
        final subCategoriesEntities = subCategoriesCached.map((e) => e.toEntity()).toList();

        emit(state.copyWith(
          subCategoriesStatus: SubCategoriesStatus.success,
          subCategories: subCategoriesEntities,
        ));
        for (final sub in subCategoriesEntities) {
          fetchProductsForSubCategory(subCategoryId: sub.id);
        }
      } else {
        emit(state.copyWith(
          subCategoriesStatus: SubCategoriesStatus.error,
          errorMessage: "No internet connection, please check your network.",
        ));
      }
    }
  }

  Future<void> fetchProductsForSubCategory({required String subCategoryId}) async {

    final currentStatus = state.subProductsCategoryStatusMap[subCategoryId];
    if (currentStatus == SubProductsCategoryStatus.loading ||
        currentStatus == SubProductsCategoryStatus.success) {
      return;
    }

    emit(state.copyWith(
      subProductsCategoryStatusMap: Map<String, SubProductsCategoryStatus>.from(
        state.subProductsCategoryStatusMap,
      )..[subCategoryId] = SubProductsCategoryStatus.loading,
    ));

    final productsCached = LocalStorageService.categoriesProductsRepo
        .getData(customKey: 'category_products_$subCategoryId');
    final bool isConnectedInternet = await NetworkManager.instance.isConnected();

    if (isConnectedInternet) {
      final result = await categoryRepo.fetchProductsForCategory(categoryId: subCategoryId);

      result.fold(
            (error) => print('DEBUG: fetchProductsForCategory FAILED → ${error.message}'),
            (products) => print('DEBUG: fetchProductsForCategory returned ${products.length} product(s) for id=$subCategoryId'),
      );

      result.fold(
            (error) {
          emit(state.copyWith(
            subProductsCategoryStatusMap: Map<String, SubProductsCategoryStatus>.from(
              state.subProductsCategoryStatusMap,
            )..[subCategoryId] = SubProductsCategoryStatus.error,
            errorMessage: error.message,
          ));
        },
            (success) {
          emit(state.copyWith(
            productsBySubCategoryId: Map<String, List<ProductEntity>>.from(
              state.productsBySubCategoryId,
            )..[subCategoryId] = success,
            subProductsCategoryStatusMap: Map<String, SubProductsCategoryStatus>.from(
              state.subProductsCategoryStatusMap,
            )..[subCategoryId] = SubProductsCategoryStatus.success,
          ));
        },
      );
    } else {
      if (productsCached != null && productsCached.isNotEmpty) {
        emit(state.copyWith(
          productsBySubCategoryId: Map<String, List<ProductEntity>>.from(
            state.productsBySubCategoryId,
          )..[subCategoryId] = productsCached.map((e) => e.toEntity()).toList(),
          subProductsCategoryStatusMap: Map<String, SubProductsCategoryStatus>.from(
            state.subProductsCategoryStatusMap,
          )..[subCategoryId] = SubProductsCategoryStatus.success,
        ));
      } else {
        emit(state.copyWith(
          subProductsCategoryStatusMap: Map<String, SubProductsCategoryStatus>.from(
            state.subProductsCategoryStatusMap,
          )..[subCategoryId] = SubProductsCategoryStatus.error,
          errorMessage: "No internet connection, please check your network.",
        ));
      }
    }
  }
}