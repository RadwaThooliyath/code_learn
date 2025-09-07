import 'package:flutter_svg/svg.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/utils/customtextformfiled.dart';
import 'package:uptrail/utils/app_spacing.dart';
import 'package:uptrail/utils/app_decoration.dart';
import 'package:uptrail/utils/responsive_helper.dart';
import 'package:uptrail/view/navigPage.dart';
import 'package:uptrail/view/registerPage.dart';
import 'package:uptrail/view/forgot_password_page.dart';
import 'package:uptrail/view_model/auth_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
   _emailController.dispose();
   _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(

          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.green1.withValues(alpha: 0.8),
              AppColors.green2.withValues(alpha: 0.9),
              AppColors.green1.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: ResponsiveHelper.getScreenPadding(context),
              child: Container(
                width: ResponsiveHelper.getFormWidth(context),
                padding: AppSpacing.paddingXL,
                decoration: AppDecoration.elevatedCardDecoration,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 160,
                        height: 60,

                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: SvgPicture.asset(
                            'assets/logo/logo_white.svg',
                            width: 160,
                            height: 160,
                          ),
                        ),
                      ),
                      AppSpacing.medium,
                      Text(
                        "Welcome Back!",
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getHeadingSize(context),
                          fontWeight: FontWeight.bold,
                          color: AppColors.background,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        "Sign in to your account",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      AppSpacing.large,
                      Consumer<AuthViewModel>(
                        builder: (context, authViewModel, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextFormField(
                                controller: _emailController,
                                hintText: "Username/Email",
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email is required';
                                  }
                                  return null;
                                },
                              ),
                              if (authViewModel.fieldErrors.containsKey('email'))
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                                  child: Text(
                                    authViewModel.fieldErrors['email']!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      AppSpacing.small,
                      Consumer<AuthViewModel>(
                        builder: (context, authViewModel, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextFormField(
                                controller: _passwordController,
                                hintText: "Password",
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password is required';
                                  }
                                  return null;
                                },
                              ),
                              if (authViewModel.fieldErrors.containsKey('password'))
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                                  child: Text(
                                    authViewModel.fieldErrors['password']!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      AppSpacing.medium,
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ForgotPasswordPage(),
                              ),
                            );
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: AppColors.robinEggBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      AppSpacing.small,
                      Consumer<AuthViewModel>(
                        builder: (context, authViewModel, child) {
                          return SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: Container(
                              decoration: AppDecoration.primaryGradientDecoration,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppDecoration.borderRadiusL,
                                  ),
                                ),
                                onPressed: authViewModel.isLoading ? null : () async {
                                  if (_formKey.currentState!.validate()) {
                                    final success = await authViewModel.login(
                                      _emailController.text.trim(),
                                      _passwordController.text,
                                    );

                                    if (success && mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Login successful!"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(builder: (context) => const Navigpage()),
                                            (route) => false,
                                      );
                                    } else if (!success && mounted) {
                                      // Only show snackbar if there are no field-specific errors
                                      if (authViewModel.fieldErrors.isEmpty && authViewModel.error.isNotEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(authViewModel.error),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                                child: Text(
                                  authViewModel.isLoading ? "Signing In..." : "Sign In",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      AppSpacing.large,
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[300])),
                          Padding(
                            padding: AppSpacing.screenPaddingHorizontal,
                            child: Text(
                              "or",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[300])),
                        ],
                      ),
                      AppSpacing.medium,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          AppSpacing.hSmall,
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Registerpage()),
                              );
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.robinEggBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

