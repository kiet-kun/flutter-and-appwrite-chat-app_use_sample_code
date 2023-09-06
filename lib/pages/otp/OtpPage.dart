


import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:chat_with_bisky/bloc/auth/auth_bloc.dart';
import 'package:chat_with_bisky/bloc/auth/auth_event.dart';
import 'package:chat_with_bisky/service/LocalStorageService.dart';
import 'package:chat_with_bisky/values/values.dart';
import 'package:chat_with_bisky/widget/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../bloc/auth/auth_state.dart';
import '../../route/app_route/AppRouter.gr.dart';

@RoutePage()
class OtpPage extends StatefulWidget{


  String userId;

  OtpPage(this.userId);


  @override
  _OtpPageState  createState() {


    return _OtpPageState();
  }

}


class  _OtpPageState extends State<OtpPage>{


  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(



      body: BlocListener<AuthBloc,AuthState>(

        listener: (context, state) {


          if (state is LoadingOtpVerificationAuthState){

            ChatDialogs.waiting(context, "loading.....");
          }else if (state is FailureOtpVerificationAuthState){
            ChatDialogs.hideProgress(context);
            ChatDialogs.informationOkDialog(context, title: "Error", description: state.message, type: AlertType.error);

          }else if (state is SuccessOtpVerificationAuthState){
            ChatDialogs.hideProgress(context);

            // persist user id and also the stage
            print("navigate to another page username page");
             LocalStorageService.putString(LocalStorageService.userId,widget.userId);
            LocalStorageService.putString(LocalStorageService.stage,LocalStorageService.updateNamePage);
            AutoRouter.of(context).push(UpdateNamePage(userId: widget.userId));

          }

        },
        child:  Stack(
          children: [

            Image.asset(ImagePath.background, height: MediaQuery.of(context).size.height,
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [


                OTPTextField(
                  otpFieldStyle: OtpFieldStyle(
                      backgroundColor: Colors.white, focusBorderColor: Colors.amber),
                  length: 6,
                  width: MediaQuery.of(context).size.width,
                  // fieldWidth: 40,
                  style: const TextStyle(fontSize: 17),
                  textFieldAlignment: MainAxisAlignment.spaceAround,
                  fieldStyle: FieldStyle.box,
                  onCompleted: (String code) {
                    controller.text = code;

                    BlocProvider.of<AuthBloc>(context)
                    .add(MobileNumberVerificationEvent(widget.userId,code));

                  },
                  onChanged: (String changed) {},
                  obscureText: false,
                ),


              ],)

          ],
        ),

      )

    );
  }




  @override
  void initState() {
    // TODO: implement initState
    super.initState();


  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

}
