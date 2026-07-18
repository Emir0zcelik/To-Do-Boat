import 'package:flutter/material.dart';
import 'package:ancyra_sailing/l10n/app_translations.dart';
import 'package:ancyra_sailing/utils/appstyles.dart';

Future<bool> showConfirmDeleteDialog({
  required BuildContext context,
  required String itemName,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Appstyles.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Appstyles.borderRadiusMedium),
        ),
        title: Text(
          AppTranslations.t(context, 'areYouSure'),
          style: Appstyles.titleTextStyle.copyWith(color: Appstyles.textDark),
        ),
        content: Text(
          "'$itemName'",
          style: Appstyles.normalTextStyle.copyWith(color: Appstyles.textDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppTranslations.t(context, 'cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppTranslations.t(context, 'delete')),
          ),
        ],
      );
    },
  );

  return result == true;
}
