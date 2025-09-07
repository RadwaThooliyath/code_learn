import 'package:flutter_svg/svg.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/utils/app_spacing.dart';
import 'package:uptrail/utils/app_decoration.dart';
import 'package:uptrail/utils/responsive_helper.dart';
import 'package:uptrail/utils/customtextformfiled.dart';
import 'package:uptrail/view/loginPage.dart';
import 'package:uptrail/view_model/auth_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Registerpage extends StatefulWidget {
  const Registerpage({super.key});

  @override
  State<Registerpage> createState() => _RegisterpageState();
}

class _RegisterpageState extends State<Registerpage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.green2.withValues(alpha: 0.8),
              AppColors.green1.withValues(alpha: 0.7),
              AppColors.logoDarkTeal.withValues(alpha: 0.9),
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
                        "Create Account",
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getHeadingSize(context),
                          fontWeight: FontWeight.bold,
                          color: AppColors.background,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        "Join us today!",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      AppSpacing.large,
                      CustomTextFormField(
                        controller: nameController,
                        hintText: "Full Name",
                        prefixIcon: const Icon(Icons.person, color: Colors.grey),
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Name is required' : null,
                      ),
                      AppSpacing.small,
                      CustomTextFormField(
                        controller: emailController,
                        hintText: "Email Address",
                        type: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email, color: Colors.grey),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$')
                              .hasMatch(value)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      AppSpacing.small,
                      CustomTextFormField(
                        controller: phoneController,
                        hintText: "Phone Number",
                        type: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone, color: Colors.grey),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone number is required';
                          } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                            return 'Enter a valid 10-digit phone number';
                          }
                          return null;
                        },
                      ),
                      AppSpacing.small,
                      CustomTextFormField(
                        controller: addressController,
                        hintText: "Address (Optional)",
                        prefixIcon: const Icon(Icons.location_on, color: Colors.grey),
                        maxlines: 2,
                      ),
                      AppSpacing.small,
                      CustomTextFormField(
                        controller: passwordController,
                        hintText: "Password",
                        obscureText: true,
                        prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          } else if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      AppSpacing.small,
                      CustomTextFormField(
                        controller: confirmController,
                        hintText: "Confirm Password",
                        obscureText: true,
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                        validator: (value) {
                          if (value != passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      AppSpacing.large,
                      Consumer<AuthViewModel>(
                        builder: (context, authViewModel, child) {
                          return SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: Container(
                              decoration: AppDecoration.accentGradientDecoration,
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
                                    final success = await authViewModel.register(
                                      name: nameController.text.trim(),
                                      email: emailController.text.trim(),
                                      password: passwordController.text,
                                      passwordConfirm: confirmController.text,
                                      phoneNumber: phoneController.text.trim(),
                                      address: addressController.text.trim(),
                                    );
                                    
                                    if (success && mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Registration Successful!"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const LoginPage(),
                                        ),
                                      );
                                    } else if (authViewModel.error.isNotEmpty && mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(authViewModel.error),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: authViewModel.isLoading 
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    )
                                  : const Text(
                                      "Create Account",
                                      style: TextStyle(
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
                            "Already have an account?",
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
                                    builder: (context) => const LoginPage()),
                              );
                            },
                            child: const Text(
                              "Sign In",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.logoBrightBlue,
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
