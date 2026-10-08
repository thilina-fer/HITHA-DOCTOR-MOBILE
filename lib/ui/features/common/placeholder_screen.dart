import 'package:flutter/material.dart';

import '../../core/theme/hitha_theme.dart';
import '../../core/widgets/hitha_widgets.dart';

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    this.subtitle,
    this.badgeText = 'NEXT MODULE',
  });

  final String title;
  final String? subtitle;
  final String badgeText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HithaColors.cream,
      appBar: HithaAppBar(title: title),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(HithaSpacing.page),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: HithaCard(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const HithaLotus(size: 38, color: HithaColors.forest),
                    const SizedBox(height: 16),
                    HithaPill(
                      text: badgeText,
                      background: HithaColors.sprout,
                      foreground: HithaColors.moss,
                    ),
                    const SizedBox(height: 16),
                    Text(title, style: HithaText.h2, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(
                      subtitle ?? 'This module will be connected in the next implementation phase.',
                      style: HithaText.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
