extends Node3D

@export var target_camera: Camera3D
@export var thunder_sound: AudioStreamPlayer

var _timer: float = 0.0
var _next_strike: float = 10.0

func _ready() -> void:
	if not target_camera:
		target_camera = get_viewport().get_camera_3d()

func _process(delta: float) -> void:
	var current = WeatherManager.current_weather
	if not current or not current.lightning_enabled: 
		return
	
	_timer += delta
	if _timer >= _next_strike:
		_strike()
		_timer = 0.0
		# Randomize next interval (e.g., 2.5s to 7.5s if base is 5.0)
		var base_interval = current.lightning_interval
		_next_strike = randf_range(base_interval * 0.5, base_interval * 1.5)

func _strike() -> void:
	if not target_camera: return
	
	# 1. Calculate Ground Hit Position (In front of camera)
	var forward = -target_camera.global_transform.basis.z
	var right = target_camera.global_transform.basis.x
	
	# Randomize hit point:
	# Distance: 50m to 300m away
	# Offset: -100m to 100m left/right
	var dist = randf_range(50.0, 300.0)
	var offset_x = randf_range(-100.0, 100.0)
	
	var strike_pos = target_camera.global_position + (forward * dist) + (right * offset_x)
	strike_pos.y = 0.0 # Force ground level
	
	# 2. Calculate Sky Start Position
	# It should be almost directly above the strike, but slightly offset to look dynamic.
	# Height: 150m to 250m (Way up in the sky!)
	var sky_pos = strike_pos
	sky_pos.y = randf_range(450.0, 750.0)
	sky_pos.x += randf_range(-30.0, 30.0) # Slight tilt
	sky_pos.z += randf_range(-30.0, 30.0)
	
	# 3. Spawn Visual Bolt
	var bolt = LightningBolt.new()
	add_child(bolt)
	
	# Generate jagged mesh
	# segments=25 (more detail), jaggedness=8.0 (wilder arcs), width=2.0 (thick core)
	bolt.generate(sky_pos, strike_pos, 25, 8.0, 2.0)
	
	# 4. Light Flash (Illumination)
	var flash = OmniLight3D.new()
	add_child(flash)
	# Place light 20m above ground so it lights up the floor nicely
	flash.global_position = strike_pos + Vector3(0, 20, 0)
	flash.omni_range = 500.0
	flash.light_energy = 0.0
	flash.light_color = Color(0.8, 0.9, 1.0) # Blue-white
	
	# Flash Animation
	var tween = create_tween()
	tween.tween_property(flash, "light_energy", 50.0, 0.05) # Instant Bright
	tween.tween_property(flash, "light_energy", 0.0, 0.3)  # Fast Fade
	tween.tween_callback(flash.queue_free)
	
	# 5. Handle Thunder Audio
	# Speed of sound ~340 m/s
	var delay = dist / 340.0
	
	if thunder_sound and thunder_sound.stream:
		# Create a one-shot timer for the sound
		get_tree().create_timer(delay).timeout.connect(func():
			# Clone player to allow overlapping thunders if strikes are close
			var sfx = thunder_sound.duplicate()
			add_child(sfx)
			sfx.pitch_scale = randf_range(0.8, 1.2) # Vary pitch for realism
			sfx.play()
			sfx.finished.connect(sfx.queue_free)
		)
		print("Lightning Strike! Dist: %d m | Delay: %.2f s" % [int(dist), delay])
	else:
		push_warning("LightningGenerator: No thunder sound assigned!")
