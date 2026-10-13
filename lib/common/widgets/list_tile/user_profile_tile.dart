import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import '../../../features/settings/presentation/controllers/user_cubit/user_cubit.dart';
import '../../../features/settings/presentation/screens/profile/profile_screen.dart';
import '../images/circular_image.dart';

class UserProfileTile extends StatelessWidget {
  const UserProfileTile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        switch (state.userDataStatus) {
          case UserDataStatus.loading:
            return const _ProfileTileShimmer();

          case UserDataStatus.error:
            return ListTile(
              leading: const CircleAvatar(
                radius: 25,
                child: Icon(Iconsax.user),
              ),
              title: Text(
                'حدث خطأ في تحميل البيانات',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .apply(color: Colors.white),
              ),
              subtitle: Text(
                state.errorMessage ?? '',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .apply(color: Colors.white70),
              ),
              trailing: IconButton(
                onPressed: () => context.read<UserCubit>().getUserData(),
                icon: const Icon(Iconsax.refresh, color: Colors.white),
              ),
            );

          case UserDataStatus.loaded:
            return ListTile(
              leading: CircularImage(
                image: state.user!.profilePicture,
                isNetworkImage: true,
                height: 50,
                width: 50,
                padding: 0,
              ),
              title: Text(
                state.user?.fullName ?? 'Guest',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .apply(color: Colors.white),
              ),
              subtitle: Text(
                state.user?.email ?? '',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .apply(color: Colors.white),
              ),
              trailing: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                     MaterialPageRoute(builder: (_){
                       return BlocProvider.value(
                           value: context.read<UserCubit>(),
                           child: ProfileScreen(),
                       );
                     }),
                  );
                },
                icon: const Icon(
                  Iconsax.edit,
                  color: Colors.white,
                ),
              ),
            );
        }
      },
    );
  }
}

class _ProfileTileShimmer extends StatelessWidget {
  const _ProfileTileShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white24,
      highlightColor: Colors.white54,
      child: ListTile(
        leading: const CircleAvatar(
          radius: 25,
          backgroundColor: Colors.white,
        ),
        title: Container(
          width: 120,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Container(
            width: 180,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}