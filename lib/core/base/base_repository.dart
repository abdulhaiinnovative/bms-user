// debug import removed

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
      // Repository error handling (logging removed)
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
      // Repository safe error handling (logging removed)
      return null;
    }
  }
}
