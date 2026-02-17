extends Node3D
class_name WeatherListener

## Attach this as a CHILD of a RigidBody3D to make it react to wind.
## Usage: The parent node MUST be a RigidBody3D.

@export var wind_multiplier: float = 1.0
@export var randomness: float = 0.5

var _parent_body: RigidBody3D
var _noise: FastNoiseLite

func _ready() -> void:
	# 1. Verify parent is a physics body
	_parent_body = get_parent() as RigidBody3D
	if not _parent_body:
		push_warning("WeatherListener: Parent must be a RigidBody3D!")
		set_physics_process(false)
		return
	
	# 2. Setup noise for turbulence (so wind isn't perfectly constant)
	_noise = FastNoiseLite.new()
	_noise.frequency = 0.5
	_noise.seed = randi() # Random seed for variety

func _physics_process(delta: float) -> void:
	# 3. Get global wind data (Cached in WeatherManager for performance)
	# DO NOT use RenderingServer.global_shader_parameter_get() here!
	var wind_dir = WeatherManager.current_wind_direction
	var wind_str = WeatherManager.current_wind_strength
	
	# Optimization: Don't calculate if no wind
	if wind_str <= 0.01:
		return
		
	# 4. Calculate Force
	var time = Time.get_ticks_msec() / 1000.0
	var turbulence = _noise.get_noise_3d(global_position.x, global_position.y, time)
	
	# Force = Direction * Strength * Multiplier * (Randomness)
	var final_force = (wind_dir as Vector3) * wind_str * wind_multiplier
	final_force *= (1.0 + turbulence * randomness)
	
	# 5. Apply to parent
	# We use central force for simple pushing
	_parent_body.apply_central_force(final_force * delta * 50.0) 
