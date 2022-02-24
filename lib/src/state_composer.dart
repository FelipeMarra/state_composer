library state_composer.src.state_composer;

import 'dart:async';

import 'package:state_composer/src/exceptions.dart';

///To create a state machine just instanciate this class passing the [id]
///and the [ComposerState]s that it will have, you also need to set
///what state will be the [initial] one
class StateMachine<StateType extends ComposerState> {
  ///[StateMachine]'s id, a name that identifies the machine
  final String id;

  ///The list of [ComposerState]s that make up this [StateMachine]
  final List<StateType> states;

  ///The [ComposerState] id that will be automatically activated when the [StateMachine] is
  ///instantiated
  final String initialStateId;

  StateType? _lastState;
  ///The [ComposerState] the [StateMachine] was in previously
  StateType? get lastState => _lastState;

  StateType? _currentState;
  ///The [ComposerState] the [StateMachine] is currently in
  StateType? get currentState => _currentState;

  StreamController<StateType> _stateStreamController =
      StreamController<StateType>.broadcast();
  ///Strem updated every time [currenteState] is updated
  Stream<StateType> get stateStream => _stateStreamController.stream;

  StateMachine({
    required this.id,
    required this.states,
    required this.initialStateId,
  }) {
    _start();
  }

  Future<void> _start() async {
    //Set the current and last states as the initial one
    try {
      _currentState = states.singleWhere(
        (StateType state) => state.id == initialStateId,
      );
    } catch (e) {
      throw InvalidState(from: currentState?.id ?? "None", id: initialStateId);
    }

    //add to stream and enter the state
    _stateStreamController.add(_currentState!);
    await _currentState?.onEnter!(this);
  }

  ///This method executes a transition from the [currentState] to the
  ///[nextState] parameter, but only if the transition is valid i.e. if the
  ///[currentState] have [nextState] in its transitions list
  Future<void> transitionTo(String nextStateId) async {
    //try to get next state
    StateType nextState;
    try {
      nextState = states.singleWhere(
        (StateType composerState) => composerState.id == nextStateId,
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

    //leave current state
    await _currentState?.onLeave!(this, nextState);

    //Update last and current sates and add to stream
    _lastState = _currentState;
    _currentState = nextState;

    _stateStreamController.add(_currentState!);

    //enter next sate
    await nextState.onEnter!(this);
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
class ComposerState<TransitionType extends Transition> {
  ///State's name. Must be unique
  final String id;

  ///Function executed on enter the state.
  ///Will give you access to the [lastState] and the [currentState]
  final Function(StateMachine stateMachine)? onEnter;

  ///Function executed on leave the state.
  ///Will give you access to the [currentState] and the [nextState]
  final Function(StateMachine stateMachine, ComposerState nextState)? onLeave;

  ///The list of [Transition]s that make up this [StateMachine]
  final List<TransitionType> transitions;

  ComposerState({
    required this.id,
    this.onEnter,
    this.onLeave,
    required this.transitions,
  });

  ///The ids of the [transitions]
  List<String> transitionsDestines() {
    List<String> destines = [];
    for (TransitionType transition in transitions) {
      destines.add(transition.to);
    }
    return destines;
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
