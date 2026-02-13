
# Architecture

### Layers
- **Application** -
upper layer, used to connect all of the modules below, can be used to create integrations with external APIs

- **Implementation** -
middle layer, used to create business logic and direct implementations of specific features

- **Package** -
lower layer, used to create an API for specific systems, doesnt include business logic

### Rules
- Modules cant require other modules on the same layer
- Package layer should have events, which could be used to create hooks
- Packages should be constructed as self sustaining modules, which could be used in any project with minimal external dependencies

### Application

**Application layer** is used to connect different implementations together, register modules and initialize them. This layer may include IoC, Events, Tests, as well as some parts of the business logic. E.x PlayerJoined -> Combat Actor created, StatSystem Actor created, etc

### Implementation
**Implementation layer** is used to implement a direct functionality of existing business rules. This layer can use Packages APIs to create some specific features. E.x Combat Abilities should be created in this layer

**Structure**
- **Entities** - contain implementations of Aggregates. E.x Fireball Ability should be constructed here. Entities cant require other Entities on the same layer. 

- **Handlers** - contain implementations of Packages. E.x logic, which grants the player abilities should be constructed here. Handlers cant require other Handlers on the same layer.

### Package
**Package layer** is used to create APIs for specific systems. This layer works similar to the npm packages, which means that this layer doesnt really provide any direct implementations of the logic, but instead provides an API which can be used to implement such logic

**Structure**
- **Components** contains simple logic, doesnt have a list of existing components or a id. Mostly used as an utility for Aggregates. E.x TimerComponent

- **Aggregates** contains object logic. Logic which specifies how the object should behave. Manage object's state, define methods, etc. E.x AbilityAggregate. E.x AbilityAggregate. Aggregates cant require other Aggregates on the same layer

- **Services** contains service logic. Used to operate on Aggregates. Capabale of registration, creation, deletion of Aggregates. Can be also used to link Aggregates (E.x AbilityExecutionService, which handles AbilityAggregate and ActorAggregate). Services cant require other Services on the same layer

- **API** doesnt contain any logic and instead acts as a Facade of Services or as an Adapter

