# OOP Diagram: Component Diagram

## Definition
A **Component Diagram** is a UML structural diagram that shows the organization of and dependencies among software components. A component is a modular, replaceable part of the system that encapsulates its contents and exposes functionality through interfaces.

## Purpose in OOP
- Shows how the system is **divided into components** (modules, packages, libraries)
- Illustrates **provided and required interfaces** for each component
- Maps the **dependency relationships** — which component depends on which
- Bridges the gap between architecture (high-level) and classes (low-level)
- Guides decisions about **packaging, deployment, and reusability**

## Key Elements

| Element | Symbol | Description |
|---------|--------|-------------|
| Component | Rectangle with component icon (two small rectangles) | A modular software unit |
| Provided Interface | Lollipop (circle on a line) | An interface the component exposes to others |
| Required Interface | Socket (half-circle on a line) | An interface the component needs from others |
| Dependency | Dashed arrow | One component depends on another |
| Port | Small square on component boundary | A named interaction point |
| Package | Tabbed rectangle | A grouping of related components |

## When to Use
- After the System Architecture Diagram, to **detail each layer's internal modules**
- When designing the **module structure** of the application
- To plan **code organization** (folders, packages, libraries)
- When evaluating which components can be **reused, replaced, or tested independently**

## How It Relates to Other Diagrams
- **System Architecture Diagram** shows layers; Component Diagram shows modules within layers
- **Class Diagram** shows classes within each component
- **Deployment Diagram** shows which component runs on which node
- **Sequence Diagram** shows messages crossing component boundaries

## OOP Principles Illustrated
- **Encapsulation**: Each component hides its internals and exposes only its interfaces
- **Interface Segregation**: Components define focused interfaces for their consumers
- **Dependency Inversion**: Components depend on abstractions (interfaces), not concrete implementations
- **Open/Closed Principle**: Components can be extended through their interfaces without modifying internals
- **Modularity**: The system is composed of independent, interchangeable units

## Drawing Guidelines
1. Identify the major functional modules of the system
2. Draw each as a component with the UML component icon
3. Show provided interfaces (lollipops) and required interfaces (sockets)
4. Connect sockets to lollipops to show which component satisfies which dependency
5. Group related components into packages if the diagram gets large
6. Label all dependencies and interfaces

## Common Mistakes
- Confusing components with classes (components are coarser-grained)
- Not showing interfaces — just boxes with arrows misses the point
- Too fine-grained (showing every class as a component)
- Too coarse-grained (the whole system as one component)
- Not distinguishing provided vs. required interfaces

## Tools
- Draw.io / diagrams.net
- Lucidchart
- StarUML
- Visual Paradigm
- Enterprise Architect
- PlantUML
