# OOP Diagram: Activity Diagram

## Definition
An **Activity Diagram** is a UML behavioral diagram that models the workflow or process flow of a system. It shows the sequence of activities (actions), decisions, parallel paths, and synchronization points that occur during a specific process or use case.

## Purpose in OOP
- Models the **dynamic behavior** of a system — how processes flow from start to end
- Shows **decision points** (branching logic) and **parallel activities** (concurrency)
- Maps directly to **method implementations** — each activity can become a method call
- Documents the **business logic** behind a use case before coding begins
- Useful for identifying where **objects interact** and what **state changes** occur

## Key Elements

| Element | Symbol | Description |
|---------|--------|-------------|
| Initial Node | Filled black circle | Starting point of the workflow |
| Activity / Action | Rounded rectangle | A step or task in the process |
| Decision Node | Diamond | A branching point with conditions |
| Merge Node | Diamond | Converges multiple branches back into one |
| Fork Bar | Thick horizontal bar | Splits flow into parallel activities |
| Join Bar | Thick horizontal bar | Synchronizes parallel flows back into one |
| Final Node | Bullseye (circle in circle) | End of the workflow |
| Flow Arrow | Arrow | Direction of flow between activities |
| Swimlane | Vertical or horizontal partition | Groups activities by actor or component |

## When to Use
- To model the **workflow** of a specific use case
- When a process has **decision points**, **loops**, or **parallel tasks**
- To communicate process flow to non-technical stakeholders
- Before implementing methods — to plan the logic flow

## How It Relates to Other Diagrams
- **Use Case Diagram** identifies the use case; Activity Diagram shows its internal workflow
- **Sequence Diagram** shows the same flow but focuses on object-to-object messages with timing
- **State Machine Diagram** focuses on an object's state transitions; Activity Diagram focuses on process flow
- **Class Diagram** implements the objects whose methods are called in each activity

## OOP Principles Illustrated
- **Encapsulation**: Each activity can represent a method encapsulated within a class
- **Polymorphism**: Decision nodes may lead to different implementations based on object type
- **Responsibility Assignment**: Swimlanes show which class or actor owns each activity
- **Composition**: Complex activities are composed of simpler sub-activities

## Drawing Guidelines
1. Start with a single Initial Node
2. Use swimlanes to assign activities to actors (Lecturer, Student, Server, etc.)
3. Label every decision branch with its condition (Yes/No, Valid/Invalid)
4. Use fork/join bars for genuinely parallel activities
5. End with one or more Final Nodes
6. Keep activity names as verb phrases ("Validate PIN", "Capture Face Image")

## Common Mistakes
- No decision labels — every branch from a diamond must be labeled
- Missing the final node — every path must eventually reach an end
- Using it to show class structure (that's a Class Diagram)
- Overcomplicating with too many activities — keep it at the right abstraction level
- Forgetting parallel paths where activities genuinely happen concurrently

## Tools
- Draw.io / diagrams.net
- Lucidchart
- StarUML
- Visual Paradigm
- PlantUML
