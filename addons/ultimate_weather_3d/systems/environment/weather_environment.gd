extends Node
class_name WeatherEnvironmentController

## Controls WorldEnvironment properties based on WeatherManager state.
## Add this node to your scene and assign a WorldEnvironment.

@export var world_environment: WorldEnvironment
@export var sun_light: DirectionalLight3D

# internal cache
var _default_env: Environment

func _ready() -> void:
	if not world_environment and has_node("WorldEnvironment"):
		world_environment = get_node("WorldEnvironment")
	
	if world_environment and world_environment.environment:
		# Duplicate to avoid modifying the original resource on disk
		world_environment.environment = world_environment.environment.duplicate()
		_default_env = world_environment.environment
	else:
		push_warning("WeatherEnvironmentController: No WorldEnvironment assigned!")
		set_process(false)
		return

	# Initial update
	if WeatherManager.current_weather:
		_apply_instant(WeatherManager.current_weather)

func _process(_delta: float) -> void:
	if not WeatherManager.is_transitioning():
		return
		
	var from: WeatherPreset = WeatherManager.current_weather
	var to: WeatherPreset = WeatherManager.get_target_weather()
	var progress: float = WeatherManager.get_transition_progress()
	
	if from and to:
		_interpolate_environment(from, to, progress)

func _interpolate_environment(from: WeatherPreset, to: WeatherPreset, t: float) -> void:
	var env = world_environment.environment
	
	# 1. Sky & Ambient
	# Note: Actual Sky texture blending is complex; we interpolate colors here.
	# For procedural sky, you'd access env.sky.sky_material.
	if env.sky and env.sky.sky_material is ProceduralSkyMaterial:
		var mat = env.sky.sky_material as ProceduralSkyMaterial
		mat.sky_top_color = from.sky_color.lerp(to.sky_color, t)
		mat.sky_horizon_color = from.horizon_color.lerp(to.horizon_color, t)
		mat.ground_horizon_color = from.horizon_color.lerp(to.horizon_color, t)
	
	env.ambient_light_energy = lerpf(from.ambient_energy, to.ambient_energy, t)
	env.ambient_light_color = from.sky_color.lerp(to.sky_color, t) # Simple approximation
	
	# 2. Volumetric Fog
	# Optimization: If density is near 0, disable it? 
	# Godot 4 Volumetric Fog is expensive.
	
	env.volumetric_fog_density = lerpf(from.fog_density, to.fog_density, t)
	env.volumetric_fog_albedo = from.fog_albedo.lerp(to.fog_albedo, t)
	env.volumetric_fog_emission = from.fog_albedo * lerpf(from.fog_emission_energy, to.fog_emission_energy, t)
	
	# 3. Sun (if assigned)
	if sun_light:
		sun_light.light_energy = lerpf(from.sun_energy, to.sun_energy, t)
		# We don't rotate sun here; that's for Day/Night system

func _apply_instant(preset: WeatherPreset) -> void:
	var env = world_environment.environment
	
	if env.sky and env.sky.sky_material is ProceduralSkyMaterial:
		var mat = env.sky.sky_material as ProceduralSkyMaterial
		mat.sky_top_color = preset.sky_color
		mat.sky_horizon_color = preset.horizon_color
		mat.ground_horizon_color = preset.horizon_color
		
	env.ambient_light_energy = preset.ambient_energy
	env.ambient_light_color = preset.sky_color
	
	env.volumetric_fog_density = preset.fog_density
	env.volumetric_fog_albedo = preset.fog_albedo
	env.volumetric_fog_emission = preset.fog_albedo * preset.fog_emission_energy
	
	if sun_light:
		sun_light.light_energy = preset.sun_energy
