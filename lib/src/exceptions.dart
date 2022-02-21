library state_composer.src.exceptions;

class InvalidTransition implements Exception {
  String from;
  String to;

  InvalidTransition({
    required this.from,
    required this.to,
  });

  String get message => "Invalid Transition, from $from to $to";

  @override
  String toString() {
    return message;
  }
}

class InvalidState implements Exception {
  String from;
  String id;

  InvalidState({
    required this.from,
    required this.id,
  });

  String get message =>
      "State $id doesen't exist or there are multiple states with this id. Comming from $from trying to transition to $id";

  @override
  String toString() {
    return message;
  }
}
