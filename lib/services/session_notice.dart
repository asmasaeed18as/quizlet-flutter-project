class SessionNotice {
  static String? _message;

  static void set(String message) {
    _message = message;
  }

  static String? take() {
    final current = _message;
    _message = null;
    return current;
  }
}
