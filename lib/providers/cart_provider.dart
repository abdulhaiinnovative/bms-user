import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:app/models/salon_detail_models.dart' as salon_models;
import 'package:app/models/HomePageResponse.dart' as home_models;

class CartProvider extends ChangeNotifier {
  final Map<dynamic, int> _items = {};

  // Salon information
  int? _salonId;
  String? _salonName;

  Map<dynamic, int> get items => _items;
  int get itemCount => _items.length;

  // Get total amount
  double get totalAmount {
    return _items.entries.fold(
      0.0,
      (sum, entry) => sum + (_getItemPrice(entry.key) * entry.value),
    );
  }

  // Check if cart has services
  bool get hasServices {
    return _items.keys.any((item) => _itemType(item) == _CartItemType.service);
  }

  // Check if cart has deals
  bool get hasDeals {
    return _items.keys.any((item) => _itemType(item) == _CartItemType.deal);
  }
  String? salonLogo;
  String? salonImage;

  // Get salon info
  int? get salonId => _salonId;
  String? get salonName => _salonName;

  // Set salon info
  void setSalonInfo(int? id, String? name) {
    _salonId = id;
    _salonName = name;

    notifyListeners();
  }

  // Get salon ID from an item (Service or Deal)
  int? _getItemSalonId(dynamic item) {
    if (item is salon_models.Service) return item.salonId;
    if (item is salon_models.Deal) return item.salonId;
    if (item is home_models.Service) return item.salonId;
    if (item is home_models.Deal) return item.salonId;
    return null;
  }

  // Check if item belongs to a different salon than current cart
  bool isDifferentSalon(dynamic item) {
    if (_items.isEmpty || _salonId == null) return false;
    final itemSalonId = _getItemSalonId(item);
    if (itemSalonId == null) return false;
    return itemSalonId != _salonId;
  }

  // Clear cart and add new item from different salon
  void _clearAndAddItem(dynamic item, {int quantity = 1}) {
    final itemSalonId = _getItemSalonId(item);
    _items.clear();
    _items[item] = quantity;
    _salonId = itemSalonId;
    // Note: salonName should be set separately via setSalonInfo if needed
    notifyListeners();
  }

  // Get price of an item
  double _getItemPrice(dynamic item) {
    if (item is salon_models.Service) return (item.price ?? 0).toDouble();
    if (item is salon_models.Deal)
      return (item.totalPrice ?? item.price ?? 0).toDouble();
    if (item is home_models.Service) return (item.price ?? 0).toDouble();
    if (item is home_models.Deal)
      return (item.totalPrice ?? item.price ?? 0).toDouble();
    return 0.0;
  }

  _CartItemType? _itemType(dynamic item) {
    if (item is salon_models.Service || item is home_models.Service) {
      return _CartItemType.service;
    }
    if (item is salon_models.Deal || item is home_models.Deal) {
      return _CartItemType.deal;
    }
    return null;
  }

  int? _itemId(dynamic item) {
    if (item is salon_models.Service) return item.id;
    if (item is salon_models.Deal) return item.id;
    if (item is home_models.Service) return item.id;
    if (item is home_models.Deal) return item.id;
    return null;
  }

  dynamic _findExistingKey(dynamic item) {
    final type = _itemType(item);
    final id = _itemId(item);
    if (type != null && id != null) {
      for (final existing in _items.keys) {
        if (_itemType(existing) == type && _itemId(existing) == id) {
          return existing;
        }
      }
      return null;
    }
    return _items.containsKey(item) ? item : null;
  }

  // Check if item is in cart
  bool isInCart(dynamic item) {
    return _findExistingKey(item) != null;
  }

  // Toggle item in cart (add if not present, remove if present)
  // Returns true if item was toggled successfully
  // Returns false if item is from different salon (requires clearing cart first)
  bool toggleItem(dynamic item, {bool forceClear = false}) {
    final existingKey = _findExistingKey(item);

    if (existingKey != null) {
      _items.remove(existingKey);
      notifyListeners();
      return true;
    } else {
      // Check if item is from a different salon
      if (isDifferentSalon(item)) {
        if (forceClear) {
          // User confirmed - clear cart and add new item
          _clearAndAddItem(item);
          return true;
        } else {
          // Return false to indicate different salon - caller should show confirmation
          return false;
        }
      }
      _items[item] = 1;
      // Update salon ID if not set
      _salonId ??= _getItemSalonId(item);
      notifyListeners();
      return true;
    }
  }

  // Add item to cart
  // Returns true if item was added successfully
  // Returns false if item is from different salon (requires clearing cart first)
  bool addItem(dynamic item, {int quantity = 1, bool forceClear = false}) {
    // Check if item is from a different salon
    if (isDifferentSalon(item)) {
      if (forceClear) {
        // User confirmed - clear cart and add new item
        _clearAndAddItem(item, quantity: quantity);
        return true;
      } else {
        // Return false to indicate different salon - caller should show confirmation
        return false;
      }
    }

    final existingKey = _findExistingKey(item);
    if (existingKey != null) {
      _items[existingKey] = quantity;
    } else {
      _items[item] = quantity;
    }
    // Update salon ID if not set
    _salonId ??= _getItemSalonId(item);
    notifyListeners();
    return true;
  }

  // Remove item from cart
  void removeItem(dynamic item) {
    log('alkdfalskdjfa;lskdjf;laskdjf;laskdjfalksdjf');
    final existingKey = _findExistingKey(item);
    if (existingKey != null) {
      _items.remove(existingKey);
      notifyListeners();
    }
  }

  // Update quantity
  void updateQuantity(dynamic item, int quantity) {
    if (quantity <= 0) {
      removeItem(item);
      return;
    }
    final existingKey = _findExistingKey(item);
    if (existingKey != null && _items.containsKey(existingKey)) {
      _items[existingKey] = quantity;
      notifyListeners();
    }
  }

  // Clear cart
  void clearCart() {
    _items.clear();
    _salonId = null;
    _salonName = null;
    notifyListeners();
  }
}

enum _CartItemType { service, deal }
