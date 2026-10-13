import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:fit_store/common/errors/failure.dart';
import 'package:fit_store/features/home/domain/entities/banners_entity.dart';
import 'package:fit_store/features/home/domain/entities/categories_entity.dart';
import 'package:fit_store/features/home/domain/entities/product_entity.dart';
import 'package:fit_store/features/home/domain/repos/home_repo.dart';
import '../../../../../common/local_storage/loacal_storage_service.dart';
import '../../../../../utils/helpers/network_manager.dart';
import '../../../data/model/banners_model.dart';

part 'promo_slider_state.dart';

class PromoSliderCubit extends Cubit<PromoSliderState> {
  final HomeRepo _homeRepo;

  PromoSliderCubit({required HomeRepo homeRepo})
      : _homeRepo = homeRepo,
        super(const PromoSliderState());

  void onPageChanged(int index) {
    emit(state.copyWith(currentIndex: index));
  }

  Future<void> fetchBanners() async {
    emit(state.copyWith(
      status: PromoSliderEnum.loading,
      currentIndex: 0,
      clearError: true,
    ));

    final List<BannerModel>? cachedBanners =
    LocalStorageService.bannersRepo.getData();
    final bool isConnected = await NetworkManager.instance.isConnected();

    if (isConnected) {
      final result = await _homeRepo.fetchBanners();
      result.fold(
            (failure) => emit(state.copyWith(
          status: PromoSliderEnum.error,
          errorMessage: failure.message,
        )),
            (banners) => emit(state.copyWith(
          status: PromoSliderEnum.loaded,
          bannerEntityList: banners,
          clearError: true,
        )),
      );
    } else if (cachedBanners != null && cachedBanners.isNotEmpty) {
      final active = cachedBanners.where((e) => e.isActive).toList();
      if (active.isEmpty) {
        emit(state.copyWith(
          status: PromoSliderEnum.error,
          errorMessage: 'No banners available',
        ));
        return;
      }
      emit(state.copyWith(
        status: PromoSliderEnum.loaded,
        bannerEntityList: active.map((e) => e.toEntity()).toList(),
        clearError: true,
      ));
    } else {
      emit(state.copyWith(
        status: PromoSliderEnum.error,
        errorMessage: 'No internet connection, please check your network.',
      ));
    }
  }

  Future<Either<Failure, ProductEntity>> getProductById(String id) =>
      _homeRepo.getProductById(id);

  Future<Either<Failure, CategoryEntity>> getCategoryById(String id) =>
      _homeRepo.getCategoryById(id);
}