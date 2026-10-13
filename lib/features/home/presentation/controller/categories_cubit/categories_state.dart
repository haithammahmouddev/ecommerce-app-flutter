part of 'categories_cubit.dart';

enum CategoriesStatus { loading, success, error }

enum SubCategoriesStatus { loading, success, error }

enum SubProductsCategoryStatus { loading, success, error }

class CategoriesState extends Equatable {
  final CategoriesStatus status;
  final List<CategoryEntity> categoryEntityList;
  final List<CategoryEntity> subCategories;
  final SubCategoriesStatus subCategoriesStatus;

  final Map<String, List<ProductEntity>> productsBySubCategoryId;

  final Map<String, SubProductsCategoryStatus> subProductsCategoryStatusMap;

  final String? errorMessage;

  const CategoriesState({
    this.status = CategoriesStatus.loading,
    this.categoryEntityList = const [],
    this.subCategories = const [],
    this.subCategoriesStatus = SubCategoriesStatus.loading,
    this.productsBySubCategoryId = const {},
    this.subProductsCategoryStatusMap = const {},
    this.errorMessage,
  });

  List<ProductEntity> productsFor(String subCategoryId) =>
      productsBySubCategoryId[subCategoryId] ?? const [];

  SubProductsCategoryStatus statusFor(String subCategoryId) =>
      subProductsCategoryStatusMap[subCategoryId] ?? SubProductsCategoryStatus.loading;

  CategoriesState copyWith({
    CategoriesStatus? status,
    List<CategoryEntity>? categoryEntityList,
    List<CategoryEntity>? subCategories,
    SubCategoriesStatus? subCategoriesStatus,
    Map<String, List<ProductEntity>>? productsBySubCategoryId,
    Map<String, SubProductsCategoryStatus>? subProductsCategoryStatusMap,
    String? errorMessage,
  }) {
    return CategoriesState(
      status: status ?? this.status,
      categoryEntityList: categoryEntityList ?? this.categoryEntityList,
      subCategories: subCategories ?? this.subCategories,
      subCategoriesStatus: subCategoriesStatus ?? this.subCategoriesStatus,
      productsBySubCategoryId: productsBySubCategoryId ?? this.productsBySubCategoryId,
      subProductsCategoryStatusMap:
      subProductsCategoryStatusMap ?? this.subProductsCategoryStatusMap,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    categoryEntityList,
    subCategories,
    subCategoriesStatus,
    productsBySubCategoryId,
    subProductsCategoryStatusMap,
    errorMessage,
  ];
}