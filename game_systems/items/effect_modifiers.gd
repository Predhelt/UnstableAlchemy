## Class representing the modifiers at each step for effect properties >= 0.0
class_name EffectModifiers extends Resource

## The modifiers for effect duration based on step. Multiplies with the [member StatusEffect.duration]
@export var durations : Array[float] = [1.0,1.0,1.0,1.0,1.0]
## The modifiers for effect value potency based on step. Multiplies with the [member StatusEffect.value]
@export var potencies : Array[float] = [1.0,1.0,1.0,1.0,1.0]
