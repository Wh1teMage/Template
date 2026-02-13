# Skill
- some states should have an ability to be called from the client
- make something with replication (E.x if the state could be called directly from the client then ignore replication)
- skills should have attributes (to change config dynamically)
- skills should have tags?

# Attributes
- have a DefaultValue, which is readonly + a Modified value, which represents a real value
- must be in attribute sets
```lua
Object: { ..., Attributes: { [string]: { Default: number, Modified: number }}}
-- ^ should include metatable so that we can access attribute values directly
- all of the changes can be performed only using StatusEffects (setter is avaliable only by the statusEffect)
```
- Attribute should contain methods to control its values
- should we store them as a queue of changes or as an exact value?
- could either be a data object with a few methods or a constructor + new (so we could set custom methods)

# AttributeSet
- contain attributes based on the context
```lua
Object: { ..., Attributes: { [string]: AttributeSet<Attribute> } }
```
- should contain Name field?
- handles AttributeAdded/AttributeRemoved/AttributeChanged event?

# Tags
- represent a boolean
```lua
Object: { ..., Tags: { [string]: boolean }}
```
-- ^ should also have a metatable, which allows direct access to the field
- can be changed only by Object?

# Status Effect
- works as a skill (constructor + new methods)
- has methods to modify attributes and tags
- override methods contain logic to modify attributes using API?
- .new(attribute: Attribute)
- ^ so that we can modify the selected attribute, selected within the instance constructor
- has Apply and Remove methods
- ^ these should be separated
- some kind of AttributeController, which will act as an API to change attributes
- StatusEffect by itself operates on the Attributes using API on the Application layer
- similar to how skills operate with the attributes (not in the abstract class, but instead in the implementation)
- maybe status effect should operate on the whole actor, instead of a singular attribute?

# Global
- replication should be handled using default remote event + dedicated serialization
- we only need to replicate the state, which means that overall bandwidth for enums will be small
