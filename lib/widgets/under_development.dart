import 'package:flutter/material.dart';

import '../utils/contants.dart';

class UnderDevelopmentScreen extends StatelessWidget {
  final String screenName;

  const UnderDevelopmentScreen({
    super.key,
    this.screenName =
        '', // Optional screen name to show which feature is under development
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          screenName.isNotEmpty ? screenName : 'Under Development',
          style: const TextStyle(fontFamily: 'Lexend'),
        ),
        backgroundColor: AppColors.accent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Construction Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.construction,
                size: 80,
                color: Colors.amber[700],
              ),
            ),
            const SizedBox(height: 40),

            // Main Message
            Text(
              'Under Development',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Detailed Message
            Text(
              screenName.isNotEmpty
                  ? 'The $screenName feature is currently under development and will be available soon.'
                  : 'This feature is currently under development and will be available soon.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Progress Indicator
            SizedBox(
              width: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: null, // Indeterminate progress
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                  minHeight: 8,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Return Button
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
