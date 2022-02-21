import 'package:state_composer/state_composer.dart';
import 'package:test/test.dart';

void main() {
  group(
    "State Machine Tests",
    () {
      late StateMachine machine;

      setUp(() {
        machine = StateMachine(
          id: "machine1",
          initialStateId: "A",
          states: [
            ComposerState(
              id: "A",
              onEnter: () async {
                print("Entered A");
              },
              onLeave: () async {
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
              onEnter: () {
                print("Entered B");
              },
              onLeave: () {
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
      });
    },
  );
}
