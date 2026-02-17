@tool
extends RefCounted
class_name WeatherShaderGlobals

## Helper to register global shader parameters in the editor
## Run this once via the plugin or a dedicated menu button

const GLOBALS = {
	"weather_wetness_level": {
		"type": "float",
		"value": 0.0
	},
	"weather_snow_height": {
		"type": "float",
		"value": 0.0
	},
	"weather_wind_direction": {
		"type": "vec3",
		"value": Vector3(1, 0, 0)
	},
	"weather_wind_strength": {
		"type": "float",
		"value": 0.0
	}
}

static func register_globals() -> void:
	print("UltimateWeather3D: Registering shader globals...")
	
	for name in GLOBALS:
		var setting_path = "shader_globals/" + name
		
		# Check if already exists to avoid overwriting custom values
		if not ProjectSettings.has_setting(setting_path):
			var data = GLOBALS[name]
			var value = {
				"type": data.type,
				"value": data.value
			}
			ProjectSettings.set_setting(setting_path, value)
			print(" + Registered: ", name)
		else:
			print(" = Skipped (exists): ", name)
	
	# Save changes to project.godot
	ProjectSettings.save()
	print("UltimateWeather3D: Globals registration complete. Restart editor if shaders fail to compile.")
