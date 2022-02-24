import 'package:state_composer/state_composer.dart';
import 'package:test/test.dart';

void main() {
  group(
    "Inside The State Tests",
    () {
      bool firstTime = true;
      test("Transition from A to B", () async {
        StateMachine machine = StateMachine(
          id: "machine1",
          initialStateId: "A",
          states: [
            ComposerState(
              id: "A",
              onEnter: (stateMachine) async {
                if (firstTime == true) {
                  expect(stateMachine.lastState, null);
                  firstTime = false;
                } else {
                  expect(stateMachine.lastState!.id, "B");
                }

                expect(stateMachine.currentState!.id, "A");

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
              onLeave: (machine, nextState) {
                print("leaving B");

                expect(machine.currentState!.id, "B");
                expect(nextState.id, "A");
              },
              transitions: [
                Transition(id: "B=>A", to: "A"),
              ],
            )
          ],
        );
        await machine.transitionTo("B");
        await machine.transitionTo("A");
      });
    },
  );
}
