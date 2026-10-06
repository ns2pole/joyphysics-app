import 'package:flutter/material.dart';
import 'package:joyphysics/l10n/app_localizations.dart';

class AboutView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutApp)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(l10n.aboutBody, style: const TextStyle(fontSize: 17)),
      ),
    );
  }
}
