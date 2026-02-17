extends Decal

## Controls puddle visibility based on global wetness
## Requires WeatherManager singleton to be active

func _process(delta: float) -> void:
	# Read from the local variable in WeatherManager (CPU fast access)
	# This avoids the "RenderingServer.global_shader_parameter_get" performance warning
	var wetness = WeatherManager.current_wetness_level
	
	# We want puddles to start appearing when wetness > 0.2
	# (wetness - 0.2) / 0.8 maps the range [0.2, 1.0] to [0.0, 1.0]
	var target_mix = clamp((wetness - 0.2) / 0.8, 0.0, 1.0)
	
	# Smoothly interpolate the decal opacity
	# albedo_mix controls how opaque the decal is (0 = invisible, 1 = fully visible)
	albedo_mix = lerpf(albedo_mix, target_mix, delta * 2.0)
