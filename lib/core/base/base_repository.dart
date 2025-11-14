import 'package:flutter/foundation.dart';

/// Base Repository that all repositories should extend
/// Provides common error handling and logging
abstract class BaseRepository {
  /// Execute a repository operation with error handling
  Future<T> execute<T>({
    required Future<T> Function() operation,
    String? errorContext,
  }) async {
    try {
      return await operation();
    } catch (e) {
      final context = errorContext ?? 'Repository operation';
      final errorMessage = '$context failed: ${e.toString()}';

      if (kDebugMode) {
        print('Repository Error: $errorMessage');
      }

      // Re-throw the error so the ViewModel can handle it
      rethrow;
    }
  }

  /// Execute a repository operation and return null on error instead of throwing
  Future<T?> executeSafe<T>({
    required Future<T> Function() operation,
    String? errorContext,
  }) async {
    try {
      return await operation();
    } catch (e) {
      final context = errorContext ?? 'Repository operation';
      final errorMessage = '$context failed: ${e.toString()}';

      if (kDebugMode) {
        print('Repository Safe Error: $errorMessage');
      }

      return null;
    }
  }
}
