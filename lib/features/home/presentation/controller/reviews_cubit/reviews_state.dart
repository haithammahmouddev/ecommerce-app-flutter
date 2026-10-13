part of 'reviews_cubit.dart';

enum ReviewsStatus { loading, success, error, actionInProgress }

class ReviewsState extends Equatable {
  final ReviewsStatus status;
  final List<ReviewEntity> reviews;
  final String? errorMessage;

  const ReviewsState({
    this.status = ReviewsStatus.loading,
    this.reviews = const [],
    this.errorMessage,
  });

  ReviewsState copyWith({
    ReviewsStatus? status,
    List<ReviewEntity>? reviews,
    String? errorMessage,
  }) {
    return ReviewsState(
      status: status ?? this.status,
      reviews: reviews ?? this.reviews,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, reviews, errorMessage];
}