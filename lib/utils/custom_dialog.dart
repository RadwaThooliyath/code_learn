// lib/shared/widgets/custom_dialog.dart

import 'package:flutter/material.dart';
import '../app_constants/colors.dart';
import './apptext.dart';

enum DialogType {
  logout,
  success,
  warning,
  error,
  authError
}

class CustomDialog extends StatelessWidget {
  final DialogType type;
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const CustomDialog({
    Key? key,
    required this.type,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
  }) : super(key: key);

  factory CustomDialog.logout({
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    return CustomDialog(
      type: DialogType.logout,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      cancelText: 'Cancel',
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }

  factory CustomDialog.success({
    required String title,
    required String message,
    String? confirmText,
    VoidCallback? onConfirm,
  }) {
    return CustomDialog(
      type: DialogType.success,
      title: title,
      message: message,
      confirmText: confirmText ?? 'OK',
      onConfirm: onConfirm,
    );
  }

  factory CustomDialog.warning({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    return CustomDialog(
      type: DialogType.warning,
      title: title,
      message: message,
      confirmText: 'Proceed',
      cancelText: 'Cancel',
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }

  factory CustomDialog.error({
    required String title,
    required String message,
    String? confirmText,
    VoidCallback? onConfirm,
  }) {
    return CustomDialog(
      type: DialogType.error,
      title: title,
      message: message,
      confirmText: confirmText ?? 'OK',
      onConfirm: onConfirm,
    );
  }

  factory CustomDialog.authError({
    required String message,
    required VoidCallback onConfirm,
  }) {
    return CustomDialog(
      type: DialogType.authError,
      title: 'Authentication Error',
      message: message,
      confirmText: 'Login Again',
      onConfirm: onConfirm,
    );
  }

  IconData _getIcon() {
    switch (type) {
      case DialogType.logout:
        return Icons.logout_rounded;
      case DialogType.success:
        return Icons.check_circle_outline_rounded;
      case DialogType.warning:
        return Icons.warning_amber_rounded;
      case DialogType.error:
        return Icons.error_outline_rounded;
      case DialogType.authError:
        return Icons.lock_outline_rounded;
    }
  }

  Color _getIconColor() {
    switch (type) {
      case DialogType.logout:
        return Colors.blue;
      case DialogType.success:
        return Colors.green;
      case DialogType.warning:
        return Colors.orange;
      case DialogType.error:
      case DialogType.authError:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.brightPinkCrayola,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            color: _getIconColor(),
            size: 48,
          ),
          const SizedBox(height: 16),
          AppText(
            data: title,
            color: Colors.white,
            size: 18,
            fw: FontWeight.bold,
          ),
          const SizedBox(height: 8),
          AppText(
            data: message,
            color: Colors.white70,
            size: 16,
            align: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: cancelText != null
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.center,
            children: [
              if (cancelText != null)
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                      onCancel?.call();
                    },
                    child: AppText(
                      data: cancelText!,
                      color: Colors.white54,
                      size: 16,
                    ),
                  ),
                ),
              if (cancelText != null)
                const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                    onConfirm?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getIconColor(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: AppText(
                      data: confirmText ?? 'OK',
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}