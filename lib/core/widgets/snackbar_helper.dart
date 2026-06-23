import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showSuccessSnackBar(BuildContext context, String message) {
  _showStyled(context, message, const Color(0xFFC8F135), Colors.black);
}

void showErrorSnackBar(BuildContext context, String message) {
  _showStyled(context, message, const Color(0xFFFF4D6D), Colors.white);
}

void _showStyled(BuildContext context, String message, Color bg, Color fg, {bool isSuccess = true}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: fg,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.zenDots(
                  fontSize: 12,
                  color: fg,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 3),
      ),
    );
}
