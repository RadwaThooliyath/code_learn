import 'package:flutter/material.dart';



class ImageWidget extends StatelessWidget {

  final String? assetName;
  final String ?semanticLabel;
  const ImageWidget({super.key,this.assetName,this.semanticLabel});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
        assetName!,
        // colorFilter: ColorFilter.mode(Colors.red, BlendMode.srcIn),

    );
  }
}
