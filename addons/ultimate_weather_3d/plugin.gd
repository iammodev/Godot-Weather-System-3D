@tool
extends EditorPlugin

const AUTOLOAD_NAME: String = "WeatherManager"
const AUTOLOAD_PATH: String = "res://addons/ultimate_weather_3d/weather_manager.gd"


func _enter_tree() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)
	print("UltimateWeather3D: Plugin enabled")


func _exit_tree() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
	print("UltimateWeather3D: Plugin disabled")
