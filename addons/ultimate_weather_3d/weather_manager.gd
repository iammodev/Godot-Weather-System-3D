extends Node

## Core singleton for UltimateWeather3D
## Add as autoload: Project Settings > Autoload > Name: WeatherManager

signal weather_changed(new_preset: WeatherPreset)
signal transition_started(from_preset: WeatherPreset, to_preset: WeatherPreset)
signal transition_finished()

var _state_machine: WeatherStateMachine = WeatherStateMachine.new()
var _shader_globals_initialized: bool = false

# --- Accumulation Settings ---
var snow_accumulation_speed: float = 0.05 
var snow_melt_speed: float = 0.1       

# --- Public Cache ---
var current_wetness_level: float = 0.0
var current_wind_direction: Vector3 = Vector3.ZERO
var current_wind_strength: float = 0.0
var current_snow_height: float = 0.0

var current_weather: WeatherPreset:
	get: return _state_machine.current_preset

func _ready() -> void:
	_initialize_shader_globals()
	# Explicitly reset snow to 0 on startup
	RenderingServer.global_shader_parameter_set(WeatherTypes.SHADER_SNOW, 0.0)
	
	_state_machine.state_changed.connect(_on_state_changed)
	_state_machine.transition_completed.connect(_on_transition_completed)
	print("UltimateWeather3D: WeatherManager initialized")

func _process(delta: float) -> void:
	_state_machine.process_transition(delta)
	
	# --- Dynamic Accumulation Logic ---
	# Determine target snow level
	var target_snow: float = 0.0
	var active_preset = _state_machine.target_preset if _state_machine.is_transitioning else _state_machine.current_preset
	
	if active_preset and active_preset.weather_type == "Snow":
		target_snow = active_preset.snow_coverage
	
	# Smoothly move towards target
	if current_snow_height != target_snow:
		var speed = snow_accumulation_speed if target_snow > current_snow_height else snow_melt_speed
		current_snow_height = move_toward(current_snow_height, target_snow, speed * delta)
		
		# Update GPU
		RenderingServer.global_shader_parameter_set(WeatherTypes.SHADER_SNOW, current_snow_height)

	if _state_machine.is_transitioning:
		_update_interpolated_globals()

func _initialize_shader_globals() -> void:
	_set_global_if_missing(WeatherTypes.SHADER_WETNESS, 0.0)
	_set_global_if_missing(WeatherTypes.SHADER_SNOW, 0.0)
	_set_global_if_missing(WeatherTypes.SHADER_WIND_DIR, Vector3.ZERO)
	_set_global_if_missing(WeatherTypes.SHADER_WIND_STRENGTH, 0.0)
	_shader_globals_initialized = true

func _set_global_if_missing(param_name: StringName, default_value: Variant) -> void:
	RenderingServer.global_shader_parameter_set(param_name, default_value)

func set_weather(preset: WeatherPreset, transition_duration: float = 2.0) -> void:
	if preset == null:
		push_error("WeatherManager: Cannot set null preset")
		return
	_state_machine.change_weather(preset, transition_duration)

func get_target_weather() -> WeatherPreset:
	return _state_machine.target_preset

func get_transition_progress() -> float:
	return _state_machine.transition_progress

func is_transitioning() -> bool:
	return _state_machine.is_transitioning

func set_weather_instant(preset: WeatherPreset) -> void:
	set_weather(preset, 0.0)

func _on_state_changed(old_preset: WeatherPreset, new_preset: WeatherPreset) -> void:
	transition_started.emit(old_preset, new_preset)
	weather_changed.emit(new_preset)

func _on_transition_completed() -> void:
	transition_finished.emit()

func _update_interpolated_globals() -> void:
	if not _shader_globals_initialized or _state_machine.current_preset == null:
		return
	
	var current = _state_machine.current_preset
	var target = _state_machine.target_preset
	if target == null:
		_apply_globals(current)
		return
	
	var wetness = _state_machine.get_interpolated_value(current.wetness_level, target.wetness_level)
	var wind_dir = _state_machine.get_interpolated_value(current.wind_direction, target.wind_direction)
	var wind_str = _state_machine.get_interpolated_value(current.wind_strength, target.wind_strength)
	
	current_wetness_level = wetness
	current_wind_direction = wind_dir
	current_wind_strength = wind_str
	
	RenderingServer.global_shader_parameter_set(WeatherTypes.SHADER_WETNESS, wetness)
	RenderingServer.global_shader_parameter_set(WeatherTypes.SHADER_WIND_DIR, wind_dir)
	RenderingServer.global_shader_parameter_set(WeatherTypes.SHADER_WIND_STRENGTH, wind_str)

func _apply_globals(preset: WeatherPreset) -> void:
	current_wetness_level = preset.wetness_level
	current_wind_direction = preset.wind_direction
	current_wind_strength = preset.wind_strength
	
	RenderingServer.global_shader_parameter_set(WeatherTypes.SHADER_WETNESS, preset.wetness_level)
	RenderingServer.global_shader_parameter_set(WeatherTypes.SHADER_WIND_DIR, preset.wind_direction)
	RenderingServer.global_shader_parameter_set(WeatherTypes.SHADER_WIND_STRENGTH, preset.wind_strength)
	
	# Reset snow cache if not snowing, or keep current.
	# We generally let _process handle snow, but if we instant-set, maybe we should respect it?
	# For gradual, we do nothing here.
