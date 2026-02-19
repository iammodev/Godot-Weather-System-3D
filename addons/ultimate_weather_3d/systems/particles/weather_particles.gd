extends Node3D
class_name WeatherParticleController

## Manages precipitation particles dynamically based on node names.
## Add GPUParticles3D children named exactly like the WeatherType (e.g., "Rain", "Snow", "Hail").

@export var target_camera: Camera3D
@export var follow_camera: bool = true

# Dictionary mapping weather_type (String) -> GPUParticles3D node
var _particle_systems: Dictionary = {}
var _current_preset: WeatherPreset

func _ready() -> void:
	if not target_camera:
		target_camera = get_viewport().get_camera_3d()
	
	# 1. Dynamically register all GPUParticles3D children
	for child in get_children():
		if child is GPUParticles3D:
			# The node name becomes the key (e.g., "Rain", "Snow", "Sandstorm")
			_particle_systems[child.name] = child
			print("WeatherParticleController: Registered system for '%s'" % child.name)
			
			# Ensure they start off
			child.emitting = false
			child.amount_ratio = 0.0

func _process(delta: float) -> void:
	_update_position()

	if WeatherManager.is_transitioning():
		_blend_particles(
			WeatherManager.current_weather, 
			WeatherManager.get_target_weather(), 
			WeatherManager.get_transition_progress()
		)
	elif WeatherManager.current_weather != _current_preset:
		_apply_preset(WeatherManager.current_weather)

func _update_position() -> void:
	if not follow_camera or not target_camera:
		return
	global_position = target_camera.global_position
	global_position.y += 10.0 

func _apply_preset(preset: WeatherPreset) -> void:
	if not preset: return
	_current_preset = preset
	
	var type = preset.weather_type
	
	# Loop through all registered systems
	for sys_name in _particle_systems:
		var particles = _particle_systems[sys_name]
		
		# Match logic: 
		# 1. Exact match (e.g. Node "Rain" matches Preset "Rain")
		# 2. Special case: "Thunderstorm" activates "Rain" if no "Thunderstorm" particles exist
		var should_emit = (sys_name == type)
		
		if type == "Thunderstorm" and sys_name == "Rain":
			should_emit = true
		
		if should_emit:
			if not particles.emitting: particles.emitting = true
			particles.amount_ratio = 1.0
		else:
			particles.emitting = false
			particles.amount_ratio = 0.0

func _blend_particles(from: WeatherPreset, to: WeatherPreset, t: float) -> void:
	var from_type = from.weather_type if from else ""
	var to_type = to.weather_type if to else ""
	
	for sys_name in _particle_systems:
		var particles = _particle_systems[sys_name]
		
		# Determine if this system is active in 'from' or 'to' states
		var active_in_from = (sys_name == from_type) or (from_type == "Thunderstorm" and sys_name == "Rain")
		var active_in_to = (sys_name == to_type) or (to_type == "Thunderstorm" and sys_name == "Rain")
		
		if active_in_to and not active_in_from:
			# Fading IN
			if not particles.emitting: particles.emitting = true
			particles.amount_ratio = t
		elif active_in_from and not active_in_to:
			# Fading OUT
			particles.amount_ratio = 1.0 - t
			if t >= 0.99: particles.emitting = false
		elif active_in_to and active_in_from:
			# Staying ON
			particles.amount_ratio = 1.0
		else:
			# Staying OFF
			particles.emitting = false
