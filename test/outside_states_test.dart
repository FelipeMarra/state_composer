import 'package:state_composer/state_composer.dart';
import 'package:test/test.dart';

void main() {
  group(
    "Outside The States Tests Using Stream",
    () {
      late StateMachine machine;
      late bool firstTime = true;

      setUp(() {
        machine = StateMachine(
          id: "machine1",
          initialStateId: "A",
          states: [
            ComposerState(
              id: "A",
              onEnter: (stateMachine) async {
                print("Entered A");

                await Future.delayed(Duration(seconds: 3));

                print("Enter A future completed");

                if (firstTime) {
                  stateMachine.transitionTo("B");
                  firstTime = false;
                }
              },
              onLeave: (stateMachine, nextState) async {
                print("Leaving A");
              },
              transitions: [
                Transition(id: "A=>B", to: "B"),
              ],
            ),
            ComposerState(
              id: "B",
              onEnter: (stateMachine) async {
                print("Entered B");

                await Future.delayed(Duration(seconds: 3));

                print("Enter A future completed");

                stateMachine.transitionTo("A");
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
        await expectLater(
          machine.stateStream.map((event) => event.id),
          emitsInOrder(["A", "B", "A"]),
        );
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
