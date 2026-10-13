import 'package:equatable/equatable.dart';
import 'package:fit_store/common/local_storage/loacal_storage_service.dart';
import 'package:fit_store/features/settings/data/models/address_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../common/widgets/texts/section_heading.dart';
import '../../screens/address/widgets/add_new_address.dart';
import '../../screens/address/widgets/single_address_widget.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/network_manager.dart';
import '../../../domain/entities/address_entity.dart';
import '../../../domain/repos/address_repo.dart';


part 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  final AddressRepo _addressRepo;

  final nameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final streetController = TextEditingController();
  final postalCodeController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController();
  final addressFormKey = GlobalKey<FormState>();

  AddressCubit({required this._addressRepo}) : super(AddressState());

  Future<void> fetchUserAddresses() async {
    emit(state.copyWith(status: AddressStatus.loading));
    final List<AddressModel>? userAddressesCached = LocalStorageService
        .addressRepo
        .getData();
    final bool isConnectedInternet = await NetworkManager.instance
        .isConnected();

    if (isConnectedInternet) {
      print(userAddressesCached);
      final result = await _addressRepo.fetchUserAddresses();

      result.fold(
        (failure) {
          if (userAddressesCached != null && userAddressesCached.isNotEmpty) {
            final List<AddressEntity> addressEntities = userAddressesCached
                .map((e) => e.toEntity())
                .toList();
            final selected = addressEntities.firstWhere(
              (element) => element.selectedAddress,
              orElse: () => AddressEntity.emptyAddress,
            );
            emit(
              state.copyWith(
                status: AddressStatus.success,
                addresses: addressEntities,
                selectedAddress: selected,
              ),
            );
          } else {
            emit(
              state.copyWith(
                status: AddressStatus.error,
                errorMessage: failure.message,
              ),
            );
          }
        },
        (successAddresses) {
          final selected = successAddresses.firstWhere(
            (element) => element.selectedAddress,
            orElse: () => AddressEntity.emptyAddress,
          );

          emit(
            state.copyWith(
              status: AddressStatus.success,
              addresses: successAddresses,
              selectedAddress: selected,
            ),
          );
        },
      );
    } else {
      if (userAddressesCached != null && userAddressesCached.isNotEmpty) {
        final List<AddressEntity> addressEntities = userAddressesCached
            .map((e) => e.toEntity())
            .toList();
        final selected = addressEntities.firstWhere(
          (element) => element.selectedAddress,
          orElse: () => AddressEntity.emptyAddress,
        );

        emit(
          state.copyWith(
            status: AddressStatus.success,
            addresses: addressEntities,
            selectedAddress: selected,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AddressStatus.error,
            errorMessage: "No internet connection, please check your network.",
          ),
        );
      }
    }
  }

  Future<void> selectAddress(AddressEntity newSelectedAddress) async {
    final previousAddresses = state.addresses;
    final previousSelected = state.selectedAddress;

    final optimisticList = state.addresses.map((address) {
      return address.copyWith(
        selectedAddress: address.id == newSelectedAddress.id,
      );
    }).toList();

    final optimisticSelected = newSelectedAddress.copyWith(
      selectedAddress: true,
    );

    emit(
      state.copyWith(
        status: AddressStatus.loading,
        addresses: optimisticList,
        selectedAddress: optimisticSelected,
      ),
    );

    if (!await NetworkManager.instance.isConnected()) {
      emit(
        state.copyWith(
          status: AddressStatus.error,
          errorMessage: 'لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة.',
          addresses: previousAddresses,
          selectedAddress: previousSelected,
        ),
      );
      return;
    }

    bool hasError = false;

    if (previousSelected.id.isNotEmpty &&
        previousSelected.id != newSelectedAddress.id) {
      final result = await _addressRepo.updateSelectedField(
        previousSelected.id,
        false,
      );
      result.fold((error) {
        hasError = true;
        emit(
          state.copyWith(
            status: AddressStatus.error,
            errorMessage: error.message,
            addresses: previousAddresses,
            selectedAddress: previousSelected,
          ),
        );
      }, (_) {});
    }

    if (hasError) return;

    final selectResult = await _addressRepo.updateSelectedField(
      newSelectedAddress.id,
      true,
    );

    selectResult.fold(
      (failure) {
        emit(
          state.copyWith(
            status: AddressStatus.error,
            errorMessage: failure.message,
            addresses: previousAddresses,
            selectedAddress: previousSelected,
          ),
        );
      },
      (_) async {
        emit(state.copyWith(status: AddressStatus.success));
        await LocalStorageService.addressRepo.saveData(
          optimisticList
              .map((entity) => AddressModel.fromEntity(entity))
              .toList(),
        );
      },
    );
  }

  Future<dynamic> selectNewAddressPopup(BuildContext context) {
    fetchUserAddresses();

    return showModalBottomSheet(
      context: context,
      builder: (_) => BlocProvider.value(
        value: this,
        child: Container(
          padding: EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SectionHeading(
                title: 'Select Address',
                showActionButton: false,
              ),
              SizedBox(height: AppSizes.spaceBtwItems),
              Flexible(
                child: BlocBuilder<AddressCubit, AddressState>(
                  builder: (context, state) {
                    if (state.status == AddressStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.addresses.isEmpty) {
                      return const Center(child: Text('No Address Found'));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.addresses.length,
                      itemBuilder: (_, index) {
                        final address = state.addresses[index];
                        return SingleAddress(
                          address: address,
                          onTap: () async {
                            await selectAddress(address);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: AppSizes.defaultSpace * 2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AddNewAddressScreen(),
                      ),
                    );
                  },
                  child: const Text('Add new address'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> addNewAddress() async {
    if (!addressFormKey.currentState!.validate()) return;

    emit(state.copyWith(status: AddressStatus.loading));

    final newAddress = AddressEntity(
      id: '',
      name: nameController.text.trim(),
      phoneNumber: phoneNumberController.text.trim(),
      street: streetController.text.trim(),
      city: cityController.text.trim(),
      state: stateController.text.trim(),
      postalCode: postalCodeController.text.trim(),
      country: countryController.text.trim(),
      selectedAddress: true,
      dateTime: DateTime.now(),
    );

    final result = await _addressRepo.addAddress(newAddress);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: AddressStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (addressId) async {
        final addressWithId = newAddress.copyWith(id: addressId);

        await selectAddress(addressWithId);
        clearFormFields();
        await fetchUserAddresses();

        emit(state.copyWith(status: AddressStatus.addSuccess));
      },
    );
  }

  void clearFormFields() {
    nameController.clear();
    phoneNumberController.clear();
    streetController.clear();
    postalCodeController.clear();
    cityController.clear();
    stateController.clear();
    countryController.clear();
    addressFormKey.currentState?.reset();
  }

  @override
  Future<void> close() {
    nameController.dispose();
    phoneNumberController.dispose();
    streetController.dispose();
    postalCodeController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    return super.close();
  }
}
