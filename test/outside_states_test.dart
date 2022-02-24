import 'package:state_composer/state_composer.dart';
import 'package:test/test.dart';

void main() {
  group(
    "Outside The States Tests Using Stream",
    () {
      late StateMachine machine;

      setUp(() {
        machine = StateMachine(
          id: "machine1",
          initialStateId: "A",
          states: [
            ComposerState(
              id: "A",
              onEnter: (stateMachine) async {
                print("Entered A");
              },
              onLeave: (stateMachine, nextState) async {
                print("Leaving A");

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
              },
              onLeave: (currentState, nextState) {
                print("leaving B");
              },
              transitions: [
                Transition(id: "B=>A", to: "A"),
              ],
            )
          ],
        );
      });

      test("Stream Listening", () async {
        int counter = 0;
        machine.stateStream.listen((currentState) async {
          switch (counter) {
            case 0:
              expect(currentState.id, "A");
              await machine.transitionTo("B");
              counter++;
              break;
            case 1:
              expect(currentState.id, "B");
              await machine.transitionTo("A");
              counter++;
              break;
            case 2:
              expect(currentState.id, "A");
              break;
          }
        });
      });
    },
  );

  group(
    "Outside The States Tests Without Stream",
    () {
      late StateMachine machine;

      setUp(() {
        machine = StateMachine(
          id: "machine1",
          initialStateId: "A",
          states: [
            ComposerState(
              id: "A",
              onEnter: (stateMachine) async {
                print("Entered A");
              },
              onLeave: (stateMachine, nextState) async {
                print("Leaving A");

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
              },
              onLeave: (currentState, nextState) {
                print("leaving B");
              },
              transitions: [
                Transition(id: "B=>A", to: "A"),
              ],
            )
          ],
        );
      });

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
