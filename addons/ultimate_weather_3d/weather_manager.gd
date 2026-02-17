extends Node

## Core singleton for UltimateWeather3D
## Add as autoload: Project Settings > Autoload > Name: WeatherManager

signal weather_changed(new_preset: WeatherPreset)
signal transition_started(from_preset: WeatherPreset, to_preset: WeatherPreset)
signal transition_finished()

var _state_machine: WeatherStateMachine = WeatherStateMachine.new()
var _shader_globals_initialized: bool = false

## Current active preset (read-only via getter)
var current_weather: WeatherPreset:
	get: return _state_machine.current_preset


func _ready() -> void:
	_initialize_shader_globals()
	_state_machine.state_changed.connect(_on_state_changed)
	_state_machine.transition_completed.connect(_on_transition_completed)
	print("UltimateWeather3D: WeatherManager initialized")


func _process(delta: float) -> void:
	_state_machine.process_transition(delta)
	if _state_machine.is_transitioning:
		_update_interpolated_globals()


func _initialize_shader_globals() -> void:
	"""Initialize all global shader parameters if not already set"""
	
	_set_global_if_missing(WeatherTypes.SHADER_WETNESS, 0.0)
	_set_global_if_missing(WeatherTypes.SHADER_SNOW, 0.0)
	_set_global_if_missing(WeatherTypes.SHADER_WIND_DIR, Vector3.ZERO)
	_set_global_if_missing(WeatherTypes.SHADER_WIND_STRENGTH, 0.0)
	
	_shader_globals_initialized = true


func _set_global_if_missing(param_name: StringName, default_value: Variant) -> void:
	"""Helper to set global only if it doesn't exist"""
	RenderingServer.global_shader_parameter_set(param_name, default_value)


func set_weather(preset: WeatherPreset, transition_duration: float = 2.0) -> void:
	"""Change weather to a new preset with optional transition"""
	if preset == null:
		push_error("WeatherManager: Cannot set null preset")
		return
	
	_state_machine.change_weather(preset, transition_duration)


## Returns the destination preset during a transition, or null if stable
func get_target_weather() -> WeatherPreset:
	return _state_machine.target_preset

## Returns the current transition progress (0.0 to 1.0)
func get_transition_progress() -> float:
	return _state_machine.transition_progress

## Returns true if a transition is active
func is_transitioning() -> bool:
	return _state_machine.is_transitioning


func set_weather_instant(preset: WeatherPreset) -> void:
	"""Instantly switch weather (no transition)"""
	set_weather(preset, 0.0)


func _on_state_changed(old_preset: WeatherPreset, new_preset: WeatherPreset) -> void:
	transition_started.emit(old_preset, new_preset)
	weather_changed.emit(new_preset)


func _on_transition_completed() -> void:
	transition_finished.emit()


func _update_interpolated_globals() -> void:
	"""Update shader globals during transitions"""
	if not _shader_globals_initialized or _state_machine.current_preset == null:
		return
	
	var current: WeatherPreset = _state_machine.current_preset
	var target: WeatherPreset = _state_machine.target_preset
	
	if target == null:
		_apply_globals(current)
		return
	
	# Interpolate values
	var wetness: float = _state_machine.get_interpolated_value(
		current.wetness_level, target.wetness_level
	)
	var snow: float = _state_machine.get_interpolated_value(
		current.snow_coverage, target.snow_coverage
	)
	var wind_dir: Vector3 = _state_machine.get_interpolated_value(
		current.wind_direction, target.wind_direction
	)
	var wind_str: float = _state_machine.get_interpolated_value(
		current.wind_strength, target.wind_strength
	)
	
	RenderingServer.global_shader_parameter_set(WeatherTypes.SHADER_WETNESS, wetness)
	RenderingServer.global_shader_parameter_set(WeatherTypes.SHADER_SNOW, snow)
	RenderingServer.global_shader_parameter_set(WeatherTypes.SHADER_WIND_DIR, wind_dir)
	RenderingServer.global_shader_parameter_set(WeatherTypes.SHADER_WIND_STRENGTH, wind_str)


func _apply_globals(preset: WeatherPreset) -> void:
	"""Apply preset values to shader globals (non-interpolated)"""
	RenderingServer.global_shader_parameter_set(WeatherTypes.SHADER_WETNESS, preset.wetness_level)
	RenderingServer.global_shader_parameter_set(WeatherTypes.SHADER_SNOW, preset.snow_coverage)
	RenderingServer.global_shader_parameter_set(WeatherTypes.SHADER_WIND_DIR, preset.wind_direction)
	RenderingServer.global_shader_parameter_set(WeatherTypes.SHADER_WIND_STRENGTH, preset.wind_strength)
