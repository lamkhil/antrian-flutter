class AdminSdkNotConfigured implements Exception {
  final String message;
  const AdminSdkNotConfigured(this.message);
  @override
  String toString() => message;
}

class AdminSdkInitFailed implements Exception {
  final String message;
  const AdminSdkInitFailed(this.message);
  @override
  String toString() => message;
}
