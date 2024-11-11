const Map<String, String> firebaseAuthErrors = {
  'invalid-email': "L'adresse e-mail est invalide.",
  'invalid-credential': "Courriel et/ou mot de passe incorrect",
  'user-disabled': "Le compte de cet utilisateur est désactivé.",
  'user-not-found': "Aucun utilisateur trouvé avec cet e-mail.",
  'wrong-password': "Le mot de passe est incorrect.",
  'email-already-in-use': "Ce courriel est déjà utilisé par un autre compte.",
  'weak-password': "Le mot de passe est trop faible.",
  'operation-not-allowed': "Cette opération n'est pas autorisée.",
  'network-request-failed': "La connexion au réseau a échoué.",
  'requires-recent-login': "Veuillez vous reconnecter avant d'effectuer cette opération.",
};

String mapFirebaseAuthError(String errorCode) {
  return firebaseAuthErrors[errorCode] ?? "Une erreur inconnue s'est produite.";
}
