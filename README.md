# State Composer
>Create state machines in dart using object composition
>For now only suports simple transitions between states. Next steps are add listeners and parallel states

## Usage
###Creating a machine with to states A and B
``` dart
StateMachine machine = StateMachine(
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
'''
###Transitioning between states
```dart
print(machine.currentState!.id) //A
await machine.transitionTo("B");
//Leaving A
//Leaving A future completed
//Entered B
print(machine.currentState!.id) //B
```
