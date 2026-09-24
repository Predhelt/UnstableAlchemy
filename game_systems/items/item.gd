class_name Item extends Resource

## The type that the item is. By default, the type is "Item"
var type : String = "Item"
##
## IDs for unique items. -1 is unused. 0-99 are raw ingredients.
## 100-199 are simple produced ingredients. 200-299 are complex ingredients
## that require more than one craft. 500+ are Potions. 999 is the failed craft item
##
@export var id : int
## Name shown to the player.
@export var display_name := ""
## Description shown to the player.
@export var description := "" 
## Image of the item.
@export var texture : Texture2D 
## The primary color of the item. Used for what color to fill the dropper.
@export_enum("red", "orange", "green", "yellow", "blue", "cyan", "purple", "brown", "black", "gray", "white") var primary_color : String = "green"
## Sound when the item is used in the [Inventory].
@export_enum("eat", "drink", "read", "equip") var use_sound : String = "eat"
## The maximum amount of the item that can be stacked in one slot in the inventory.
@export var max_qty := 10 
## Tracks the current amount of the item either in the inventory slot or in the object the item is contained in.
@export var qty := 1 
## Events that get triggered when the item is consumed.
## The keys are the strings representing the name of the callable function in the EventHandler
## and the value array is the list of parameters of the function.
@export var on_consume_events : Dictionary[String,Array]
## Status effects that are emitted to the player when the player samples or consumes the item.
@export var on_consume_effects : Array[StatusEffect] 
## The message that the player emits when the item is consumed, relating to the effects of the item.
@export var on_consume_message := "" 
### 
#@export var conditions : Array[ItemCondition]

##@experimental
# Option 1
#@export var default_properties : Array[ItemProperty]
#@export var bellow_properties : Array[ItemProperty]
#@export var stewed_properties : Array[ItemProperty]
#@export var bellowed_and_stewed : Array[ItemProperty]

#Option 2: Recursive item creation
#@export var grinded_item : Item
#@export var crushed_item : Item
#@export var stewed_item : Item #NOTE: Stewed item state change should be done 
		# before the next precision window to avoid any ordering inconsistencies
#@export var bellows_item : Item

#Option 3: Effect Modifiers. Per Effect.
### Dictionary[Dictionary[Array[float]] 
### modifier_name[element_id][elemend_property_name] = [modifier_at_step1, modifier_at_step2, ..., modifier_at_step5]
### ex: grind_modifer[4].duration = [0.1, 0.3, 0.8, 1.5, 0.5]
#@export_group("Modifiers")
### Key: [StatusEffect] ID, returns [EffectModifiers] for each crush step the given status effect.
#@export var crush_modifiers : Dictionary[int, EffectModifiers]
#@export_range(0,4) var cur_crush_step := 0
### Key: [StatusEffect] ID, returns [EffectModifiers] for each grind step the given status effect.
#@export var grind_modifiers : Dictionary[int, EffectModifiers]
#@export_range(0,4) var cur_grind_step := 0
### Key: [StatusEffect] ID, returns [EffectModifiers] for each stew step the given status effect.
#@export var stew_modifiers : Dictionary[int, EffectModifiers]
#@export_range(0,4) var cur_stew_step := 0
### Key: [StatusEffect] ID, returns [EffectModifiers] for each bellow step the given status effect.
#@export var bellow_modifiers : Dictionary[int, EffectModifiers]
#@export_range(0,4) var cur_bellow_step := 0
#
### Action types: "crush", "grind", "stew", "bellow".
### When step = -1, the action step will be incremented by 1. 
### Otherwise, the step will be set to the given index between 0 and 4.
### Invalid indices will not change the current step. If the step is already at index 4,
### checks will be made for conditional status effects without increasing the current step.
#func update_step(action_type : String, step : int = -1) -> void:
	##TODO: Test if dictionary value variables are updating the reference.
	##var action_steps : Dictionary[String, int] = {
		##"grind" : cur_grind_step,
		##"crush" : cur_crush_step,
		##"stew" : cur_stew_step,
		##"bellow" : cur_bellow_step
	##}
	##action_steps[action_type] = _get_step(action_steps[action_type], step)
	#match action_type:
		#"crush":
			#cur_crush_step = _get_step(cur_crush_step, step)
		#"grind":
			#cur_grind_step = _get_step(cur_grind_step, step)
		#"stew":
			#cur_stew_step =  _get_step(cur_stew_step, step)
		#"bellow":
			#cur_bellow_step =  _get_step(cur_bellow_step, step)
	#
	##TODO: Check conditional effects after update
	#check_conditional_effects()
#
### Returns the [param cur_step] to the given [param step]. If step = -1, increments.
#func _get_step(cur_step, step) -> int:
	#if step == -1 and cur_step < 4:
		#return cur_step + 1
	#elif step >= 0 and step <= 4:
		#return step
	#return cur_step
#
### Checks [member conditions] to see if comparisons are satisfied. If so, apply conditions.
#func check_conditional_effects():
	#for condition in conditions:
		#var is_condition_met : bool = true
		#for c in condition.comparisions:
			#match c.comparator:
				#"<":
					#var p : int = _get_action_step(c.property)
					#if p >= c.value:
						#is_condition_met = false
						#break
				#"=":
					#var p : int = _get_action_step(c.property)
					#if p != c.value:
						#is_condition_met = false
						#break
				#">":
					#var p : int = _get_action_step(c.property)
					#if p <= c.value:
						#is_condition_met = false
						#break
		#if not is_condition_met:
			#break
		#_set_condition(condition)
#
### Returns the current step of the modifier for the given property name.
#func _get_action_step(property : String) -> int:
	#match property:
		#"crush":
			#return cur_crush_step
		#"grind":
			#return cur_grind_step
		#"stew":
			#return cur_stew_step
		#"bellow":
			#return cur_bellow_step
	#return -1
#
#
#func _set_condition(condition : ItemCondition):
	## Add effects
	#for e in condition.effects_added:
		#for i in range(len(on_consume_effects)):
			#if on_consume_effects[i].id == e.id:
				#on_consume_effects.remove_at(i) #TODO: Determine if the old effects should always be removed in favor of new effects
				#break
		#on_consume_effects.append(e)
	## Remove effects
	#for e in condition.effects_removed:
		#for i in range(len(on_consume_effects)):
			#if on_consume_effects[i].id == e.id:
				#on_consume_effects.remove_at(i)
				#break
	## Add events
	#for e in condition.events_added:
		#for cur_event in on_consume_events:
			#if cur_event == e:
				#on_consume_events.erase(e)
				#break
		#on_consume_events[e] = #TODO: Change event to be a data type?
	## Remove events
	#for e in condition.events_removed:
		#for cur_event in on_consume_events:
			#if cur_event == e:
				#on_consume_events.erase(e)
				#break
