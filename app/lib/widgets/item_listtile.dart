import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/models/item.dart';
import 'package:librairian/providers/item.dart';

class ItemListTile extends ConsumerWidget {
  const ItemListTile({
    super.key,
    required this.item,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.isThreeLine = false,
    this.dense,
    this.enabled = true,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.selectedTileColor,
    this.tileColor,
    this.contentPadding,
    this.shape,
    this.hoverColor,
    this.focusColor,
    this.focusNode,
    this.autofocus = false,
    this.mouseCursor,
    this.visualDensity,
    this.selectedShape,
  });

  final Item item;
  final Widget? trailing;
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final bool? isThreeLine;
  final bool? dense;
  final bool? enabled;
  final GestureTapCallback? onTap;
  final GestureLongPressCallback? onLongPress;
  final bool? selected;
  final Color? selectedTileColor;
  final Color? tileColor;
  final EdgeInsetsGeometry? contentPadding;
  final ShapeBorder? shape;
  final Color? hoverColor;
  final Color? focusColor;
  final FocusNode? focusNode;
  final bool? autofocus;
  final MouseCursor? mouseCursor;
  final VisualDensity? visualDensity;
  final ShapeBorder? selectedShape;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(itemControllerProvider(item.id));
    return ListTile(
      title: Text(item.name),
      subtitle: Text(item.description),
      leading: leading,
      trailing: trailing,
      isThreeLine: isThreeLine ?? false,
      dense: dense ?? true,
      enabled: enabled!,
      onTap: onTap,
      onLongPress: onLongPress,
      selected: selected!,
      selectedTileColor:
          selectedTileColor ?? Theme.of(context).colorScheme.surfaceDim,
      tileColor: tileColor,
      contentPadding: contentPadding,
      shape: shape,
      hoverColor: hoverColor,
      focusColor: focusColor,
      focusNode: focusNode,
      autofocus: autofocus!,
      mouseCursor: mouseCursor,
      visualDensity: visualDensity,
      selectedColor: Theme.of(context).colorScheme.onSurface,
    );
  }
}
