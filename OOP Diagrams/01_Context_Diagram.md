# OOP Diagram: Context Diagram

## Definition
A **Context Diagram** (also called a Level 0 Data Flow Diagram) represents the highest-level view of a system. It shows the system as a single process (a black box) and illustrates how it interacts with external entities (actors, systems, data stores) through data flows.

## Purpose in OOP
- Defines the **system boundary** — what is inside the system vs. what is external
- Identifies all **external actors** (users, hardware, third-party services) that interact with the system
- Maps **data flows** entering and leaving the system
- Serves as the starting point before decomposing the system into subsystems, classes, or components

## Key Elements

| Element | Symbol | Description |
|---------|--------|-------------|
| System | Single rounded rectangle or circle | The entire software system as one process |
| External Entity | Rectangle | An actor, device, or external system outside the boundary |
| Data Flow | Arrow (labeled) | Data or control moving between the system and an entity |
| System Boundary | Dashed border | Separates internal components from external ones |

## When to Use
- At the **very start** of system analysis and design
- In requirements gathering to confirm scope with stakeholders
- To communicate with non-technical audiences who need a high-level view
- As the first diagram in a design document before showing internal details

## How It Relates to Other Diagrams
- **Precedes** the Use Case Diagram (which decomposes actor–system interactions)
- **Precedes** the System Architecture Diagram (which shows internal layers)
- Actors identified here reappear in Use Case, Sequence, and Activity diagrams

## OOP Principles Illustrated
- **Encapsulation**: The system is treated as a single encapsulated unit
- **Abstraction**: Internal details are hidden; only interfaces (data flows) are shown
- **Separation of Concerns**: External responsibilities vs. internal processing are clearly divided

## Drawing Guidelines
1. Place the system in the center
2. Arrange external entities around it
3. Draw labeled arrows showing direction of data flow
4. Keep it simple — no internal structure at this level
5. Use consistent naming for entities (these names carry through to other diagrams)

## Common Mistakes
- Including internal components (that belongs in architecture or component diagrams)
- Missing an external actor (every actor must appear here)
- Unlabeled data flows — every arrow needs a name describing what data moves
- Confusing a context diagram with a use case diagram (context shows data flows, not use cases)

## Tools
- Draw.io / diagrams.net
- Lucidchart
- Microsoft Visio
- PlantUML
- Enterprise Architect
