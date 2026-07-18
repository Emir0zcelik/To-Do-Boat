import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:ancyra_sailing/l10n/app_translations.dart';
import 'package:ancyra_sailing/utils/appstyles.dart';

class EditableDropdown extends StatelessWidget {
  const EditableDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.selectedIndex,
    required this.lockedCount,
    required this.onChanged,
    required this.onAddNew,
    required this.onDelete,
    this.allowAdd = true,
    this.allowDelete = true,
    this.icon,
  });

  final String label;
  final List<String> items;
  final int selectedIndex;
  final int lockedCount;

  final void Function(int index) onChanged;
  final VoidCallback onAddNew;
  final void Function(int index) onDelete;
  final bool allowAdd;
  final bool allowDelete;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Appstyles.lightBlue, width: 2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: Appstyles.oceanGradient,
                  borderRadius: BorderRadius.circular(Appstyles.borderRadiusSmall),
                ),
                child: Icon(
                  icon ?? Icons.directions_boat,
                  color: Appstyles.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: Appstyles.headingTextStyle.copyWith(
                  color: Appstyles.primaryBlue,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Container(
          decoration: BoxDecoration(
            color: Appstyles.white,
            borderRadius: BorderRadius.circular(Appstyles.borderRadiusSmall),
            border: Border.all(color: Appstyles.lightBlue, width: 1.5),
            boxShadow: Appstyles.softShadow,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton2<int>(
              isExpanded: true,
              value: (items.isNotEmpty &&
                      selectedIndex >= 0 &&
                      selectedIndex < items.length)
                  ? selectedIndex
                  : null,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  items.isEmpty
                      ? AppTranslations.t(context, 'noItemsYet')
                      : AppTranslations.t(context, 'selectOption'),
                  style: Appstyles.normalTextStyle
                      .copyWith(color: Appstyles.textLight),
                ),
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: 300,
                decoration: BoxDecoration(
                  color: Appstyles.white,
                  borderRadius: BorderRadius.circular(Appstyles.borderRadiusSmall),
                  boxShadow: Appstyles.mediumShadow,
                ),
              ),
              iconStyleData: IconStyleData(
                icon: const Icon(Icons.keyboard_arrow_down, color: Appstyles.primaryBlue),
              ),
              style: Appstyles.normalTextStyle.copyWith(color: Appstyles.textDark),
              items: [
                for (int i = 0; i < items.length; i++)
                  DropdownMenuItem(
                    value: i,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        items[i],
                        style: Appstyles.normalTextStyle.copyWith(color: Appstyles.textDark),
                      ),
                    ),
                  ),

                if (allowAdd)
                  DropdownMenuItem(
                    value: -1,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Appstyles.secondaryBlue, Appstyles.primaryBlue],
                        ),
                        borderRadius: BorderRadius.circular(Appstyles.borderRadiusSmall),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.add, color: Appstyles.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              AppTranslations.t(context, 'addNewItem'),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Appstyles.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (allowDelete &&
                    items.isNotEmpty &&
                    selectedIndex >= lockedCount &&
                    selectedIndex < items.length)
                  DropdownMenuItem(
                    value: -2,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(Appstyles.borderRadiusSmall),
                        border: Border.all(color: Colors.red.shade300, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.delete, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              AppTranslations.t(context, 'deleteSelected'),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
              onChanged: (value) {
                if (value == -1) {
                  onAddNew();
                } else if (value == -2) {
                  onDelete(selectedIndex);
                } else {
                  onChanged(value!);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
