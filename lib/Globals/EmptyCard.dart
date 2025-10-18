import 'MyColors.dart';
import 'package:flutter/material.dart';

import '../shared_prff.dart';

class EmptyCard extends StatelessWidget {
  final double? width;
  final double? height;
  final double? vertical;
  final double? horizontal;

  const EmptyCard({
    super.key,
    this.width,
    this.height,
    this.vertical,
    this.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin:  EdgeInsets.symmetric(vertical: vertical!, horizontal: horizontal!),
      decoration:  BoxDecoration(
        color: MyColors.inputBorderColor,
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    );
  }
}
