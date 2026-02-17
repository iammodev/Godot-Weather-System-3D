extends VBoxContainer

# Define presets for testing
var preset_clear: WeatherPreset
var preset_storm: WeatherPreset
var preset_rain: WeatherPreset
var preset_snow: WeatherPreset

func _ready() -> void:
	# 1. Setup Clear Weather
	preset_clear = WeatherPreset.new()
	preset_clear.preset_name = "Clear Day"
	preset_clear.weather_type = "Clear" # Important for particles
	preset_clear.sky_color = Color("4a9aff") 
	preset_clear.horizon_color = Color("a3cef1")
	preset_clear.sun_energy = 1.2
	preset_clear.ambient_energy = 0.5
	preset_clear.fog_density = 0.0
	preset_clear.ambient_sound = null
	
	# 2. Setup Storm Weather
	preset_storm = WeatherPreset.new()
	preset_storm.preset_name = "Heavy Storm"
	preset_storm.weather_type = "Thunderstorm" # Important for particles
	preset_storm.sky_color = Color("1a1a1a") 
	preset_storm.horizon_color = Color("2d2d2d")
	preset_storm.sun_energy = 0.1
	preset_storm.ambient_energy = 0.1
	preset_storm.fog_density = 0.05       
	preset_storm.fog_albedo = Color("2d2d2d")
	preset_storm.ambient_sound = load("uid://bwb2772chawtg")
	preset_storm.lightning_enabled = true

	# 3. Setup Rain Weather
	preset_rain = WeatherPreset.new()
	preset_rain.preset_name = "Rainy Day"
	preset_rain.weather_type = "Rain" # Triggers rain particles
	preset_rain.sky_color = Color("6d6d6d") # Overcast grey
	preset_rain.horizon_color = Color("7a7a7a")
	preset_rain.sun_energy = 0.5
	preset_rain.ambient_sound = load("uid://bwb2772chawtg")
	preset_rain.ambient_energy = 0.3
	preset_rain.fog_density = 0.02
	preset_rain.fog_albedo = Color("7a7a7a")
	
	# 4. Setup Snow Weather
	preset_snow = WeatherPreset.new()
	preset_snow.preset_name = "Snowy Day"
	preset_snow.weather_type = "Snow"
	preset_snow.sky_color = Color("8d9bb0") # Whiter/colder grey
	preset_snow.horizon_color = Color("9daebf")
	preset_snow.sun_energy = 0.8
	preset_snow.ambient_energy = 0.6
	preset_snow.fog_density = 0.04
	preset_snow.fog_albedo = Color("b0bace")
	preset_snow.ambient_sound = load("uid://dppfqmbhpdu6b")


	# 4. Connect Buttons
	$ButtonClear.pressed.connect(func(): 
		print("Switching to Clear...")
		WeatherManager.set_weather(preset_clear, 3.0) 
	)
	
	$ButtonStorm.pressed.connect(func(): 
		print("Switching to Storm...")
		WeatherManager.set_weather(preset_storm, 3.0) 
	)

	$ButtonRain.pressed.connect(func(): 
		print("Switching to Rain...")
		WeatherManager.set_weather(preset_rain, 3.0)
	)
	
	$ButtonSnow.pressed.connect(func(): 
		print("Switching to Snow...")
		WeatherManager.set_weather(preset_snow, 3.0)
	)
