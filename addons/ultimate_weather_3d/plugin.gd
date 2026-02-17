@tool
extends EditorPlugin

const AUTOLOAD_NAME: String = "WeatherManager"
const AUTOLOAD_PATH: String = "res://addons/ultimate_weather_3d/weather_manager.gd"

func _enter_tree() -> void:
	# 1. Register Globals first
	var shader_globals_script = load("res://addons/ultimate_weather_3d/shaders/globals/weather_shader_globals.gd")
	if shader_globals_script:
		shader_globals_script.register_globals()
	
	# 2. Add Autoload
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)
	print("UltimateWeather3D: Plugin enabled")

func _exit_tree() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
	print("UltimateWeather3D: Plugin disabled")
