import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:chat_with_bisky/bloc/auth/auth_bloc.dart';
import 'package:chat_with_bisky/bloc/auth/auth_event.dart';
import 'package:chat_with_bisky/model/AuthenticationState.dart';
import 'package:chat_with_bisky/pages/login/providers/AuthViewModel.dart';
import 'package:chat_with_bisky/service/LocalStorageService.dart';
import 'package:chat_with_bisky/values/values.dart';
import 'package:chat_with_bisky/widget/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../bloc/auth/auth_state.dart';
import '../../route/app_route/AppRouter.gr.dart';

@RoutePage()
class LoginPage extends ConsumerWidget {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController controller = TextEditingController();
  String initialCountry = 'BE';
  PhoneNumber number = PhoneNumber(isoCode: 'BE');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final notifier = ref.read(authNotifierProvider.notifier);
    final model = ref.watch(authNotifierProvider);
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            ImagePath.background,
            height: MediaQuery.of(context).size.height,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber number) {
                  this.number = number;
                },
                onInputValidated: (bool value) {},
                selectorConfig: const SelectorConfig(
                  selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                ),
                ignoreBlank: false,
                autoValidateMode: AutovalidateMode.disabled,
                selectorTextStyle: TextStyle(color: Colors.black),
                initialValue: number,
                textFieldController: controller,
                formatInput: true,
                keyboardType: const TextInputType.numberWithOptions(
                    signed: true, decimal: true),
                inputBorder: const OutlineInputBorder(),
                onSaved: (PhoneNumber number) {
                  print('On Saved: $number');
                },
              ),
              ElevatedButton(
                onPressed: () {
                  formKey.currentState?.validate();

                  getPhoneNumber(number, notifier, context, model);
                },
                child: const Text('Verify'),
              ),
            ],
          ),
          if (model.loading)
            Material(
              color: scheme.surfaceVariant.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
        ],
      ),
    );
  }

  void getPhoneNumber(PhoneNumber number, AuthNotifier notifier,
      BuildContext context, AuthenticationState model) async {
    String phone = number.phoneNumber!;
    LocalStorageService.putString(
        LocalStorageService.dialCode, number.dialCode ?? "");
    notifier.phoneNumberChanged(phone);
    await notifier.loginWithMobileNumber();

    print("navigate to another page otp confirmation");
    AutoRouter.of(context).push(OtpPage(userId: phone.substring(1)));
  }

  @override
  void dispose() {
    controller.dispose();
  }
}
