# State Composer
>Create state machines in dart using object composition <br>
>Next steps are to add parallel states and transition guards

## Usage
### Example of a simple machine with two states
Instanciate your `StateMachine` passing its id, i.e. a unique name, the inintial state id and a list of states <br>
Each `ComposerState` also have an id that can really be whatever you want to call it, as long as there is no other state with this name <br>
States execute stuff through `onEnter` and `onLeave` functions. <br>
`onEnter` will pass the last and current states <br>
`onLeave` will pass the current and next states <br>
Ps: those functions accept futures<br>
All transitions that a state is allowed to make must be inside the transitions list. A `Transition` also receives an id, 
and the id of the state that you want to go to
``` dart
machine = StateMachine(
  id: "machine1",
  initialStateId: "A",
  states: [
    ComposerState(
      id: "A",
      onEnter: (stateMachine) async {
        test("onEnter A Last State Should be Null", () {
          expect(stateMachine.lastState, null);
        });
        test("onEnter A Current State ID Should be A", () {
          expect(stateMachine.currentState!.id, "A");
        });
        print("Entered A");
      },
      onLeave: (stateMachine, nextState) async {
        print("Leaving A");

        expect(stateMachine.currentState!.id, "A");
        expect(nextState.id, "B");

        await Future.delayed(Duration(seconds: 3));
        print("Leaving A future completed");
      },
      transitions: [
        Transition(id: "A=>B", to: "B"),
      ],
    ),
    ComposerState(
      id: "B",
      onEnter: (stateMachine) {
        print("Entered B");

        expect(stateMachine.lastState!.id, "A");
        expect(stateMachine.currentState!.id, "B");
      },
      onLeave: (currentState, nextState) {
        print("leaving B");

        expect(currentState.id, "B");
        expect(nextState.id, "A");
      },
      transitions: [
        Transition(id: "B=>A", to: "A"),
      ],
    )
  ],
);
```
## Transitioning between states
```dart
print(machine.currentState!.id) //A
await machine.transitionTo("B");
//Leaving A
//Leaving A future completed
//Entered B
print(machine.currentState!.id) //B
```
## Generic State and Transition Types
You can create personalized states and transitions that extends `ComposerState` and `Transition`. To see an
example look at <a href="https://github.com/FelipeMarra/flutter_chat_composer/blob/main/lib/models/chat_bot_models.dart"> flutter_chat_composer's model <a>
that extends state_composer to create a chatbot based on state machines

## Listening to State Changes
Use the state machines' `stateStream` to listen the state changes
```dart
machine.stateStream.listen((currentState) {
  print("State Changed to ${currentState.id}");
});
```
