import 'package:equatable/equatable.dart';
import 'package:fit_store/features/settings/presentation/screens/setting_screen.dart';
import 'package:fit_store/features/store/presentation/screens/store.dart';
import 'package:fit_store/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'features/home/presentation/screens/home.dart';
import 'features/favourites/presentation/screens/favourite.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  static const routeName = '/navigation-menu';

  static final List<Widget> screens = [
    const HomeScreen(),
    const StoreScreen(),
    const FavouriteScreen(),
    const SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NavigationBarCubit>(
          create: (context) => NavigationBarCubit(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final darkMode = HelperFunctions.isDarkMode(context);

          return BlocBuilder<NavigationBarCubit, NavigationBarState>(
            builder: (context, state) {
              return Scaffold(
                body: IndexedStack(
                  index: state.currentIndex,
                  children: screens,
                ),
                bottomNavigationBar: NavigationBar(
                  height: 80,
                  elevation: 0,
                  selectedIndex: state.currentIndex,
                  backgroundColor: darkMode ? Colors.black : Colors.white,
                  indicatorColor: darkMode
                      ? Colors.white.withOpacity(.1)
                      : Colors.black.withOpacity(.1),
                  onDestinationSelected: (index) {
                    context.read<NavigationBarCubit>().changeIndex(index);
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Iconsax.home),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Iconsax.shop),
                      label: 'Store',
                    ),
                    NavigationDestination(
                      icon: Icon(Iconsax.heart),
                      label: 'Heart',
                    ),
                    NavigationDestination(
                      icon: Icon(Iconsax.user),
                      label: 'User',
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class NavigationBarState extends Equatable {
  final int currentIndex;

  const NavigationBarState({this.currentIndex = 0});

  NavigationBarState copyWith({int? currentIndex}) {
    return NavigationBarState(currentIndex: currentIndex ?? this.currentIndex);
  }

  @override
  List<Object?> get props => [currentIndex];
}

class NavigationBarCubit extends Cubit<NavigationBarState> {
  NavigationBarCubit() : super(const NavigationBarState());

  void changeIndex(int index) {
    emit(state.copyWith(currentIndex: index));
  }
}
