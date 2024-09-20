class TokenSingleton {
  // Private constructor
  TokenSingleton._();

  // Single instance of the class
  static final TokenSingleton _instance = TokenSingleton._();

  // Getter for the instance
  static TokenSingleton get instance => _instance;

  String? _token;
  String? get token => _token;
  set token(String? newToken) {
    _token = newToken;
  }

  void clearToken() {
    _token = null;
  }
}