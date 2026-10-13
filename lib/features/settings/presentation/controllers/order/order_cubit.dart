import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fit_store/features/settings/data/models/address_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../../../../common/widgets/success_screen/success_screen.dart';
import '../../../../../navigation_menu.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/helpers/paypal_webview_screen.dart';
import '../../../../../utils/popups/full_screen_loader.dart';
import '../../../../../utils/popups/loaders.dart';
import '../../../../cart/presentation/controllers/cart/cart_cubit.dart';
import '../../../../checkout/presentation/controllers/checkout/checkout_cubit.dart';
import '../../../data/models/order_model.dart';
import '../../../domain/repos/order_repo.dart';
import '../address/address_cubit.dart';
import 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository _orderRepository;
  StreamSubscription? _ordersSubscription;

  OrderCubit({required this._orderRepository}) : super(const OrderState());

  Future<void> fetchUserOrders(BuildContext context) async {
    emit(state.copyWith(status: OrderStatusEnum.loading));

    try {
      await _ordersSubscription?.cancel();

      await for (final result in _orderRepository.fetchUserOrdersStream()) {
        result.fold(
          (error) {
            emit(
              state.copyWith(
                status: OrderStatusEnum.error,
                errorMessage: error.message,
              ),
            );
            if (context.mounted) {
              Loaders.warningSnackBar(
                title: 'Oh Snap!',
                message: error.message,
                context: context,
              );
            }
          },
          (userOrders) {
            emit(
              state.copyWith(
                status: OrderStatusEnum.success,
                orders: userOrders,
              ),
            );
          },
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: OrderStatusEnum.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }

  void _goToSuccess(BuildContext context) {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(
      context,
      SuccessScreen.routeName,
      arguments: {
        'image': AppImages.successfullyRegisterAnimation,
        'title': 'Payment Success!',
        'subTitle': 'Your item will be shipped soon!',
        'onPressed': (successContext) {
          Navigator.pushNamedAndRemoveUntil(
            successContext,
            NavigationMenu.routeName,
            (route) => false,
          );
        },
      },
    );
  }


  Future<void> _saveOrderAndFinish({
    required BuildContext context,
    required OrderModel order,
    required String userId,
    required CartCubit cartCubit,
  }) async {
    FullScreenLoader.popUpCircular(context);

    final result = await _orderRepository.saveOrder(order, userId);

    result.fold(
      (error) {
        if (context.mounted) FullScreenLoader.stopLoading(context);
        emit(
          state.copyWith(
            status: OrderStatusEnum.error,
            errorMessage: error.message,
          ),
        );
        if (context.mounted) {
          Loaders.errorSnackBar(
            title: 'Oh Snap!',
            message: error.message,
            context: context,
          );
        }
      },
      (_) {
        cartCubit.clearCart();
        if (context.mounted) FullScreenLoader.stopLoading(context);
        emit(state.copyWith(status: OrderStatusEnum.processingSuccess));
        _goToSuccess(context);
      },
    );
  }

  Future<void> _processStripePayment({
    required BuildContext context,
    required double totalAmount,
    required CardBrandAcceptance cardBrandAcceptance,
    required OrderModel order,
    required String userId,
  }) async {
    bool loaderVisible = true;
    void hideLoader() {
      if (loaderVisible && context.mounted) {
        FullScreenLoader.stopLoading(context);
      }
      loaderVisible = false;
    }

    try {
      final supabaseAnonKey = dotenv.env['SUPABASE_PUBLISHER_KEY']!;
      const functionBaseUrl =
          'https://uvymvisxemcodavxgoks.supabase.co/functions/v1';

      final response = await http.post(
        Uri.parse('$functionBaseUrl/create-stripe-payment'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': supabaseAnonKey,
          'Authorization': 'Bearer $supabaseAnonKey',
        },
        body: jsonEncode({'amount': totalAmount, 'currency': 'usd'}),
      );

      if (response.statusCode != 200) {
        throw 'Failed to create payment intent: ${response.body}';
      }

      final data = jsonDecode(response.body);
      if (data['error'] != null) {
        throw data['error'];
      }

      final clientSecret = data['clientSecret'];

      hideLoader();
      if (!context.mounted) return;

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Fit Store',
          paymentIntentClientSecret: clientSecret,
          style: ThemeMode.dark,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(primary: Colors.blue),
          ),
          cardBrandAcceptance: cardBrandAcceptance,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      if (!context.mounted) return;
      FullScreenLoader.popUpCircular(context);
      loaderVisible = true;

      final saved = await _orderRepository.saveOrder(order, userId);
      saved.fold<void>((error) => throw error.message, (_) {});

      if (!context.mounted) return;
      final cartCubit = context.read<CartCubit>();
      cartCubit.clearCart();

      hideLoader();
      emit(state.copyWith(status: OrderStatusEnum.processingSuccess));
      _goToSuccess(context);
    } catch (e) {
      hideLoader();
      emit(
        state.copyWith(
          status: OrderStatusEnum.error,
          errorMessage: e.toString(),
        ),
      );
      if (context.mounted) {
        if (e is StripeException) {
          Loaders.warningSnackBar(
            title: 'Payment cancelled',
            message: e.error.localizedMessage ?? 'Payment was cancelled.',
            context: context,
          );
        } else {
          Loaders.errorSnackBar(
            title: 'Stripe Error',
            message: e.toString(),
            context: context,
          );
        }
      }
    }
  }

  Future<void> processOrder({
    required BuildContext context,
    required double totalAmount,
  }) async {
    FullScreenLoader.popUpCircular(context);

    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      FullScreenLoader.stopLoading(context);
      return;
    }

    final checkoutCubit = context.read<CheckoutCubit>();
    final paymentMethod = checkoutCubit.state.selectedPaymentMethod;
    final addressCubit = context.read<AddressCubit>();
    final cartCubit = context.read<CartCubit>();
    final cartItems = cartCubit.state.cartItems;

    if (addressCubit.state.selectedAddress.id.isEmpty) {
      await addressCubit.fetchUserAddresses();
    }

    var selectedAddress = addressCubit.state.selectedAddress;

    if (selectedAddress.id.isEmpty && addressCubit.state.addresses.isNotEmpty) {
      selectedAddress = addressCubit.state.addresses.first;
    }

    if (selectedAddress.id.isEmpty) {
      if (context.mounted) {
        FullScreenLoader.stopLoading(context);
        Loaders.warningSnackBar(
          title: 'Address required',
          message: 'Please add or select a shipping address first.',
          context: context,
        );
      }
      return;
    }

    final order = OrderModel(
      id: Uuid().v4(),
      userId: userId,
      status: OrderStatus.pending,
      totalAmount: totalAmount,
      orderDate: DateTime.now(),
      paymentMethod: paymentMethod.name,
      address: AddressModel.fromEntity(selectedAddress),
      deliveryDate:
          null,
      items: cartItems.toList(),
    );

    final methodName = paymentMethod.name
        .toLowerCase()
        .replaceAll('_', '')
        .replaceAll(' ', '');

    if (methodName == 'paypal') {
      bool loaderVisible = true;
      void hideLoader() {
        if (loaderVisible && context.mounted) {
          FullScreenLoader.stopLoading(context);
        }
        loaderVisible = false;
      }

      try {
        final supabaseAnonKey = dotenv.env['SUPABASE_PUBLISHER_KEY']!;
        const functionBaseUrl =
            'https://uvymvisxemcodavxgoks.supabase.co/functions/v1';

        final createRes = await http.post(
          Uri.parse('$functionBaseUrl/create-paypal-order'),
          headers: {
            'Content-Type': 'application/json',
            'apikey': supabaseAnonKey,
            'Authorization': 'Bearer $supabaseAnonKey',
          },
          body: jsonEncode({'amount': totalAmount.toStringAsFixed(2)}),
        );

        if (createRes.statusCode != 200) {
          throw 'Failed to create order: ${createRes.body}';
        }

        final data = jsonDecode(createRes.body);
        if (data['success'] != true) {
          throw data['error'] ?? 'PayPal order creation failed';
        }
        final String approvalUrl = data['approvalUrl'];
        final String paypalOrderId = data['orderId'];

        hideLoader();
        if (!context.mounted) return;

        final approved = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PayPalWebViewScreen(approvalUrl: approvalUrl),
          ),
        );

        if (approved != true) {
          if (context.mounted) {
            Loaders.warningSnackBar(
              title: 'Payment cancelled',
              message: 'You cancelled the PayPal payment.',
              context: context,
            );
          }
          return;
        }

        if (!context.mounted) return;
        FullScreenLoader.popUpCircular(context);
        loaderVisible = true;

        final captureRes = await http.post(
          Uri.parse('$functionBaseUrl/rapid-processor'),
          headers: {
            'Content-Type': 'application/json',
            'apikey': supabaseAnonKey,
            'Authorization': 'Bearer $supabaseAnonKey',
          },
          body: jsonEncode({'orderId': paypalOrderId}),
        );

        if (captureRes.statusCode != 200) {
          throw 'Failed to capture order: ${captureRes.body}';
        }

        final capData = jsonDecode(captureRes.body);
        if (capData['success'] != true) {
          throw 'Payment was not completed (${capData['error'] ?? 'unknown'})';
        }

        final saved = await _orderRepository.saveOrder(order, userId);
        saved.fold<void>((error) => throw error.message, (_) {});
        cartCubit.clearCart();

        hideLoader();
        emit(state.copyWith(status: OrderStatusEnum.processingSuccess));
        _goToSuccess(context);
      } catch (e) {
        hideLoader();
        emit(
          state.copyWith(
            status: OrderStatusEnum.error,
            errorMessage: e.toString(),
          ),
        );
        if (context.mounted) {
          Loaders.errorSnackBar(
            title: 'PayPal Error',
            message: e.toString(),
            context: context,
          );
        }
      }
      return;
    }

    if (methodName == 'creditcard') {
      await _processStripePayment(
        context: context,
        totalAmount: totalAmount,
        cardBrandAcceptance: const CardBrandAcceptance.all(),
        order: order,
        userId: userId,
      );
      return;
    }

    if (methodName == 'vodafonecash') {
      FullScreenLoader.stopLoading(context);

      final TextEditingController phoneController = TextEditingController();
      final GlobalKey<FormState> formKey = GlobalKey<FormState>();
      bool confirmed = false;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.asset(
                              'assets/icons/payment_methods/vc.png',
                              height: 32,
                              width: 32,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Vodafone Cash',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(dialogContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Enter your mobile wallet number to receive the payment request.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 11,
                    decoration: InputDecoration(
                      labelText: 'Wallet Phone Number',
                      hintText: '010XXXXXXXX',
                      prefixIcon: const Icon(Icons.phone_android_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (!value.startsWith('01') || value.length != 11) {
                        return 'Enter a valid 11-digit Vodafone number (01x...)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          confirmed = true;
                          Navigator.pop(dialogContext);
                        }
                      },
                      child: const Text(
                        'Confirm & Pay',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      if (confirmed && context.mounted) {
        await _saveOrderAndFinish(
          context: context,
          order: order,
          userId: userId,
          cartCubit: cartCubit,
        );
      }
      return;
    }

    if (methodName == 'fawry') {
      FullScreenLoader.stopLoading(context);

      final String mockRefNumber =
          '789${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      bool confirmed = false;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            'assets/icons/payment_methods/Fawry-Logo.jpg.webp',
                            height: 32,
                            width: 32,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.payment_rounded,
                                  color: Colors.orange,
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'FawryPay',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please use the reference number below to complete your payment at any Fawry outlet or via MyFawry App:',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Reference Number',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        mockRefNumber,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.5,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      confirmed = true;
                      Navigator.pop(dialogContext);
                    },
                    child: const Text(
                      'I Have Paid (Simulate Success)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      if (confirmed && context.mounted) {
        await _saveOrderAndFinish(
          context: context,
          order: order,
          userId: userId,
          cartCubit: cartCubit,
        );
      }
      return;
    }

    if (methodName == 'instapay') {
      FullScreenLoader.stopLoading(context);

      final TextEditingController ipaController = TextEditingController();
      final GlobalKey<FormState> formKey = GlobalKey<FormState>();
      bool confirmed = false;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.purple,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'InstaPay',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(dialogContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Enter your InstaPay address (IPA) or username to receive the transfer request:',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: ipaController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'InstaPay Address (IPA)',
                      hintText: 'username@instapay',
                      prefixIcon: const Icon(Icons.alternate_email_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.purple,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your InstaPay address';
                      }
                      if (!value.contains('@')) {
                        return 'Enter a valid IPA (e.g. name@instapay)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          confirmed = true;
                          Navigator.pop(dialogContext);
                        }
                      },
                      child: const Text(
                        'Pay via InstaPay (Simulate)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      if (confirmed && context.mounted) {
        await _saveOrderAndFinish(
          context: context,
          order: order,
          userId: userId,
          cartCubit: cartCubit,
        );
      }
      return;
    }

    final result = await _orderRepository.saveOrder(order, userId);
    result.fold(
      (error) {
        if (context.mounted) FullScreenLoader.stopLoading(context);
        emit(
          state.copyWith(
            status: OrderStatusEnum.error,
            errorMessage: error.message,
          ),
        );
        if (context.mounted) {
          Loaders.errorSnackBar(
            title: 'Oh Snap!',
            message: error.message,
            context: context,
          );
        }
      },
      (_) {
        cartCubit.clearCart();
        if (context.mounted) FullScreenLoader.stopLoading(context);

        emit(state.copyWith(status: OrderStatusEnum.processingSuccess));
        _goToSuccess(context);
      },
    );
  }
}
