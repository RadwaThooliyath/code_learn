import 'package:code_learn/app_constants/colors.dart';
import 'package:code_learn/utils/app_spacing.dart';
import 'package:code_learn/utils/app_decoration.dart';
import 'package:code_learn/utils/responsive_helper.dart';
import 'package:code_learn/view/loginPage.dart';
import 'package:code_learn/view_model/auth_viewModel.dart';
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

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.coral.withValues(alpha: 0.8),
              AppColors.brightPinkCrayola.withValues(alpha: 0.7),
              AppColors.champagnePink.withValues(alpha: 0.9),
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
                          color: AppColors.coral.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_add_outlined,
                          size: 48,
                          color: AppColors.coral,
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
                      TextFormField(
                        controller: nameController,
                        style: const TextStyle(
                          color: AppColors.background,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: AppDecoration.formFieldDecoration(
                          hintText: "Full Name",
                          prefixIcon: const Icon(Icons.person, color: Colors.grey),
                        ),
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Name is required' : null,
                      ),
                      AppSpacing.small,
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          color: AppColors.background,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: AppDecoration.formFieldDecoration(
                          hintText: "Email Address",
                          prefixIcon: const Icon(Icons.email, color: Colors.grey),
                        ),
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
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(
                          color: AppColors.background,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: AppDecoration.formFieldDecoration(
                          hintText: "Phone Number",
                          prefixIcon: const Icon(Icons.phone, color: Colors.grey),
                        ),
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
                      TextFormField(
                        controller: passwordController,
                        obscureText: !_passwordVisible,
                        style: const TextStyle(
                          color: AppColors.background,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: AppDecoration.formFieldDecoration(
                          hintText: "Password",
                          prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
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
                      TextFormField(
                        controller: confirmController,
                        obscureText: !_confirmPasswordVisible,
                        style: const TextStyle(
                          color: AppColors.background,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: AppDecoration.formFieldDecoration(
                          hintText: "Confirm Password",
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _confirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _confirmPasswordVisible = !_confirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value != passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      AppSpacing.large,
                      SizedBox(
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
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

                                await authViewModel.register(
                                  nameController.text,
                                  emailController.text,
                                  passwordController.text,
                                );

                                if (authViewModel.error.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Registration Successful"),
                                      backgroundColor: AppColors.robinEggBlue,
                                    ),
                                  );

                                  // Navigate to login or home page
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const Loginpage()),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Error: ${authViewModel.error}"),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text(
                              "Create Account",
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
                                    builder: (context) => const Loginpage()),
                              );
                            },
                            child: const Text(
                              "Sign In",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.coral,
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
