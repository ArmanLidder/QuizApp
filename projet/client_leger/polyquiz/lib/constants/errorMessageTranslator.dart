

const Map<String, String> firebaseAuthErrors = {
  'invalid-email': "EMAIL_INVALID",
  'invalid-credential': "INVALID_CREDENTIAL",
  'user-disabled': "USER_DISABLED",
  'user-not-found': "USER_NOT_FOUND",
  'wrong-password': "WRONG_PASSWORD",
  'email-already-in-use': "EMAIL_ALREADY_IN_USE",
  'weak-password': "WEAK_PASSWORD",
  'operation-not-allowed': "OPERATION_NOT_ALLOWED",
  'network-request-failed': "NETWORK_REQUEST_FAILED",
  'requires-recent-login': "REQUIRES_RECENT_LOGIN",
};

String mapFirebaseAuthError(String errorCode) {
  return firebaseAuthErrors[errorCode] ?? "Une erreur inconnue s'est produite.";
}
