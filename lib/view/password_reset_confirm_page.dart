import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/services/auth_service.dart';
import 'package:uptrail/utils/app_spacing.dart';
import 'package:uptrail/utils/responsive_helper.dart';
import 'package:uptrail/view/loginPage.dart';

class PasswordResetConfirmPage extends StatefulWidget {
  final String token;
  
  const PasswordResetConfirmPage({
    super.key,
    required this.token,
  });

  @override
  State<PasswordResetConfirmPage> createState() => _PasswordResetConfirmPageState();
}

class _PasswordResetConfirmPageState extends State<PasswordResetConfirmPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _passwordReset = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _confirmPasswordReset() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.confirmPasswordReset(
        token: widget.token,
        newPassword: _passwordController.text,
        newPasswordConfirm: _confirmPasswordController.text,
      );
      
      if (result['success']) {
        setState(() {
          _passwordReset = true;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Password reset failed. Please try again.';
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter, one lowercase letter, and one number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
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
                    _passwordReset ? 'Password Reset Successful!' : 'Set New Password',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  AppSpacing.small,
                  
                  Text(
                    _passwordReset 
                        ? 'Your password has been successfully reset. You can now sign in with your new password.'
                        : 'Create a strong password for your account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.4,
                    ),
                  ),
                  
                  AppSpacing.veryLarge,
                  
                  if (!_passwordReset) ...[
                    // Password reset form
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // New Password field
                            const Text(
                              'New Password',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            AppSpacing.verySmall,
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              validator: _validatePassword,
                              decoration: InputDecoration(
                                hintText: "Enter new password",
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: AppColors.logoBrightBlue,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            
                            AppSpacing.small,
                            
                            // Confirm Password field
                            const Text(
                              'Confirm New Password',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            AppSpacing.verySmall,
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              validator: _validateConfirmPassword,
                              decoration: InputDecoration(
                                hintText: "Confirm new password",
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: AppColors.logoBrightBlue,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            
                            AppSpacing.small,
                            
                            // Password requirements
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue[200]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.info_outline, color: Colors.blue[600], size: 16),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Password Requirements:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    '• At least 8 characters long\n• Contains uppercase and lowercase letters\n• Contains at least one number',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
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
                            
                            // Reset password button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _confirmPasswordReset,
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
                                        "Reset Password",
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
                    // Success confirmation
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
                              Icons.check_circle_outline,
                              size: 40,
                              color: Colors.green[600],
                            ),
                          ),
                          
                          AppSpacing.medium,
                          
                          Text(
                            'Password Reset Complete!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          
                          AppSpacing.small,
                          
                          const Text(
                            'Your password has been successfully updated. You can now sign in to your account with your new password.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
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
                              onPressed: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (context) => const LoginPage()),
                                  (route) => false,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.logoBrightBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Sign In Now",
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
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}