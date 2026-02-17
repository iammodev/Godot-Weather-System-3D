extends Node3D
class_name WeatherParticleController

## Manages precipitation particles (Rain/Snow)
## Attach this to a Node3D that holds your GPUParticles3D children

@export var target_camera: Camera3D
@export var follow_camera: bool = true

# Child nodes (assign in editor or find dynamically)
@onready var rain_particles: GPUParticles3D = $Rain
@onready var snow_particles: GPUParticles3D = $Snow

# Internal state
var _current_preset: WeatherPreset

func _ready() -> void:
	# Find camera if not assigned
	if not target_camera:
		target_camera = get_viewport().get_camera_3d()

func _process(delta: float) -> void:
	_update_position()


	# Check for weather updates
	if WeatherManager.is_transitioning():
		var from = WeatherManager.current_weather
		var to = WeatherManager.get_target_weather()
		var progress = WeatherManager.get_transition_progress()
		_blend_particles(from, to, progress)
	elif WeatherManager.current_weather != _current_preset:
		if WeatherManager.current_weather:
			print("WeatherParticleController: New preset detected: ", WeatherManager.current_weather.weather_type)
			_apply_preset(WeatherManager.current_weather)
		else:
			print("WeatherParticleController: Current weather is null!")


func _update_position() -> void:
	if not follow_camera or not target_camera:
		return
		
	# Snap to camera position but keep global rotation aligned with up
	global_position = target_camera.global_position
	# Offset upwards so rain falls *past* the camera, not starting inside it
	global_position.y += 10.0 

func _apply_preset(preset: WeatherPreset) -> void:
	_current_preset = preset
	# Basic switching logic - can be expanded
	if preset.weather_type == "Rain" or preset.weather_type == "Thunderstorm":
		rain_particles.emitting = true
		snow_particles.emitting = false
		rain_particles.amount_ratio = 1.0
	elif preset.weather_type == "Snow":
		rain_particles.emitting = false
		snow_particles.emitting = true
		snow_particles.amount_ratio = 1.0
	else:
		rain_particles.emitting = false
		snow_particles.emitting = false

func _blend_particles(from: WeatherPreset, to: WeatherPreset, t: float) -> void:
	# Complex blending: crossfade amount_ratio
	# This is a simplified approach. Ideally, you modulate transparency/amount.
	
	var is_raining_to = (to.weather_type in ["Rain", "Thunderstorm"])
	var is_snowing_to = (to.weather_type == "Snow")
	
	# Rain Logic
	if is_raining_to:
		if not rain_particles.emitting: rain_particles.emitting = true
		rain_particles.amount_ratio = t
	elif rain_particles.emitting:
		rain_particles.amount_ratio = 1.0 - t
		if t >= 0.99: rain_particles.emitting = false
		
	# Snow Logic
	if is_snowing_to:
		if not snow_particles.emitting: snow_particles.emitting = true
		snow_particles.amount_ratio = t
	elif snow_particles.emitting:
		snow_particles.amount_ratio = 1.0 - t
		if t >= 0.99: snow_particles.emitting = false
