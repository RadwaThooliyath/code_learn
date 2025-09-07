import 'package:flutter/material.dart';
import 'package:uptrail/view/widgets/whatsapp_support_dialog.dart';

class WhatsAppSupportButton extends StatelessWidget {
  const WhatsAppSupportButton({super.key});

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const WhatsAppSupportDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 140, // Higher above bottom navigation
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF25D366), Color(0xFF128C7E)], // WhatsApp gradient
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF25D366).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: SizedBox(
          width: 52,
          height: 52,
          child: FloatingActionButton(
            onPressed: () => _showSupportDialog(context),
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: const Icon(
              Icons.chat,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}