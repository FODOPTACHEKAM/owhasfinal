# OOP Diagram: System Architecture Diagram

## Definition
A **System Architecture Diagram** presents the overall structure of a software system by showing its major layers, modules, and their relationships. It is a high-level blueprint that describes how the system is organized, what technologies are used at each layer, and how data flows between them.

## Purpose in OOP
- Decomposes the system into **architectural layers** (Presentation, Business Logic, Data, etc.)
- Shows how **classes and objects** are organized into packages, modules, or services
- Illustrates the **technology choices** at each layer (frameworks, databases, APIs)
- Provides a roadmap for developers to understand where new code should be placed

## Key Elements

| Element | Symbol | Description |
|---------|--------|-------------|
| Layer | Horizontal band or stacked box | A logical tier (UI, Logic, Data, Cloud) |
| Module / Package | Rectangle within a layer | A grouping of related classes or services |
| Dependency Arrow | Arrow between layers/modules | Shows which layer depends on which |
| External Service | Cloud icon or separate box | Third-party APIs, databases, cloud services |
| Data Flow | Labeled arrow | Direction and type of data movement |

## When to Use
- After the Context Diagram, to show the **internal structure** of the system
- When presenting the system to developers, reviewers, or examiners
- To justify technology choices and separation of concerns
- As the central reference diagram that other diagrams (component, class, deployment) refine

## How It Relates to Other Diagrams
- **Context Diagram** shows the system as a black box; Architecture opens that box
- **Component Diagram** zooms into individual modules shown here
- **Class Diagram** details the OOP structure within each module
- **Deployment Diagram** maps these layers to physical infrastructure

## OOP Principles Illustrated
- **Layered Architecture**: Each layer encapsulates a responsibility (Single Responsibility Principle)
- **Dependency Inversion**: Higher layers depend on abstractions, not concrete implementations
- **Separation of Concerns**: UI, business logic, and data access are isolated
- **Modularity**: System is composed of interchangeable, self-contained modules

## Drawing Guidelines
1. Stack layers vertically (UI on top, Data on bottom) or use a component layout
2. Label each layer with its responsibility and key technologies
3. Show dependency direction with arrows (typically top-down)
4. Include external services (databases, APIs, cloud) at the edges
5. Use color coding to distinguish layers

## Common Mistakes
- Making it too detailed (this is a high-level view — save details for component/class diagrams)
- Not showing the data flow direction
- Mixing architecture (logical) with deployment (physical) concerns
- Omitting external dependencies that the system relies on

## Tools
- Draw.io / diagrams.net
- Lucidchart
- Microsoft Visio
- C4 Model tools (Structurizr)
- Figma
