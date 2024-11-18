import '../models/user.dart';

const Map<String, String> eventMessage = {
  "win": "partie gagnée",
  "loss": "partie perdue",
  "login": "connexion",
  "logout": "déconnexion"
};

const Map<EventType, String> loginEventTypeToString = {
  EventType.login: "login",
  EventType.logout: "logout",
};
const Map<Result, String> resultTypeToString = {
  Result.win: "win",
  Result.loss: "loss",
};
