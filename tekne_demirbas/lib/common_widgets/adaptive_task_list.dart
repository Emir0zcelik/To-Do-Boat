import 'package:flutter/material.dart';
import 'package:ancyra_sailing/utils/size_config.dart';

/// Görev / oda listelerini telefonda tek sütun, tablette iki sütun gösterir.
class AdaptiveTaskList extends StatelessWidget {
  const AdaptiveTaskList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.empty,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry padding;
  final Widget? empty;

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) {
      return empty ?? const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= SizeConfig.tabletBreakpoint;

        if (wide) {
          return ResponsiveCenter(
            maxWidth: SizeConfig.wideContentMaxWidth,
            child: GridView.builder(
              padding: padding,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 120,
                crossAxisSpacing: 12,
                mainAxisSpacing: 8,
              ),
              itemCount: itemCount,
              itemBuilder: itemBuilder,
            ),
          );
        }

        return ResponsiveCenter(
          maxWidth: SizeConfig.contentMaxWidth,
          child: ListView.separated(
            padding: padding,
            itemCount: itemCount,
            separatorBuilder: (_, __) =>
                const Divider(height: 2, color: Colors.blue),
            itemBuilder: itemBuilder,
          ),
        );
      },
    );
  }
}
