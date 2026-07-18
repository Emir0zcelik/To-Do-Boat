import 'package:flutter/material.dart';
import 'package:ancyra_sailing/l10n/app_translations.dart';
import 'package:ancyra_sailing/utils/appstyles.dart';

Future<String?> showAddItemDialog({
  required BuildContext context,
  required String title,
  required String hint,
}) {
  final controller = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Appstyles.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Appstyles.borderRadiusMedium),
        ),
        title: Text(
          title,
          style: Appstyles.titleTextStyle.copyWith(color: Appstyles.textDark),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: Appstyles.normalTextStyle.copyWith(color: Appstyles.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                Appstyles.normalTextStyle.copyWith(color: Appstyles.textLight),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(Appstyles.borderRadiusSmall),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text(AppTranslations.t(context, 'cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Appstyles.primaryBlue,
              foregroundColor: Appstyles.white,
            ),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(context, text);
              }
            },
            child: Text(AppTranslations.t(context, 'add')),
          ),
        ],
      );
    },
  );
}
