import 'package:state_composer/src/state_composer.dart';
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
            State(
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
            State(
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

      test("Initial State should be A", () {
        expect(machine.currentState!.id, "A");
      });

      test("Transition from A to B", () async{
        await machine.transitionTo("B");
        expect(machine.currentState!.id, "B");
      });
    },
  );
}
