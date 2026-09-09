import 'package:flutter/foundation.dart';
import 'view_state.dart';

/// Base ViewModel that all ViewModels should extend
/// Provides common functionality like state management, error handling, and loading states
abstract class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  String? _errorMessage;
  bool _disposed = false;

  /// Current state of the view
  ViewState get state => _state;

  /// Error message if state is error
  String? get errorMessage => _errorMessage;

  /// Convenience getters for checking state
  bool get isIdle => _state == ViewState.idle;
  bool get isLoading => _state == ViewState.loading;
  bool get isSuccess => _state == ViewState.success;
  bool get isError => _state == ViewState.error;

  /// Set the state and notify listeners
  void setState(ViewState newState) {
    _state = newState;
    if (newState != ViewState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  /// Set loading state
  void setLoading() {
    setState(ViewState.loading);
  }

  /// Set success state
  void setSuccess() {
    setState(ViewState.success);
  }

  /// Set idle state
  void setIdle() {
    setState(ViewState.idle);
  }

  /// Set error state with message
  void setError(String message) {
    _errorMessage = message;
    setState(ViewState.error);
  }

  /// Execute an async operation with automatic state management
  /// Handles loading, success, and error states automatically
  Future<T?> executeAsync<T>({
    required Future<T> Function() operation,
    bool setLoadingState = true,
    bool setSuccessState = true,
    void Function(T data)? onSuccess,
    void Function(String error)? onError,
  }) async {
    try {
      if (setLoadingState) {
        setLoading();
      }

      final result = await operation();

      if (setSuccessState) {
        setSuccess();
      }

      if (onSuccess != null) {
        onSuccess(result);
      }

      return result;
    } catch (e) {
      // Clean up error message - remove "Exception: " prefix if present
      String errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring('Exception: '.length);
      }
      setError(errorMsg);

      if (onError != null) {
        onError(errorMsg);
      }

      // ViewModel error logging removed

      return null;
    }
  }

  /// Execute an async operation without changing the state
  /// Useful for background operations
  Future<T?> executeAsyncSilent<T>({
    required Future<T> Function() operation,
    void Function(String error)? onError,
  }) async {
    try {
      return await operation();
    } catch (e) {
      // Clean up error message - remove "Exception: " prefix if present
      String errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring('Exception: '.length);
      }

      if (onError != null) {
        onError(errorMsg);
      }

      // ViewModel silent error logging removed

      return null;
    }
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
