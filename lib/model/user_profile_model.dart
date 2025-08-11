class UserProfileUpdateRequest {
  final String? name;
  final String? phoneNumber;
  final String? address;

  UserProfileUpdateRequest({
    this.name,
    this.phoneNumber,
    this.address,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (phoneNumber != null) data['phone_number'] = phoneNumber;
    if (address != null) data['address'] = address;
    return data;
  }
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'old_password': currentPassword,
      'new_password': newPassword,
      'new_password_confirm': confirmPassword,
    };
  }

  // Validation methods
  bool get isValid {
    return currentPassword.isNotEmpty &&
           newPassword.isNotEmpty &&
           confirmPassword.isNotEmpty &&
           newPassword == confirmPassword &&
           _isPasswordStrong(newPassword);
  }

  String? get validationError {
    if (currentPassword.isEmpty) {
      return 'Current password is required';
    }
    if (newPassword.isEmpty) {
      return 'New password is required';
    }
    if (confirmPassword.isEmpty) {
      return 'Please confirm your new password';
    }
    if (newPassword != confirmPassword) {
      return 'New passwords do not match';
    }
    if (!_isPasswordStrong(newPassword)) {
      return 'Password must be at least 8 characters with uppercase, lowercase, and number';
    }
    if (currentPassword == newPassword) {
      return 'New password must be different from current password';
    }
    return null;
  }

  bool _isPasswordStrong(String password) {
    if (password.length < 8) return false;
    
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasNumber = password.contains(RegExp(r'[0-9]'));
    
    return hasUppercase && hasLowercase && hasNumber;
  }
}

class UserProfileFormData {
  String name;
  String phoneNumber;
  String address;

  UserProfileFormData({
    this.name = '',
    this.phoneNumber = '',
    this.address = '',
  });

  UserProfileFormData.fromUser(dynamic user) :
    name = user.name ?? '',
    phoneNumber = user.phoneNumber ?? user.phone_number ?? '',
    address = user.address ?? '';

  bool get hasChanges => name.isNotEmpty || phoneNumber.isNotEmpty || address.isNotEmpty;

  UserProfileUpdateRequest toUpdateRequest() {
    return UserProfileUpdateRequest(
      name: name.trim().isNotEmpty ? name.trim() : null,
      phoneNumber: phoneNumber.trim().isNotEmpty ? phoneNumber.trim() : null,
      address: address.trim().isNotEmpty ? address.trim() : null,
    );
  }

  // Validation
  String? validateName() {
    if (name.trim().isEmpty) {
      return 'Name is required';
    }
    if (name.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  String? validatePhoneNumber() {
    if (phoneNumber.trim().isEmpty) {
      return null; // Phone is optional
    }
    if (phoneNumber.trim().length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    if (!RegExp(r'^[\+]?[\d\s\-\(\)]+$').hasMatch(phoneNumber.trim())) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? validateAddress() {
    if (address.trim().isNotEmpty && address.trim().length > 200) {
      return 'Address must be less than 200 characters';
    }
    return null;
  }

  bool get isValid {
    return validateName() == null &&
           validatePhoneNumber() == null &&
           validateAddress() == null;
  }
}