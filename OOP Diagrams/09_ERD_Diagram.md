# OOP Diagram: Entity-Relationship Diagram (ERD)

## Definition
An **Entity-Relationship Diagram (ERD)** models the data structure of a system by showing entities (data objects), their attributes, and the relationships between them. It is the standard way to design and document a database schema before implementation.

## Purpose in OOP
- Defines the **persistent data model** — what data is stored and how it is structured
- Maps **OOP classes to database tables** (Object-Relational Mapping)
- Shows **relationships and cardinality** between data entities
- Identifies **primary keys, foreign keys**, and constraints
- Serves as the contract between the application layer and the database layer

## Key Elements

| Element | Symbol | Description |
|---------|--------|-------------|
| Entity | Rectangle | A data object that will become a database table |
| Attribute | Oval or listed inside entity | A property/column of the entity |
| Primary Key | Underlined attribute | Uniquely identifies each record |
| Foreign Key | Attribute referencing another entity's PK | Links tables together |
| Relationship | Diamond or labeled line | An association between entities |
| Cardinality | Notation on relationship line | 1:1, 1:N, M:N |

## Relationship Cardinalities

| Notation | Meaning | Example |
|----------|---------|---------|
| 1 : 1 | One to one | Lecturer — Profile |
| 1 : N | One to many | Lecturer — Session (one lecturer creates many sessions) |
| M : N | Many to many | Student — Session (many students attend many sessions) |

## ERD Notation Styles

| Style | Description |
|-------|-------------|
| Chen Notation | Entities as rectangles, relationships as diamonds, attributes as ovals |
| Crow's Foot | Entities as rectangles with attributes listed; lines with crow's foot for "many" |
| UML | Similar to class diagram but focused on data persistence |

## When to Use
- During **database design** phase
- When mapping domain objects to persistent storage
- To document the data layer for the development team and examiners
- When designing Firebase Firestore collections or SQL tables

## How It Relates to Other Diagrams
- **Class Diagram** shows OOP structure; ERD shows the database structure (often a 1:1 mapping)
- **Component Diagram** shows the Data/Storage component; ERD details its internal schema
- **Sequence Diagram** shows CRUD operations; ERD defines what those operations affect

## OOP Principles Illustrated
- **Abstraction**: Entities represent real-world concepts at the data level
- **Encapsulation**: Each entity owns its attributes
- **Relationships**: Map to associations and compositions in the class diagram
- **Normalization**: Reducing redundancy reflects good OOP design (no duplicated state)

## Drawing Guidelines
1. Identify all entities from the domain (nouns: Lecturer, Student, Session, etc.)
2. List attributes for each entity with data types
3. Mark primary keys (PK) and foreign keys (FK)
4. Draw relationships with cardinality labels
5. Use Crow's Foot notation for clarity in complex schemas
6. Normalize to at least 3NF to reduce redundancy

## Common Mistakes
- Missing primary keys or foreign keys
- Wrong cardinality (e.g., modeling 1:N as 1:1)
- Not normalizing — too much data duplication
- Confusing ERD with Class Diagram (ERD is data-centric, Class Diagram includes behavior)
- Forgetting junction/bridge tables for M:N relationships

## Tools
- Draw.io / diagrams.net
- Lucidchart
- MySQL Workbench
- dbdiagram.io
- Enterprise Architect
- pgModeler (PostgreSQL)
