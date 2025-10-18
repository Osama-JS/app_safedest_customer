import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';


class ProgressWithIcon extends StatelessWidget {
  const ProgressWithIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          GifView.asset(
            'assets/gifs/logo.gif',
            // ImageConstant.imgHalalaLogoAnimat2,
            height: 60,
            width: 60,
            frameRate: 60, // default is 15 FPS
          )
          // you can replace

        ],
      ),
    );
  }
}