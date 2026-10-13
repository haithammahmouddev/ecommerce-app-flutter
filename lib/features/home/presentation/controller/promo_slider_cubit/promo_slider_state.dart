part of 'promo_slider_cubit.dart';

enum PromoSliderEnum { loading, loaded, error }

class PromoSliderState extends Equatable {
  final PromoSliderEnum status;
  final List<BannerEntity> bannerEntityList;
  final int currentIndex;
  final String? errorMessage;

  const PromoSliderState({
    this.status = PromoSliderEnum.loading,
    this.bannerEntityList = const [],
    this.currentIndex = 0,
    this.errorMessage,
  });

  PromoSliderState copyWith({
    PromoSliderEnum? status,
    List<BannerEntity>? bannerEntityList,
    int? currentIndex,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PromoSliderState(
      status: status ?? this.status,
      bannerEntityList: bannerEntityList ?? this.bannerEntityList,
      currentIndex: currentIndex ?? this.currentIndex,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [status, bannerEntityList, currentIndex, errorMessage];
}