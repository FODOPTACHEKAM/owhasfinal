# OOP Diagram: Class Diagram

## Definition
A **Class Diagram** is the most fundamental UML structural diagram in object-oriented design. It shows the system's classes, their attributes (properties), methods (operations), and the relationships between them — including inheritance, association, composition, aggregation, and dependency.

## Purpose in OOP
- Defines the **static structure** of the system — the blueprint of all objects
- Shows **attributes** (what data each class holds) and **methods** (what each class can do)
- Documents **relationships**: inheritance (is-a), composition (has-a), association (uses)
- Directly translatable to **source code** — each class becomes a Dart/Java/Python class
- Central to the design document — referenced by nearly every other diagram

## Key Elements

| Element | Symbol | Description |
|---------|--------|-------------|
| Class | Rectangle divided into 3 sections | Name / Attributes / Methods |
| Abstract Class | Class name in *italics* | Cannot be instantiated; must be subclassed |
| Interface | Class with <<interface>> stereotype | Defines a contract without implementation |
| Attribute | `- name: Type` | A field/property with visibility |
| Method | `+ methodName(params): ReturnType` | An operation with visibility |
| Visibility | `+` public, `-` private, `#` protected | Access level modifiers |

## Relationship Types

| Relationship | Symbol | Description | Example |
|-------------|--------|-------------|---------|
| Association | Solid line | General relationship | Lecturer — Session |
| Directed Association | Arrow | One class knows about another | Student → AttendanceRecord |
| Aggregation | Open diamond | Whole-part (part can exist independently) | Department ◇— Lecturer |
| Composition | Filled diamond | Whole-part (part cannot exist without whole) | Session ◆— AttendanceRecord |
| Inheritance | Arrow with hollow head | Is-a relationship (extends) | Lecturer ▷— User |
| Implementation | Dashed arrow with hollow head | Implements an interface | SessionService --▷ ISessionService |
| Dependency | Dashed arrow | Uses temporarily | ReportGenerator --→ Session |

## Multiplicity

| Notation | Meaning |
|----------|---------|
| `1` | Exactly one |
| `0..1` | Zero or one |
| `*` or `0..*` | Zero or more |
| `1..*` | One or more |
| `N..M` | Range from N to M |

## When to Use
- During **detailed design** after architecture and component diagrams
- When **translating requirements into code structure**
- To communicate the object model to the development team
- As reference documentation for understanding the codebase

## How It Relates to Other Diagrams
- **Component Diagram** groups classes into components
- **Sequence Diagram** shows interactions between instances of these classes
- **ERD** maps classes to database tables
- **Use Case Diagram** — each use case is implemented by one or more classes

## OOP Principles Illustrated
- **Encapsulation**: Private attributes, public methods
- **Inheritance**: Class hierarchies and abstract classes
- **Polymorphism**: Method overriding in subclasses
- **Abstraction**: Interfaces and abstract classes hide implementation
- **SOLID Principles**: Visible in class responsibilities and relationships

## Drawing Guidelines
1. Start with the main domain classes (nouns from requirements)
2. Add attributes and methods to each class
3. Draw relationships with correct notation and multiplicity
4. Use inheritance for shared behavior, composition for ownership
5. Mark abstract classes and interfaces
6. Keep the diagram focused — split into sub-diagrams if too large

## Common Mistakes
- Too many classes on one diagram (split by package/component)
- Missing multiplicity labels on associations
- Confusing aggregation with composition
- Not showing visibility modifiers
- Using inheritance where composition would be more appropriate
- Listing every getter/setter (show only significant methods)

## Tools
- Draw.io / diagrams.net
- Lucidchart
- StarUML
- Visual Paradigm
- PlantUML
- Enterprise Architect
