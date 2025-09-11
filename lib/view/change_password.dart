import 'package:flutter/material.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/model/user_profile_model.dart';
import 'package:uptrail/services/user_profile_service.dart';
import 'package:uptrail/utils/app_text_style.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final _userProfileService = UserProfileService();
  bool _isLoading = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Change Password', style: AppTextStyle.headline2),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Security Info Card
              _buildSecurityInfoCard(),
              const SizedBox(height: 24),

              // Password Form
              _buildPasswordForm(),
              const SizedBox(height: 32),

              // Action Buttons
              _buildActionButtons(),
              const SizedBox(height: 16),

              // Password Requirements
              _buildPasswordRequirements(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.robinEggBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.robinEggBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security,
            color: AppColors.robinEggBlue,
            size: 32,
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure Your Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Choose a strong password to keep your account safe.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildPasswordField(
            controller: _currentPasswordController,
            label: 'Current Password',
            icon: Icons.lock_outline,
            showPassword: _showCurrentPassword,
            onToggleVisibility: () => setState(() => _showCurrentPassword = !_showCurrentPassword),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Current password is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildPasswordField(
            controller: _newPasswordController,
            label: 'New Password',
            icon: Icons.lock,
            showPassword: _showNewPassword,
            onToggleVisibility: () => setState(() => _showNewPassword = !_showNewPassword),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'New password is required';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              if (!_isPasswordStrong(value)) {
                return 'Password must contain uppercase, lowercase, and number';
              }
              if (value == _currentPasswordController.text) {
                return 'New password must be different from current password';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildPasswordField(
            controller: _confirmPasswordController,
            label: 'Confirm New Password',
            icon: Icons.lock_reset,
            showPassword: _showConfirmPassword,
            onToggleVisibility: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your new password';
              }
              if (value != _newPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool showPassword,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !showPassword,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: AppColors.robinEggBlue),
        suffixIcon: IconButton(
          icon: Icon(
            showPassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.white54,
          ),
          onPressed: onToggleVisibility,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.robinEggBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: const BorderSide(color: Colors.white30),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _changePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.robinEggBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Change Password'),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    final newPassword = _newPasswordController.text;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Password Requirements:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildRequirementItem(
            'At least 8 characters',
            newPassword.length >= 8,
          ),
          _buildRequirementItem(
            'Contains uppercase letter (A-Z)',
            newPassword.contains(RegExp(r'[A-Z]')),
          ),
          _buildRequirementItem(
            'Contains lowercase letter (a-z)',
            newPassword.contains(RegExp(r'[a-z]')),
          ),
          _buildRequirementItem(
            'Contains number (0-9)',
            newPassword.contains(RegExp(r'[0-9]')),
          ),
          if (_currentPasswordController.text.isNotEmpty && _newPasswordController.text.isNotEmpty)
            _buildRequirementItem(
              'Different from current password',
              _newPasswordController.text != _currentPasswordController.text,
            ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String requirement, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            color: isValid ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            requirement,
            style: TextStyle(
              color: isValid ? Colors.white70 : Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  bool _isPasswordStrong(String password) {
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasNumber = password.contains(RegExp(r'[0-9]'));
    
    return hasUppercase && hasLowercase && hasNumber;
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _userProfileService.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmNewPassword: _confirmPasswordController.text,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password changed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to change password. Please check your current password.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}