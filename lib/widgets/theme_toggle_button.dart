import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/theme_service.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return IconButton(
          icon: Icon(themeProvider.currentThemeIcon),
          tooltip: themeProvider.currentThemeName,
          onPressed: () => themeProvider.toggleTheme(),
        );
      },
    );
  }
}

class ThemeSelectionDialog extends StatelessWidget {
  const ThemeSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return AlertDialog(
          title: const Text('選擇主題'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ThemeService.instance.availableThemes.map((themeMode) {
              final isSelected = themeProvider.themeMode == themeMode;
              return ListTile(
                leading: Icon(
                  ThemeService.instance.getThemeIcon(themeMode),
                  color: isSelected ? Theme.of(context).colorScheme.primary : null,
                ),
                title: Text(
                  ThemeService.instance.getThemeDisplayName(themeMode),
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Theme.of(context).colorScheme.primary : null,
                  ),
                ),
                trailing: isSelected
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
                onTap: () {
                  themeProvider.setThemeMode(themeMode);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }
}

class ThemeToggleListTile extends StatelessWidget {
  const ThemeToggleListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ListTile(
          leading: Icon(themeProvider.currentThemeIcon),
          title: const Text('主題設定'),
          subtitle: Text(themeProvider.currentThemeName),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const ThemeSelectionDialog(),
            );
          },
        );
      },
    );
  }
}