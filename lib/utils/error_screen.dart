
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';


import '../app_constants/colors.dart';
import 'appbutton_widget.dart';
import 'apptext.dart';

class ErrorScreenWithLottie extends StatelessWidget {
  final String errorMessage;
  final String lottieAssetPath;
  final VoidCallback onRetry;

  const ErrorScreenWithLottie({
    Key? key,
    required this.errorMessage,
    required this.lottieAssetPath,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie animation
            Lottie.asset(
              lottieAssetPath,
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            // Error message
            Text(
              errorMessage,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Retry button
           AppButton(
              onTap: onRetry,
              height: 48,
              width: 250,
              color: AppColors.champagnePink,
              child: AppText(data: "Login",color: Colors.white,fw: FontWeight.w700,size: 18,)
            ),
          ],
        ),
      ),
    );
  }
}