import 'package:dartz/dartz.dart';
import '../../../../common/errors/failure.dart';
import '../entities/reviews_entity.dart';

abstract class ReviewsRepo {
  Future<Either<Failure, List<ReviewEntity>>> getReviewsForProduct(String productId);
  Future<Either<Failure, void>> addReview(ReviewEntity review);
  Future<Either<Failure, void>> updateReview(ReviewEntity review);
  Future<Either<Failure, void>> deleteReview({required String reviewId, required String productId});
}