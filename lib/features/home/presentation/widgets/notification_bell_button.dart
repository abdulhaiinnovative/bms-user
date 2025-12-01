import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:app/constants.dart';
import 'package:app/features/notifications/presentation/viewmodels/notifications_view_model.dart';
import 'package:app/features/notifications/presentation/screens/notifications_screen.dart';

class NotificationBellButton extends StatefulWidget {
  const NotificationBellButton({Key? key}) : super(key: key);

  @override
  State<NotificationBellButton> createState() => _NotificationBellButtonState();
}

class _NotificationBellButtonState extends State<NotificationBellButton> {
  @override
  void initState() {
    super.initState();
    // Load unread count when widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationsViewModel>(context, listen: false)
          .loadUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationsViewModel>(
      builder: (context, notificationProvider, child) {
        final unreadCount = notificationProvider.unreadCount;

        return InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: () async {
            // Capture provider reference before async gap
            final viewModel =
                Provider.of<NotificationsViewModel>(context, listen: false);

            await Navigator.pushNamed(context, NotificationsScreen.routeName);

            // Refresh unread count when returning from notifications screen
            if (mounted) {
              viewModel.loadUnreadCount();
            }
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: kSecondaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  "assets/icons/Bell.svg",
                  colorFilter: const ColorFilter.mode(
                    kTextColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    height: 18,
                    constraints: const BoxConstraints(minWidth: 18),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4848),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
