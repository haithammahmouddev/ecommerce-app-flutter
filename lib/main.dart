import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fit_store/features/settings/presentation/controllers/user_cubit/user_cubit.dart';
import 'package:fit_store/features/settings/presentation/controllers/address/address_cubit.dart';
import 'package:fit_store/utils/helpers/deep_link_handler.dart';
import 'package:fit_store/common/local_storage/loacal_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'common/di/injection_container.dart';
import 'common/preferences/preferences_manager.dart';
import 'features/cart/presentation/controllers/cart/cart_cubit.dart';
import 'features/favourites/presentation/controllers/favorites_cubit/favorites_cubit.dart';
import 'features/home/data/model/product_model.dart';
import 'features/home/presentation/controller/products_cubit/products_cubit.dart';
import 'features/settings/presentation/controllers/order/order_cubit.dart';
import 'features/settings/presentation/controllers/theme/theme_controller_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_PUBLISHER_KEY']!,
  );
  await PreferencesManager().init();
  await LocalStorageService.init();
  await initDependencies();

  final themeController = ThemeController();
  await themeController.init();


  final deepLinkHandler = DeepLinkHandler(
    fetchProductById: (id) async {
      final doc = await FirebaseFirestore.instance
          .collection('Products')
          .doc(id)
          .get();

      final data = doc.data();
      if (!doc.exists || data == null) return null;

      return ProductModel.fromFirebaseJson(data, doc.id).toEntity();
    },
  );
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;
  await Stripe.instance.applySettings();
  runApp(
    ChangeNotifierProvider.value(
      value: themeController,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => sl<FavoritesCubit>()),
          BlocProvider(create: (context) => sl<AddressCubit>()),
          BlocProvider(create: (context) => sl<CartCubit>()),
          BlocProvider(create: (context) => sl<UserCubit>()),
          BlocProvider(create: (context) => sl<OrderCubit>()),
          BlocProvider(create: (context) => sl<ProductsCubit>()),
        ],
        child: const App(),
      ),
    ),
  );

  deepLinkHandler.init();
}
