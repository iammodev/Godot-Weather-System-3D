extends Node
class_name DayNightCycle

@export var sun_light: DirectionalLight3D
@export var day_length: float = 120.0 # Seconds per game-day
@export var start_time: float = 0.3 # 0.0 = Midnight, 0.5 = Noon

var time_of_day: float = 0.0 # 0.0 to 1.0

func _ready() -> void:
	time_of_day = start_time
	if not sun_light:
		push_warning("DayNightCycle: Sun Light not assigned!")

func _process(delta: float) -> void:
	if day_length > 0:
		time_of_day += delta / day_length
		if time_of_day >= 1.0:
			time_of_day -= 1.0 # Loop
	
	_update_sun_position()

func _update_sun_position() -> void:
	if not sun_light: return
	
	# Map 0.0-1.0 to rotation
	# 0.0 (Midnight) -> -90 deg (down)
	# 0.25 (Sunrise) -> 0 deg (horizon)
	# 0.5 (Noon) -> 90 deg (up)
	# 0.75 (Sunset) -> 180 deg (horizon)
	
	var angle = (time_of_day * 360.0) - 90.0
	sun_light.rotation_degrees.x = -angle # Negative because Godot X rotation is pitch
