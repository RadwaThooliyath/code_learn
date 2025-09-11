import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/services/auth_service.dart';
import 'package:uptrail/utils/customtextformfiled.dart';
import 'package:uptrail/utils/app_spacing.dart';
import 'package:uptrail/utils/responsive_helper.dart';
import 'package:uptrail/utils/app_decoration.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestPasswordReset() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await _authService.requestPasswordReset(_emailController.text.trim());
      
      if (success) {
        setState(() {
          _emailSent = true;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to send reset email. Please check your email and try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 24,
          ),
        ),
      ),
      body: SafeArea(
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
                    // Logo
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

                    // Title and subtitle
                    Text(
                      _emailSent ? 'Check Your Email' : 'Forgot Password?',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getHeadingSize(context),
                        fontWeight: FontWeight.bold,
                        color: AppColors.background,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    Text(
                      _emailSent
                          ? 'We\'ve sent a password reset link to your email address.'
                          : 'Enter your email address and we\'ll send you a link to reset your password.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    AppSpacing.large,

                    if (!_emailSent) ...[
                      // Email field
                      CustomTextFormField(
                        controller: _emailController,
                        hintText: "Enter your email address",
                        type: TextInputType.emailAddress,
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Colors.grey[600],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),

                      AppSpacing.medium,

                      // Error message
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.small,
                      ],

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: Container(
                          decoration: AppDecoration.primaryGradientDecoration,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brightPinkCrayola,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            onPressed: _isLoading ? null : _requestPasswordReset,
                            child: Text(
                              _isLoading ? "Sending..." : "Send Reset Link",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Email sent confirmation
                      Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle_outline,
                          size: 40,
                          color: Colors.green[600],
                        ),
                      ),

                      Text(
                        'Email Sent Successfully!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      AppSpacing.small,

                      Text(
                        'Please check your email (${_emailController.text}) and click on the reset link to create a new password.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                      ),

                      AppSpacing.large,

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: Container(
                          decoration: AppDecoration.primaryGradientDecoration,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brightPinkCrayola,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              "Back to Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      AppSpacing.small,

                      TextButton(
                        onPressed: () {
                          setState(() {
                            _emailSent = false;
                            _errorMessage = null;
                          });
                        },
                        child: const Text(
                          "Didn't receive the email? Send again",
                          style: TextStyle(
                            color: AppColors.robinEggBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],

                    if (!_emailSent) ...[
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
                            "Remember your password?",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          AppSpacing.hSmall,
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Text(
                              "Sign In",
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}