class_name WeatherStateMachine
extends RefCounted

## Manages transitions between weather states

signal state_changed(old_preset: WeatherPreset, new_preset: WeatherPreset)
signal transition_completed()

var current_preset: WeatherPreset = null
var target_preset: WeatherPreset = null

var is_transitioning: bool = false
var transition_progress: float = 0.0
var transition_duration: float = 0.0  # 0 = instant


func change_weather(new_preset: WeatherPreset, duration: float = 0.0) -> void:
	"""Request a weather change with optional transition duration"""
	if new_preset == null:
		push_error("WeatherStateMachine: Attempted to change to null preset")
		return
	
	var old_preset: WeatherPreset = current_preset
	target_preset = new_preset
	transition_duration = max(0.0, duration)
	
	if transition_duration <= 0.0:
		# Instant transition
		current_preset = new_preset
		is_transitioning = false
		transition_progress = 1.0
		state_changed.emit(old_preset, current_preset)
		transition_completed.emit()
	else:
		# Gradual transition
		is_transitioning = true
		transition_progress = 0.0
		state_changed.emit(old_preset, target_preset)


func process_transition(delta: float) -> void:
	"""Call this every frame from WeatherManager"""
	if not is_transitioning or target_preset == null:
		return
	
	transition_progress += delta / transition_duration
	
	if transition_progress >= 1.0:
		transition_progress = 1.0
		current_preset = target_preset
		is_transitioning = false
		transition_completed.emit()


func get_interpolated_value(current_val: Variant, target_val: Variant) -> Variant:
	"""Lerp between current and target based on transition progress"""
	if not is_transitioning:
		return current_val if current_preset != null else target_val
	
	var t: float = transition_progress
	
	# Type-specific interpolation
	if current_val is float:
		return lerpf(current_val, target_val, t)
	elif current_val is Color:
		return current_val.lerp(target_val, t)
	elif current_val is Vector3:
		return current_val.lerp(target_val, t)
	else:
		# For non-interpolatable types, switch at 50% progress
		return target_val if t >= 0.5 else current_val
