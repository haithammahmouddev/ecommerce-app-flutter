import 'package:fit_store/common/widgets/appbar/appbar.dart';
import 'package:fit_store/utils/constants/colors.dart';
import 'package:fit_store/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/address/address_cubit.dart';
import 'widgets/add_new_address.dart';
import 'widgets/single_address_widget.dart';

class UserAddressScreen extends StatefulWidget {
  const UserAddressScreen({super.key});
  static const routeName = '/user-address-screen';

  @override
  State<UserAddressScreen> createState() => _UserAddressScreenState();
}

class _UserAddressScreenState extends State<UserAddressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressCubit>().fetchUserAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<AddressCubit>(),
                child: const AddNewAddressScreen(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBarCustom(
        showBackArrow: true,
        title: Text(
          'Addresses',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showActions: false,
        showSkipButton: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSizes.defaultSpace),
        child: BlocBuilder<AddressCubit, AddressState>(
          builder: (context, state) {
            if (state.status == AddressStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == AddressStatus.error) {
              return Center(
                child: Text(
                  state.errorMessage ?? 'An error occurred while fetching addresses.',
                ),
              );
            }
            if (state.addresses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_off_outlined,
                      size: 64.r,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No addresses found!',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: state.addresses.length,
              itemBuilder: (context, index) {
                final address = state.addresses[index];
                return SingleAddress(
                  address: address,
                  onTap: () {
                    context.read<AddressCubit>().selectAddress(address);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}