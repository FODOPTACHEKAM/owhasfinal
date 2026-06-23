# OOP Diagram: Sequence Diagram

## Definition
A **Sequence Diagram** is a UML interaction diagram that shows how objects communicate with each other over time. It displays the order of messages (method calls, responses, events) exchanged between objects to accomplish a specific task or use case.

## Purpose in OOP
- Models the **temporal order** of interactions between objects
- Shows **method calls** between objects, making it directly translatable to code
- Identifies which **classes need which methods** — each message becomes a method on the receiving class
- Reveals **dependencies** between objects (who calls whom)
- Documents the runtime behavior of a specific scenario

## Key Elements

| Element | Symbol | Description |
|---------|--------|-------------|
| Object / Participant | Rectangle at top with lifeline | An instance of a class participating in the interaction |
| Lifeline | Vertical dashed line | Represents the object's existence over time |
| Activation Bar | Thin rectangle on lifeline | Shows when an object is actively processing |
| Synchronous Message | Solid arrow with filled head | A call that waits for a response |
| Asynchronous Message | Solid arrow with open head | A call that does not wait (fire-and-forget) |
| Return Message | Dashed arrow | The response or return value |
| Self-Message | Arrow looping back to same lifeline | An object calling its own method |
| Combined Fragment | Rectangle with operator (alt, loop, opt) | Conditional, loop, or optional behavior |

## When to Use
- To detail **how a specific use case is executed** at the object level
- When designing **API interactions** between client and server
- To validate that **classes have the right methods** before coding
- For documenting complex **multi-step processes** involving multiple objects

## How It Relates to Other Diagrams
- **Use Case Diagram** identifies what to model; Sequence Diagram shows how it executes
- **Activity Diagram** shows the same flow as a process; Sequence Diagram shows it as object messages
- **Class Diagram** defines the classes; Sequence Diagram validates their methods and relationships
- **Component Diagram** shows module boundaries; messages in sequence diagrams cross those boundaries

## OOP Principles Illustrated
- **Message Passing**: Objects communicate exclusively through messages (method calls)
- **Encapsulation**: Each object only exposes its public methods to callers
- **Polymorphism**: The same message name may invoke different implementations depending on the receiver type
- **Single Responsibility**: If one object handles too many messages, it may need to be decomposed

## Drawing Guidelines
1. Place objects/participants across the top in the order they interact
2. Time flows downward — earlier messages are higher
3. Label every message with the method name and parameters
4. Show return values on dashed return arrows
5. Use `alt` fragments for conditional logic, `loop` for repetition
6. Keep one diagram per use case or scenario for clarity

## Common Mistakes
- Too many objects on one diagram (keep it focused on one scenario)
- Missing return messages (every synchronous call should have a return)
- Not labeling messages with actual method names
- Confusing synchronous and asynchronous messages
- Showing all possible scenarios in one diagram (use separate diagrams or alt fragments)

## Tools
- Draw.io / diagrams.net
- Lucidchart
- StarUML
- Visual Paradigm
- PlantUML
- Mermaid.js
