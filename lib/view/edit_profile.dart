import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/model/user_profile_model.dart';
import 'package:uptrail/services/user_profile_service.dart';
import 'package:uptrail/utils/app_text_style.dart';
import 'package:uptrail/utils/app_spacing.dart';
import 'package:uptrail/utils/app_decoration.dart';
import 'package:uptrail/utils/customtextformfiled.dart';
import 'package:uptrail/view_model/auth_viewModel.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  
  final _userProfileService = UserProfileService();
  bool _isLoading = false;
  bool _hasChanges = false;
  UserProfileFormData? _formData;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final user = authViewModel.user;
    
    if (user != null) {
      _formData = UserProfileFormData.fromUser(user);
      _nameController.text = _formData!.name;
      _phoneNumberController.text = _formData!.phoneNumber;
      _addressController.text = _formData!.address;
      
      // Add listeners to detect changes
      _nameController.addListener(_onFieldChanged);
      _phoneNumberController.addListener(_onFieldChanged);
      _addressController.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() {
    final hasChanges = _nameController.text != _formData?.name ||
                      _phoneNumberController.text != _formData?.phoneNumber ||
                      _addressController.text != _formData?.address;
    
    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
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
              AppColors.champagnePink.withValues(alpha: 0.8),
              AppColors.brightPinkCrayola.withValues(alpha: 0.9),

            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Edit Profile', style: AppTextStyle.bodyText),
            iconTheme: const IconThemeData(color: Colors.black),
            actions: [
              if (_hasChanges)
                TextButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
            ],
          ),
          body: Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              final user = authViewModel.user;
              
              if (user == null) {
                return const Center(
                  child: Text(
                    'No user data available',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return SafeArea(
                child: SingleChildScrollView(
                  padding: AppSpacing.screenPadding,
                  child: Container(
                    width: double.infinity,
                    padding: AppSpacing.paddingXL,
                    decoration: AppDecoration.elevatedCardDecoration,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Profile Avatar
                          Center(
                            child: Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.brightPinkCrayola,
                                        AppColors.coral,
                                      ],
                                    ),
                                    boxShadow: AppDecoration.softShadow,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _getUserInitials(user.name ?? "U"),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.robinEggBlue,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          AppSpacing.large,
                          
                          Text(
                            'Edit Your Profile',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.background,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const Text(
                            'Update your personal information',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          AppSpacing.large,

                          // Form Fields
                          CustomTextFormField(
                            controller: _nameController,
                            hintText: 'Full Name',
                            prefixIcon: Icon(Icons.person, color: AppColors.robinEggBlue),
                            validator: (value) => UserProfileFormData(name: value ?? '').validateName(),
                          ),
                          
                          AppSpacing.medium,
                          
                          CustomTextFormField(
                            controller: _phoneNumberController,
                            hintText: 'Phone Number',
                            type: TextInputType.phone,
                            prefixIcon: Icon(Icons.phone, color: AppColors.robinEggBlue),
                            validator: (value) => UserProfileFormData(phoneNumber: value ?? '').validatePhoneNumber(),
                          ),
                          
                          AppSpacing.medium,
                          
                          CustomTextFormField(
                            controller: _addressController,
                            hintText: 'Address',
                            maxlines: 3,
                            prefixIcon: Icon(Icons.location_on, color: AppColors.robinEggBlue),
                            validator: (value) => UserProfileFormData(address: value ?? '').validateAddress(),
                          ),

                          AppSpacing.large,

                          // Action Buttons
                          _buildActionButtons(),
                          
                          // Add bottom padding
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
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
              foregroundColor: AppColors.background,
              side: BorderSide(color: AppColors.background.withValues(alpha: 0.3)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        AppSpacing.hMedium,
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading || !_hasChanges ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brightPinkCrayola,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
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
                : const Text('Save Changes'),
          ),
        ),
      ],
    );
  }


  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updateRequest = UserProfileUpdateRequest(
        name: _nameController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim().isNotEmpty ? _phoneNumberController.text.trim() : null,
        address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
      );

      final updatedUser = await _userProfileService.updateUserProfile(
        name: updateRequest.name,
        phoneNumber: updateRequest.phoneNumber,
        address: updateRequest.address,
      );

      if (updatedUser != null) {
        // Update the user in AuthViewModel
        final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
        authViewModel.updateUser(updatedUser);

        // Reset change tracking
        _formData = UserProfileFormData.fromUser(updatedUser);
        setState(() {
          _hasChanges = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update profile. Please try again.'),
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

  String _getUserInitials(String name) {
    if (name.isEmpty) return "U";
    List<String> nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return "${nameParts[0][0]}${nameParts[1][0]}".toUpperCase();
    }
    return name[0].toUpperCase();
  }
}