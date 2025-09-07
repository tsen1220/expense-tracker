import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../models/language_preference.dart';
import '../l10n/app_localizations.dart';

class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return PopupMenuButton<AppLanguage>(
          icon: const Icon(Icons.language),
          tooltip: AppLocalizations.of(context)!.language,
          onSelected: (AppLanguage language) {
            languageProvider.setLanguage(language);
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<AppLanguage>(
              value: AppLanguage.english,
              child: Row(
                children: [
                  Radio<AppLanguage>(
                    value: AppLanguage.english,
                    groupValue: languageProvider.currentLanguage,
                    onChanged: null,
                  ),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.english),
                ],
              ),
            ),
            PopupMenuItem<AppLanguage>(
              value: AppLanguage.traditionalChinese,
              child: Row(
                children: [
                  Radio<AppLanguage>(
                    value: AppLanguage.traditionalChinese,
                    groupValue: languageProvider.currentLanguage,
                    onChanged: null,
                  ),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.traditionalChinese),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class LanguageToggleIconButton extends StatelessWidget {
  const LanguageToggleIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return IconButton(
          icon: const Icon(Icons.language),
          tooltip: AppLocalizations.of(context)!.language,
          onPressed: () {
            languageProvider.toggleLanguage();
          },
        );
      },
    );
  }
}

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.language,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  RadioListTile<AppLanguage>(
                    title: Text(AppLocalizations.of(context)!.english),
                    value: AppLanguage.english,
                    groupValue: languageProvider.currentLanguage,
                    onChanged: (AppLanguage? value) {
                      if (value != null) {
                        languageProvider.setLanguage(value);
                      }
                    },
                  ),
                  RadioListTile<AppLanguage>(
                    title: Text(AppLocalizations.of(context)!.traditionalChinese),
                    value: AppLanguage.traditionalChinese,
                    groupValue: languageProvider.currentLanguage,
                    onChanged: (AppLanguage? value) {
                      if (value != null) {
                        languageProvider.setLanguage(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}