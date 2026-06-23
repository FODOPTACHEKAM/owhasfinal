# OOP Diagram: Use Case Diagram

## Definition
A **Use Case Diagram** is a UML behavioral diagram that captures the functional requirements of a system by showing the interactions between external actors (users or systems) and the use cases (functions) the system provides. It defines **what** the system does from the user's perspective, without specifying **how**.

## Purpose in OOP
- Captures **functional requirements** as discrete use cases
- Identifies all **actors** (primary and secondary) that interact with the system
- Shows the **system boundary** — which functionality is inside the system
- Serves as the basis for designing classes, services, and methods that implement each use case
- Used in **requirements validation** with stakeholders

## Key Elements

| Element | Symbol | Description |
|---------|--------|-------------|
| Actor | Stick figure | A user role or external system that interacts with the system |
| Use Case | Oval / ellipse | A specific function or feature the system provides |
| System Boundary | Rectangle enclosing use cases | Defines what is part of the system |
| Association | Solid line | Links an actor to a use case they participate in |
| Include | Dashed arrow with <<include>> | A use case always includes another use case |
| Extend | Dashed arrow with <<extend>> | A use case optionally extends another use case |
| Generalization | Arrow with hollow head | An actor or use case inherits from another |

## When to Use
- During **requirements analysis** to agree on system scope
- After the Context Diagram, to detail what each actor can do
- As input for designing **Activity Diagrams** (workflow for each use case) and **Sequence Diagrams** (message flow for each use case)
- In project documentation to map features to user roles

## How It Relates to Other Diagrams
- **Context Diagram** identifies actors; Use Case Diagram details their interactions
- **Activity Diagram** shows the step-by-step workflow of a single use case
- **Sequence Diagram** shows object interactions for a single use case
- **Class Diagram** implements the data and logic behind use cases

## OOP Principles Illustrated
- **Abstraction**: Each use case abstracts complex internal logic into a named function
- **Encapsulation**: The system boundary encapsulates implementation details
- **Inheritance**: Actor generalization (e.g., Student inherits from User)
- **Polymorphism**: Different actors may trigger the same use case with different behaviors

## Drawing Guidelines
1. Draw the system boundary rectangle first
2. Place actors outside the boundary
3. Place use cases inside the boundary
4. Connect each actor to the use cases they interact with
5. Use <<include>> for mandatory sub-functions and <<extend>> for optional behavior
6. Keep use case names as verb phrases ("Register Attendance", "Generate Report")

## Common Mistakes
- Too many use cases (keep it at a meaningful level of abstraction)
- Actors inside the system boundary (actors are always external)
- Using the diagram to show sequence or workflow (that's an Activity Diagram)
- Forgetting secondary actors (databases, external APIs, timers)
- Confusing <<include>> and <<extend>> (include = always happens; extend = optional)

## Tools
- Draw.io / diagrams.net
- Lucidchart
- StarUML
- Visual Paradigm
- PlantUML
