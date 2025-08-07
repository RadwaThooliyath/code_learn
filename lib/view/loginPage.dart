import 'package:code_learn/app_constants/colors.dart';
import 'package:code_learn/utils/customtextformfiled.dart';
import 'package:code_learn/utils/app_spacing.dart';
import 'package:code_learn/utils/app_decoration.dart';
import 'package:code_learn/utils/responsive_helper.dart';
import 'package:code_learn/view/navigPage.dart';
import 'package:code_learn/view/registerPage.dart';
import 'package:code_learn/view_model/auth_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {

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
              AppColors.robinEggBlue.withValues(alpha: 0.8),
              AppColors.champagnePink.withValues(alpha: 0.9),
              AppColors.coral.withValues(alpha: 0.7),
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
                        padding: AppSpacing.paddingM,
                        decoration: BoxDecoration(
                          color: AppColors.robinEggBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_outline,
                          size: 48,
                          color: AppColors.robinEggBlue,
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
                      AppSpacing.small,
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
                      AppSpacing.medium,
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
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
                      SizedBox(
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
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

                                await authViewModel.login(
                                  _emailController.text.trim(),
                                  _passwordController.text,
                                );

                                if (authViewModel.error.isEmpty && authViewModel.user != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Login successful"),
                                      backgroundColor: AppColors.robinEggBlue,
                                    ),
                                  );
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => const Navigpage()),
                                        (route) => false,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Login failed: ${authViewModel.error}"),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              }
                            },

                            child: const Text(
                              "Sign In",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
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
                              Navigator.push(
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
