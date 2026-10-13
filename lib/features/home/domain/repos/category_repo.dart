import 'package:dartz/dartz.dart';

import '../../../../common/errors/failure.dart';
import '../entities/categories_entity.dart';
import '../entities/product_entity.dart';

abstract class CategoryRepo {
  Future<Either<Failure, List<CategoryEntity>>> fetchAllCategories();
  Future<Either<Failure, List<CategoryEntity>>> getSubCategories({
    required String categoryId,
  });
  Future<Either<Failure, List<ProductEntity>>> fetchProductsForCategory({required String categoryId});
}