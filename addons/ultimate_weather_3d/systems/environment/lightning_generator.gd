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
		# Randomize next interval
		var base_interval = current.lightning_interval
		_next_strike = randf_range(base_interval * 0.5, base_interval * 1.5)

func _strike() -> void:
	if not target_camera: return
	
	# 1. Calculate random position relative to camera
	var dist = randf_range(50.0, 150.0)
	var angle = randf_range(-PI, PI) # Full circle
	# Ensure it's somewhat in front (optional, remove abs if you want 360)
	if abs(angle) > PI/2: angle = angle * 0.5 
	
	var offset = Vector3(sin(angle), 0.0, cos(angle)) * dist
	var pos = target_camera.global_position + offset
	pos.y += randf_range(20.0, 40.0) # High up in the sky
	
	# 2. Create Visual Flash (OmniLight3D)
	var flash = OmniLight3D.new()
	add_child(flash)
	flash.global_position = pos
	flash.light_energy = 0.0
	flash.omni_range = 300.0   # FIXED: Changed from light_range to omni_range
	flash.light_color = Color(0.8, 0.9, 1.0) # Blue-white
	
	# Animation: Flash -> Fade
	var tween = create_tween()
	tween.tween_property(flash, "light_energy", 20.0, 0.05) # Instant bright
	tween.tween_property(flash, "light_energy", 0.0, 0.3)  # Fast fade
	tween.tween_callback(flash.queue_free)
	
	# 3. Handle Thunder (Delayed Sound)
	var delay = dist / 340.0
	
	if thunder_sound and thunder_sound.stream:
		# Create a temporary timer for the sound
		get_tree().create_timer(delay).timeout.connect(func():
			# Clone player to allow overlapping thunders
			var sfx = thunder_sound.duplicate()
			add_child(sfx)
			sfx.pitch_scale = randf_range(0.8, 1.2)
			sfx.play()
			sfx.finished.connect(sfx.queue_free)
		)
	
	print("Lightning struck at distance: ", int(dist), "m. Thunder in: ", snapped(delay, 0.01), "s")
