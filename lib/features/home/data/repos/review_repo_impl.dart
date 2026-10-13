import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:fit_store/features/home/domain/repos/review_repo.dart';
import '../../../../common/errors/failure.dart';
import '../../../../common/local_storage/loacal_storage_service.dart';
import '../../../../utils/helpers/network_manager.dart';
import '../../domain/entities/reviews_entity.dart';
import '../model/reviews_model.dart';

class ReviewsRepoImpl implements ReviewsRepo {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<Either<Failure, List<ReviewEntity>>> getReviewsForProduct(
    String productId,
  ) async {
    final String cacheKey = 'reviews_$productId';

    try {
      final bool isConnected = await NetworkManager.instance.isConnected();

      if (!isConnected) {
        final List<ReviewModel>? cachedReviews = LocalStorageService.reviewsRepo
            .getData(customKey: cacheKey);

        if (cachedReviews != null && cachedReviews.isNotEmpty) {
          return right(cachedReviews.map((e) => e.toEntity()).toList());
        }
        return left(
          const NetworkFailure(
            'لا يوجد اتصال بالإنترنت ولا توجد تقييمات مخزنة محلياً.',
          ),
        );
      }

      final QuerySnapshot<Map<String, dynamic>> snapshot = await _db
          .collection('Products')
          .doc(productId)
          .collection('Reviews')
          .orderBy('createdAt', descending: true)
          .get();

      final List<ReviewModel> reviewModels = snapshot.docs
          .map((doc) => ReviewModel.fromFirebaseJson(doc.data(), doc.id))
          .toList();

      await LocalStorageService.reviewsRepo.saveData(
        reviewModels,
        customKey: cacheKey,
      );

      return right(reviewModels.map((e) => e.toEntity()).toList());
    } on FirebaseException catch (e) {
      final List<ReviewModel>? cachedReviews = LocalStorageService.reviewsRepo
          .getData(customKey: cacheKey);
      if (cachedReviews != null && cachedReviews.isNotEmpty) {
        return right(cachedReviews.map((e) => e.toEntity()).toList());
      }
      return left(ServerFailure(e.message ?? 'حدث خطأ أثناء جلب التقييمات.'));
    } catch (e) {
      return left(
        const ServerFailure('Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> addReview(ReviewEntity review) async {
    if (!await NetworkManager.instance.isConnected()) {
      return left(
        const NetworkFailure('لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة.'),
      );
    }

    try {
      final reviewModel = ReviewModel.fromEntity(review);

      await _db
          .collection('Products')
          .doc(review.productId)
          .collection('Reviews')
          .add({
            ...reviewModel.toJson(),
            'createdAt': FieldValue.serverTimestamp(),
          });
      await _updateProductRating(review.productId);
      await LocalStorageService.reviewsRepo.clearData(
        customKey: 'reviews_${review.productId}',
      );

      return right(null);
    } on FirebaseException catch (e) {
      return left(ServerFailure(e.message ?? 'حدث خطأ أثناء إضافة التقييم.'));
    } catch (e) {
      return left(
        const ServerFailure('Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateReview(ReviewEntity review) async {
    if (!await NetworkManager.instance.isConnected()) {
      return left(
        const NetworkFailure('لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة.'),
      );
    }

    try {
      await _db
          .collection('Products')
          .doc(review.productId)
          .collection('Reviews')
          .doc(review.id)
          .update({'comment': review.comment, 'rating': review.rating});

      await _updateProductRating(review.productId);
      await LocalStorageService.reviewsRepo.clearData(
        customKey: 'reviews_${review.productId}',
      );

      return right(null);
    } on FirebaseException catch (e) {
      return left(ServerFailure(e.message ?? 'حدث خطأ أثناء تعديل التقييم.'));
    } catch (e) {
      return left(
        const ServerFailure('Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteReview({
    required String reviewId,
    required String productId,
  }) async {
    if (!await NetworkManager.instance.isConnected()) {
      return left(
        const NetworkFailure('لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة.'),
      );
    }

    try {
      await _db
          .collection('Products')
          .doc(productId)
          .collection('Reviews')
          .doc(reviewId)
          .delete();

      await _updateProductRating(productId);
      await LocalStorageService.reviewsRepo.clearData(
        customKey: 'reviews_$productId',
      );

      return right(null);
    } on FirebaseException catch (e) {
      return left(ServerFailure(e.message ?? 'حدث خطأ أثناء حذف التقييم.'));
    } catch (e) {
      return left(
        const ServerFailure('Something went wrong. Please try again.'),
      );
    }
  }

  Future<void> _updateProductRating(String productId) async {
    final querySnapshot = await _db
        .collection('Products')
        .doc(productId)
        .collection('Reviews')
        .get();

    final docs = querySnapshot.docs;
    if (docs.isEmpty) {
      await _db.collection('Products').doc(productId).update({
        'Rating': 0.0,
        'ReviewCount': 0,
      });
      return;
    }

    double totalRating = 0.0;
    for (var doc in docs) {
      totalRating += (doc.data()['rating'] as num?)?.toDouble() ?? 0.0;
    }
    double averageRating = totalRating / docs.length;
    averageRating = double.parse(averageRating.toStringAsFixed(1));
    await _db.collection('Products').doc(productId).update({
      'Rating': averageRating,
      'ReviewCount': docs.length,
    });
  }
}
