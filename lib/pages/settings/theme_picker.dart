import 'package:flutter/material.dart';
import '../../app_theme.dart';
import 'package:flutter/cupertino.dart';

class ThemePicker extends StatefulWidget {
  final Map<ThemeMode, IconData> themeIcons = {
    ThemeMode.light: CupertinoIcons.sun_haze_fill,
    ThemeMode.dark: CupertinoIcons.moon_stars_fill,
    ThemeMode.system: CupertinoIcons.gear_alt_fill
  };
  ThemeMode themeMode;
  IconData get iconData => themeIcons[themeMode]!;
  ThemePicker({required this.themeMode});
  @override
  _ThemePickerState createState() => _ThemePickerState();
}

class _ThemePickerState extends State<ThemePicker> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () => setState(() {
              AppTheme.themeMode.update(widget.themeMode);
            }),
        icon: Icon(
          widget.iconData,
          color: AppTheme.themeMode.current == widget.themeMode
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
          size: 40,
        ));
  }
}
