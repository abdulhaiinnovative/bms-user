/// Represents the different states a view can be in
enum ViewState {
  /// Initial state, no action taken yet
  idle,

  /// Loading state, waiting for data or processing
  loading,

  /// Success state, operation completed successfully
  success,

  /// Error state, something went wrong
  error,
}
