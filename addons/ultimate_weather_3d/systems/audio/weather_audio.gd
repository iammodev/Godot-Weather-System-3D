extends Node
class_name WeatherAudioManager

## Manages dynamic weather audio (ambient loops)
## Add this to your scene (e.g., as a child of Camera or WeatherManager)

@export var fade_speed: float = 2.0

# Audio Players
var _ambient_player: AudioStreamPlayer
var _current_preset: WeatherPreset
var _target_volume: float = 0.0

func _ready() -> void:
	# Create internal player
	_ambient_player = AudioStreamPlayer.new()
	_ambient_player.bus = "Weather" # Or "Weather" if you have one
	_ambient_player.name = "AmbientLoop"
	add_child(_ambient_player)
	
	# Connect to signals
	WeatherManager.weather_changed.connect(_on_weather_changed)
	WeatherManager.transition_started.connect(_on_transition_started)

func _process(delta: float) -> void:
	# Smooth volume transition
	if _ambient_player.playing:
		var current_db = _ambient_player.volume_db
		var target_db = linear_to_db(_target_volume)
		
		# Avoid log(0) errors
		if _target_volume <= 0.001:
			target_db = -80.0
		
		_ambient_player.volume_db = move_toward(current_db, target_db, delta * fade_speed * 10.0)
		
		# Stop if silent
		if _ambient_player.volume_db <= -79.0 and _target_volume <= 0.001:
			_ambient_player.stop()

func _on_transition_started(from: WeatherPreset, to: WeatherPreset) -> void:
	# If stream changes, we might need cross-fading logic.
	# For simplicity V1: We just fade volume.
	# If you want true cross-fading between different clips, you need 2 players.
	# Here we assume 1 ambient track per preset for now.
	
	if to.ambient_sound != _ambient_player.stream:
		# If sound is different, we must stop and swap (or crossfade with 2 players)
		# Improved Single Player Logic:
		if to.ambient_sound:
			_ambient_player.stream = to.ambient_sound
			_ambient_player.play()
			_target_volume = to.ambient_sound_volume
		else:
			_target_volume = 0.0
	else:
		# Same sound, just volume change
		_target_volume = to.ambient_sound_volume

func _on_weather_changed(preset: WeatherPreset) -> void:
	_current_preset = preset
	# Ensure volume is correct at end of transition
	_target_volume = preset.ambient_sound_volume
