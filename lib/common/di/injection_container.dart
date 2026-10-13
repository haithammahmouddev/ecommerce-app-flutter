import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fit_store/features/auth/data/data_source/email_auth-datasource_imple.dart';
import 'package:fit_store/features/auth/data/data_source/email_auth_datasource.dart';
import 'package:fit_store/features/auth/data/data_source/reset_password_datasource.dart';
import 'package:fit_store/features/auth/data/data_source/session_datasource.dart';
import 'package:fit_store/features/auth/data/data_source/social_auth_datasource.dart';
import 'package:fit_store/features/auth/data/data_source/social_auth_datasource_imple.dart';
import 'package:fit_store/features/auth/data/data_source/verify_email_datasource.dart';
import 'package:fit_store/features/auth/data/data_source/verify_email_datasource_imple.dart';
import 'package:fit_store/features/auth/data/repos/email_auth-repo_imple.dart';
import 'package:fit_store/features/auth/data/repos/session_repo_imple.dart';
import 'package:fit_store/features/auth/domain/repos/reset_password_repo.dart';
import 'package:fit_store/features/auth/domain/repos/social_auth_repo.dart';
import 'package:fit_store/features/auth/presentation/bloc/email_auth_bloc/email_auth_bloc.dart';
import 'package:fit_store/features/auth/presentation/cubit/reset_password_cubit/reset_password_cubit.dart';
import 'package:fit_store/features/auth/presentation/cubit/session_cubit/session_cubit.dart';
import 'package:fit_store/features/auth/presentation/cubit/social_auth-bloc/social_auth_cubit.dart';
import 'package:fit_store/features/auth/presentation/cubit/verify_email_cubit/verify_email_cubit.dart';
import '../../features/auth/data/data_source/reset_password_datasource_imple.dart';
import '../../features/auth/data/data_source/session_datasource_imple.dart';
import '../../features/auth/data/repos/reset_password_repo_imple.dart';
import '../../features/auth/data/repos/social_auth_repo_imple.dart';
import '../../features/auth/data/repos/verify_email_repo_imple.dart';
import '../../features/auth/domain/repos/email_auth_repo.dart';
import '../../features/auth/domain/repos/session_repo.dart';
import '../../features/auth/domain/repos/verify_email_repo.dart';
import 'package:fit_store/features/home/domain/repos/category_repo.dart';
import 'package:fit_store/features/home/domain/repos/home_repo.dart';
import 'package:fit_store/features/home/presentation/controller/categories_cubit/categories_cubit.dart';
import 'package:fit_store/features/home/presentation/controller/products_cubit/images_cubit.dart';
import 'package:fit_store/features/home/presentation/controller/products_cubit/products_cubit.dart';
import 'package:fit_store/features/home/presentation/controller/products_cubit/variation_cubit.dart';
import 'package:fit_store/features/home/presentation/controller/promo_slider_cubit/promo_slider_cubit.dart';
import 'package:fit_store/features/store/domain/repos/store_repo.dart';
import 'package:fit_store/features/store/presentation/controller/brand_cubit/brand_cubit.dart';
import '../../features/cart/presentation/controllers/cart/cart_cubit.dart';
import '../../features/checkout/presentation/controllers/checkout/checkout_cubit.dart';
import '../../features/favourites/presentation/controllers/favorites_cubit/favorites_cubit.dart';
import '../../features/home/data/repos/category_repo_impl.dart';
import '../../features/home/data/repos/home_repo_imple.dart';
import '../../features/home/domain/repos/review_repo.dart';
import '../../features/home/data/repos/review_repo_impl.dart';
import '../../features/home/presentation/controller/all_products/all_products_cubit.dart';
import '../../features/home/presentation/controller/reviews_cubit/reviews_cubit.dart';
import '../../features/home/presentation/controller/search/search_cubit.dart';
import '../../features/home/presentation/screens/search/service/recent_search_store.dart';
import '../../features/settings/presentation/controllers/order/order_cubit.dart';
import '../../features/store/data/repos/store_repo_imple.dart';
import 'package:fit_store/features/settings/data/repos/address_repo_impl.dart';
import 'package:fit_store/features/settings/domain/repos/address_repo.dart';
import 'package:fit_store/features/settings/presentation/controllers/address/address_cubit.dart';
import '../../features/settings/data/repos/user_repo_impl.dart';
import '../../features/settings/domain/repos/user_repo.dart';
import '../../features/settings/presentation/controllers/user_cubit/user_cubit.dart';
import '../../features/settings/domain/repos/order_repo.dart';
import '../../features/settings/data/repos/order_repo_impl.dart';
import '../network/firebase/auth_client.dart';
import '../network/firebase/auth_client_imple.dart';
import '../network/firebase/cloud_firestore.dart';
import '../network/firebase/database_services.dart';
import '../network/firebase/storage_service.dart';
import '../network/firebase/supabase_storage.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<AuthClient>(
        () => AuthClientImpl(FirebaseAuth.instance),
  );
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  sl.registerLazySingleton<SupabaseStorageClient>(
        () => Supabase.instance.client.storage,
  );
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);
  sl.registerLazySingleton<FacebookAuth>(() => FacebookAuth.instance);
  sl.registerLazySingleton<DatabaseServices>(
        () => CloudFirestore(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<StorageService>(() => SupabaseStorageService(sl()));


  sl.registerLazySingleton<EmailAuthDatasource>(
        () => EmailAuthdatasourceImple(authClient: sl()),
  );
  sl.registerLazySingleton<VerifyEmailDatasource>(
        () => VerifyEmailDatasourceImple(authClient: sl()),
  );
  sl.registerLazySingleton<SessionDataSource>(
        () => SessionDatasourceImple(authClient: sl()),
  );
  sl.registerLazySingleton<SocialAuthDatasource>(
        () => SocialAuthDataSourceImpl(
      authClient: sl(),
      googleSignIn: sl(),
    ),
  );
  sl.registerLazySingleton<ResetPasswordDatasource>(
        () => ResetPasswordDatasourceImple(authClient: sl()),
  );


  sl.registerLazySingleton<CategoryRepo>(() => CategoryRepoImpl());
  sl.registerLazySingleton<EmailAuthRepo>(
        () => EmailAuthRepoImple(
      emailAuthDatasource: sl(),
      databaseServices: sl(),
      authClient: sl(),
    ),
  );
  sl.registerLazySingleton<HomeRepo>(
        () => HomeRepoImple(databaseServices: sl()),
  );
  sl.registerLazySingleton<OrderRepository>(() => OrderRepositoryImpl());
  sl.registerLazySingleton<UserRepo>(
        () => UserRepoImpl(databaseServices: sl(), authClient: sl(), storageService: sl()),
  );
  sl.registerLazySingleton<VerifyEmailRepo>(
        () => VerifyEmailRepoImple(verifyEmailDatasource: sl()),
  );
  sl.registerLazySingleton<SessionRepo>(
        () => SessionRepositoryImpl(sessionDataSource: sl()),
  );
  sl.registerLazySingleton<SocialAuthRepo>(
        () => SocialAuthRepoImple(databaseServices: sl(), socialAuthDatasource: sl()),
  );
  sl.registerLazySingleton<ResetPasswordRepo>(
        () => ResetPasswordRepoImple(resetPasswordDatasource: sl()),
  );
  sl.registerLazySingleton<StoreRepo>(() => StoreRepoImple());
  sl.registerLazySingleton<AddressRepo>(() => AddressRepoImpl());


  sl.registerFactory<EmailAuthBloc>(
        () => EmailAuthBloc(emailAuthRepo: sl<EmailAuthRepo>()),
  );
  sl.registerFactory<VerifyEmailCubit>(
        () => VerifyEmailCubit(verifyEmailRepo: sl(), databaseServices: sl()),
  );
  sl.registerFactory<SessionCubit>(() => SessionCubit(sessionRepository: sl()));
  sl.registerFactory<SocialAuthCubit>(
        () => SocialAuthCubit(socialAuthRepo: sl()),
  );
  sl.registerFactory<ResetPasswordCubit>(
        () => ResetPasswordCubit(resetPasswordRepo: sl()),
  );
  sl.registerFactory<UserCubit>(() => UserCubit(userRepoImpl: sl()));

  sl.registerLazySingleton<CategoriesCubit>(
        () => CategoriesCubit(categoryRepo: sl()),
  );
  sl.registerLazySingleton<BrandCubit>(
        () => BrandCubit(storeRepo: sl()),
  );
  sl.registerLazySingleton<CartCubit>(
        () => CartCubit(),
  );

  sl.registerFactory<PromoSliderCubit>(() => PromoSliderCubit(homeRepo: sl()));
  sl.registerFactory<ProductsCubit>(() => ProductsCubit(homeRepo: sl()));
  sl.registerFactory<ImagesCubit>(() => ImagesCubit());
  sl.registerFactory<VariationCubit>(() => VariationCubit());
  sl.registerFactory<AllProductsCubit>(() => AllProductsCubit(homeRepo: sl(), storeRepo: sl()));
  sl.registerFactory<FavoritesCubit>(() => FavoritesCubit(sl()));
  sl.registerFactory<AddressCubit>(() => AddressCubit(addressRepo: sl()));
  sl.registerFactory<OrderCubit>(() => OrderCubit(orderRepository: sl()));
  sl.registerFactory<CheckoutCubit>(() => CheckoutCubit());
  sl.registerLazySingleton(() => RecentSearchesStore());

  sl.registerFactory(() => SearchCubit(
    homeRepo: sl<HomeRepo>(),
    recentStore: sl<RecentSearchesStore>(),
  ));


   sl.registerLazySingleton<ReviewsRepo>(
        () => ReviewsRepoImpl(),
  );

   sl.registerFactory(
        () => ReviewsCubit(reviewsRepo: sl<ReviewsRepo>()),
  );

}