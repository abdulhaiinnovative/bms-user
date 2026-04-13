import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/profile/presentation/viewmodels/profile_view_model.dart';

/// A banner that displays at the top of the screen when user is inactive
/// Shows throughout the app to remind users about their inactive status
class InactiveUserBanner extends StatelessWidget {
  const InactiveUserBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        // Only show banner if user data is loaded and user is inactive
        if (!viewModel.hasProfileData || viewModel.isActive) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            border: Border(
              bottom: BorderSide(
                color: Colors.orange.shade200,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Inactive',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.orange.shade900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Your account is currently inactive. Please contact support.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.shade800,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.info_outline,
                color: Colors.orange.shade600,
                size: 18,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A widget that wraps content with the inactive user banner
/// Use this to add the banner to any screen
class InactiveUserBannerWrapper extends StatelessWidget {
  final Widget child;

  const InactiveUserBannerWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const InactiveUserBanner(),
        Expanded(child: child),
      ],
    );
  }
}
