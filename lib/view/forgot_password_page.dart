import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/services/auth_service.dart';
import 'package:uptrail/utils/customtextformfiled.dart';
import 'package:uptrail/utils/app_spacing.dart';
import 'package:uptrail/utils/responsive_helper.dart';

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.green1.withValues(alpha: 0.8),
              AppColors.green2.withValues(alpha: 0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: ResponsiveHelper.getScreenPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  
                  AppSpacing.veryLarge,
                  
                  // Logo
                  SvgPicture.asset(
                    'assets/logo/logo_white.svg',
                    height: 80,
                    width: 80,
                  ),
                  
                  AppSpacing.large,
                  
                  // Title and subtitle
                  Text(
                    _emailSent ? 'Check Your Email' : 'Forgot Password?',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  AppSpacing.small,
                  
                  Text(
                    _emailSent 
                        ? 'We\'ve sent a password reset link to your email address.'
                        : 'Enter your email address and we\'ll send you a link to reset your password.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.4,
                    ),
                  ),
                  
                  AppSpacing.veryLarge,
                  
                  if (!_emailSent) ...[
                    // Email form
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Email field
                            CustomTextFormField(
                              controller: _emailController,
                              hintText: "Enter your email",
                              type: TextInputType.emailAddress,
                              prefixIcon: const Icon(Icons.email_outlined),
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
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _requestPasswordReset,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.logoBrightBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        "Send Reset Link",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Email sent confirmation
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.mail_outline,
                              size: 40,
                              color: Colors.green[600],
                            ),
                          ),
                          
                          AppSpacing.medium,
                          
                          Text(
                            'Email Sent Successfully!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          
                          AppSpacing.small,
                          
                          Text(
                            'Please check your email (${_emailController.text}) and click on the reset link to create a new password.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                          ),
                          
                          AppSpacing.medium,
                          
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.logoBrightBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Back to Login",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
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
                                color: AppColors.logoBrightBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  AppSpacing.veryLarge,
                  
                  // Back to login link
                  if (!_emailSent)
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        "Remember your password? Sign in",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}