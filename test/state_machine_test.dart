import 'package:state_composer/state_composer.dart';
import 'package:test/test.dart';

void main() {
  group(
    "State Machine Tests",
    () {
      late StateMachine machine;

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

      test("Initial state should be A", () {
        expect(machine.currentState!.id, "A");
      });

      test("Transition from A to B", () async {
        await machine.transitionTo("B");
        expect(machine.currentState!.id, "B");
        expect(machine.lastState!.id, "A");
      });
    },
  );
}
