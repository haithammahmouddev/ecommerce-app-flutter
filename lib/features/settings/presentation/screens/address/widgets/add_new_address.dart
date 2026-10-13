import 'package:fit_store/common/widgets/appbar/appbar.dart';
import 'package:fit_store/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/address/address_cubit.dart';

class AddNewAddressScreen extends StatelessWidget {
  const AddNewAddressScreen({super.key});
  static const routeName = '/add-new-address-screen';

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddressCubit>();

    return BlocListener<AddressCubit, AddressState>(
      listener: (context, state) {
        if (state.status == AddressStatus.addSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Your address has been saved successfully.')),
          );
          Navigator.of(context).pop();
        } else if (state.status == AddressStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Failed to save address.')),
          );
        }
      },
      child: Scaffold(
        appBar: const AppBarCustom(
          showBackArrow: true,
          title: Text('Add new Address'),
          showActions: false,
          showSkipButton: false,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(AppSizes.defaultSpace),
            child: Form(
              key: cubit.addressFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: cubit.nameController,
                    validator: (value) => value == null || value.isEmpty ? 'Name is required' : null,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Iconsax.user),
                      labelText: 'Name',
                    ),
                  ),
                  SizedBox(height: AppSizes.spaceBtwInputFields),
                  TextFormField(
                    controller: cubit.phoneNumberController,
                    validator: (value) => value == null || value.isEmpty ? 'Phone is required' : null,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Iconsax.mobile),
                      labelText: 'Phone Number',
                    ),
                  ),
                  SizedBox(height: AppSizes.spaceBtwInputFields),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: cubit.streetController,
                          validator: (value) => value == null || value.isEmpty ? 'Street is required' : null,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Iconsax.building_31),
                            labelText: 'Street',
                          ),
                        ),
                      ),
                      SizedBox(width: AppSizes.spaceBtwInputFields),
                      Expanded(
                        child: TextFormField(
                          controller: cubit.postalCodeController,
                          validator: (value) => value == null || value.isEmpty ? 'Postal Code is required' : null,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Iconsax.code),
                            labelText: 'Postal Code',
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.spaceBtwInputFields),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: cubit.cityController,
                          validator: (value) => value == null || value.isEmpty ? 'City is required' : null,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Iconsax.building),
                            labelText: 'City',
                          ),
                        ),
                      ),
                      SizedBox(width: AppSizes.spaceBtwInputFields),
                      Expanded(
                        child: TextFormField(
                          controller: cubit.stateController,
                          validator: (value) => value == null || value.isEmpty ? 'State is required' : null,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Iconsax.activity),
                            labelText: 'State',
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.spaceBtwInputFields),
                  TextFormField(
                    controller: cubit.countryController,
                    validator: (value) => value == null || value.isEmpty ? 'Country is required' : null,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Iconsax.global),
                      labelText: 'Country',
                    ),
                  ),
                  SizedBox(height: AppSizes.defaultSpace),
                  BlocBuilder<AddressCubit, AddressState>(
                    builder: (context, state) {
                      final isLoading = state.status == AddressStatus.loading;
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () => cubit.addNewAddress(),
                          child: isLoading
                              ? SizedBox(
                            height: 20.r,
                            width: 20.r,
                            child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                              : const Text('Save'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}