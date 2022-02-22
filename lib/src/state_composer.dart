library state_composer.src.state_composer;

import 'package:state_composer/src/exceptions.dart';

///To create a state machine just instanciate this class passing the [id]
///and the [ComposerState]s that it will have, you also need to set
///what state will be the [initial] one
class StateMachine {
  ///[StateMachine]'s id, a name that identifies the machine
  final String id;

  ///The list of [ComposerState]s that make up this [StateMachine]
  final List<ComposerState> states;

  ///The [ComposerState] id that will be automatically activated when the [StateMachine] is
  ///instantiated
  final String initialStateId;

  ///The [ComposerState] the [StateMachine] was in previously
  ComposerState? _lastState;
  ComposerState? get lastState => _lastState;

  ///The [ComposerState] the [StateMachine] is currently in
  ComposerState? _currentState;
  ComposerState? get currentState => _currentState;

  //TODO listen to state changes via status class => will also deliver [starded]

  StateMachine({
    required this.id,
    required this.states,
    required this.initialStateId,
  }) {
    _start();
  }

  Future<void> _start() async {
    //Set the current and last states as the initial one and enter it
    try {
      _currentState = states.singleWhere(
        (ComposerState state) => state.id == initialStateId,
      );
    } catch (e) {
      throw InvalidState(from: currentState?.id ?? "None", id: initialStateId);
    }
    _lastState = _currentState;
    await _currentState?.onEnter!(null, _currentState!);
  }

  ///This method executes a transition from the [currentState] to the
  ///[nextState] parameter, but only if the transition is valid i.e. if the
  ///[currentState] have [nextState] in its transitions list
  Future<void> transitionTo(String nextStateId) async {
    //try to get next state
    ComposerState nextState;
    try {
      nextState = states.singleWhere(
        (ComposerState ComposerState) => ComposerState.id == nextStateId,
      );
    } catch (e) {
      throw InvalidState(from: currentState!.id, id: nextStateId);
    }

    //check if transition is valid
    if (!_currentState!.transitionsDestines().contains(nextStateId)) {
      throw InvalidTransition(
        from: _currentState!.id,
        to: nextStateId,
      );
    }

    //leave last state
    await _lastState?.onLeave!(_currentState!, nextState);

    //Update last and current sates
    ComposerState lastStateCopy = _lastState!.copyWith();
    _lastState = _currentState;
    _currentState = nextState;

    //enter next sate
    await nextState.onEnter!(lastStateCopy, currentState!);
  }
}

///A state for the [StateMachine]
///To create a [ComposerState] the only required param is it's [id], other params may be:
///[onEnter]: a function that is executed on enter the state.
///[onLeave]: a function that is executed on leave the state
///i.e. when making a transition from state A to state B, state A will run its
///onLeave function and after that state B will run its onEnter function
///[transitions]: if your state can go to another one than it must have a
///[Transition] to this other state inside this list
///
class ComposerState {
  ///State's name. Must be unique
  final String id;

  ///Function executed on enter the state.
  ///Will give you access to the [lastState] and the [currentState]
  final Function(ComposerState? lastState, ComposerState currentState)? onEnter;

  ///Function executed on leave the state.
  ///Will give you access to the [currentState] and the [nextState]
  final Function(ComposerState currentState, ComposerState nextState)? onLeave;

  ///The list of [Transition]s that make up this [StateMachine]
  final List<Transition> transitions;

  ComposerState({
    required this.id,
    this.onEnter,
    this.onLeave,
    required this.transitions,
  });

  ///The ids of the [transitions]
  List<String> transitionsDestines() {
    List<String> destines = [];
    for (Transition transition in transitions) {
      destines.add(transition.to);
    }
    return destines;
  }

  ComposerState copyWith({
    String? id,
    Function(ComposerState? lastState, ComposerState currentState)? onEnter,
    Function(ComposerState currentState, ComposerState nextState)? onLeave,
    List<Transition>? transitions,
  }) {
    return ComposerState(
      id: id ?? this.id,
      onEnter: onEnter ?? this.onEnter,
      onLeave: onLeave ?? this.onLeave,
      transitions: transitions ?? this.transitions,
    );
  }
}

///This class represents the possible [Transition]s between [ComposerState]s
///from the state where this transition where instanciated [to] the next one
class Transition {
  final String id;
  final String to;

  Transition({
    required this.id,
    required this.to,
  });

  @override
  String toString() {
    return "Transition id: $id, to: $to";
  }
}
