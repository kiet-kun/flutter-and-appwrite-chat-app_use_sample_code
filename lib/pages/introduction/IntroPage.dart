


import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:chat_with_bisky/route/app_route/AppRouter.gr.dart';
import 'package:chat_with_bisky/values/values.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

@RoutePage()
class IntroPage extends StatefulWidget{

  @override
  _IntroPageState  createState() {


    return _IntroPageState();
  }

}


class  _IntroPageState extends State<IntroPage>{


  @override
  Widget build(BuildContext context) {

    return introWidget();
  }


  Widget introWidget(){

    return IntroductionScreen(
      showSkipButton: false,
      next: const Icon(Icons.arrow_forward_ios),
      pages: [
        PageViewModel(
          title: "Chat With Loved Ones",
          body: "Chat with your loved ones and share your experience",
          image: _buildImage(ImagePath.intro1)
        ),
        PageViewModel(
            title: "More Secure",
            body: "We are more concerned about your privacy",
            image: _buildImage(ImagePath.intro2)
        ),
        PageViewModel(
            title: "Share Files",
            body: "Share images, videos, location and documents with your loved ones",
            image: _buildImage(ImagePath.intro3)
        )

      ],
      onDone:onDonePress,
      showDoneButton: true,
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),


    );
  }


  Widget _buildImage(String imagePath){

    return Image.asset(imagePath,width: 150,);
  }

  void onDonePress() {

    print("Ondone.....");

    AutoRouter.of(context).push(const LoginPage());
  }

}
