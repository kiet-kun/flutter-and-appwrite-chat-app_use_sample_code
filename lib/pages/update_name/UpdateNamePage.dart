import 'dart:io';

import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:chat_with_bisky/bloc/auth/auth_bloc.dart';
import 'package:chat_with_bisky/bloc/auth/auth_event.dart';
import 'package:chat_with_bisky/constant/strings.dart';
import 'package:chat_with_bisky/service/LocalStorageService.dart';
import 'package:chat_with_bisky/values/values.dart';
import 'package:chat_with_bisky/widget/custom_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:uuid/uuid.dart';

import '../../bloc/auth/auth_state.dart';
import '../../route/app_route/AppRouter.gr.dart';

@RoutePage()
class UpdateNamePage extends StatefulWidget {
  final String userId;

  const UpdateNamePage(this.userId, {super.key});

  @override
  _UpdateNamePageState createState() {
    return _UpdateNamePageState();
  }
}

class _UpdateNamePageState extends State<UpdateNamePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController controller = TextEditingController();

  String profilePictureStorageId = "";
  String imageExist = "";
  String imageUrl = "https://www.w3schools.com/w3images/avatar3.png";
  Uint8List? uint8list;
  File? imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LoadingUpdateUserAuthState) {
          ChatDialogs.waiting(context, "loading.....");
        } else if (state is SuccessUpdateUserAuthState) {
          ChatDialogs.hideProgress(context);
          // navigate to dashboard
          LocalStorageService.putString(LocalStorageService.stage,LocalStorageService.dashboardPage);
          AutoRouter.of(context).push(const DashboardPage());

        } else if (state is FailureUpdateUserAuthState) {
          ChatDialogs.hideProgress(context);

          ChatDialogs.informationOkDialog(context,
              title: "Error",
              description: state.message,
              type: AlertType.error);
        } else if (state is SuccessgetExistingUserAuthState) {
          setState(() {
            controller.text = state.user.name ?? "";
            profilePictureStorageId = state.user.profilePictureStorageId ?? "";
            imageExist = state.user.profilePictureStorageId ?? "";
          });
          if (profilePictureStorageId.isNotEmpty) {
            BlocProvider.of<AuthBloc>(context)
                .add(GetExistingProfilePictureEvent(profilePictureStorageId));
          }
        } else if (state is ExistingProfilePictureAuthState) {
          setState(() {
            uint8list = state.uint8list;
          });
        } else if (state is SuccessUploadProfilePictureAuthState) {


          BlocProvider.of<AuthBloc>(context).add(UpdateUserEvent(
              widget.userId, controller.text, profilePictureStorageId));

        }else if (state is FailureUploadingProfilePictureAuthState) {

          ChatDialogs.informationOkDialog(context,
              title: "Error",
              description: state.message,
              type: AlertType.error);

        }
      },
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.gallery);

                  setState(() {
                    if (image != null) {
                      imageUrl = image.path;
                      imageFile = File(imageUrl);
                    }
                  });
                },
                child: CircleAvatar(
                    child: imageFile != null
                        ? ClipOval(child: Image.file(imageFile!))
                        : ClipOval(
                            child: uint8list == null
                                ? Image.network(imageUrl!)
                                : Image.memory(
                                    uint8list!,
                                  )),
                    radius: 80,
                    backgroundColor: Colors.grey),
              ),
              const SizedBox(
                height: Sizes.HEIGHT_10,
              ),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: Strings.displayName),
              ),
              const SizedBox(
                height: Sizes.HEIGHT_20,
              ),
              ElevatedButton(
                onPressed: () {

                  if(imageFile != null){

                    profilePictureStorageId = const Uuid().v4();
                    BlocProvider.of<AuthBloc>(context).add(UploadProfilePictureEvent(imageFile!.path,
                        profilePictureStorageId,imageExist));

                  }else{
                    BlocProvider.of<AuthBloc>(context).add(UpdateUserEvent(
                        widget.userId, controller.text, profilePictureStorageId));
                  }


                },
                child: const Text("Update"),
              ),
            ],
          )
        ],
      ),
    ));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AuthBloc>(context).add(GetExistingUserEvent(widget.userId));
  }
}
