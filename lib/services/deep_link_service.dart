import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/test/salon_details_scrolling_tabs_effect_b.dart';
import 'package:app/features/home/presentation/screens/service_detail_screen.dart';
import 'package:app/features/home/presentation/screens/deals_list_screen.dart';

class DeepLinkService {
  static final _appLinks = AppLinks();
  static GlobalKey<NavigatorState>? _navigatorKey;
  static Uri? _pendingLink;
  static StreamSubscription<Uri>? _subscription;

  static Future<void> initialize(GlobalKey<NavigatorState> navKey) async {
    _navigatorKey = navKey;

    // Cold-start link (app was opened via deep link while killed)
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        _pendingLink = initial;
      }
    } catch (_) {}

    // While-running link (app is open/background and receives a deep link)
    _subscription = _appLinks.uriLinkStream.listen(_handleUri, onError: (_) {});
  }

  /// Call this from your home/main screen after the UI is fully ready.
  static void handlePendingLink() {
    if (_pendingLink != null) {
      final uri = _pendingLink!;
      _pendingLink = null;
      _handleUri(uri);
    }
  }

  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }

  static void _handleUri(Uri uri) {
    final navigator = _navigatorKey?.currentState;
    if (navigator == null) {
      // App not ready yet — keep as pending, caller must retry
      _pendingLink = uri;
      return;
    }

    // Supported URL patterns:
    //   https://bms.innovativewidget.com/go/salon/29
    //   https://bms.innovativewidget.com/go/service/29
    //   https://bms.innovativewidget.com/go/deal/29
    //   bookmyspot://go/salon/29  (custom scheme, for testing)
    final segments = uri.pathSegments;

    // Find the type segment ('salon', 'service', 'deal')
    int typeIndex = -1;
    for (int i = 0; i < segments.length; i++) {
      if (segments[i] == 'salon' ||
          segments[i] == 'service' ||
          segments[i] == 'deal') {
        typeIndex = i;
        break;
      }
    }

    if (typeIndex == -1 || typeIndex + 1 >= segments.length) return;

    final type = segments[typeIndex];
    final id = int.tryParse(segments[typeIndex + 1]);
    if (id == null) return;

    _navigateTo(navigator, type, id);
  }

  static void _navigateTo(NavigatorState navigator, String type, int id) {
    switch (type) {
      case 'salon':
        navigator.push(MaterialPageRoute(
          builder: (_) => const SalonDetailsScrollingTabsEffectB(),
          settings: RouteSettings(arguments: '$id'),
        ));
        break;

      case 'service':
        navigator.push(MaterialPageRoute(
          builder: (_) => ServiceDetailScreen(serviceId: id),
        ));
        break;

      case 'deal':
        navigator.push(MaterialPageRoute(
          builder: (_) => DealsListScreen(initialDealId: id),
        ));
        break;
    }
  }
}
