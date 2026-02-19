extends VBoxContainer

## Dynamically generates buttons for testing weather presets

var _generated_presets: Array[WeatherPreset] = []

func _ready() -> void:
	for child in get_children():
		child.queue_free()
	_create_default_presets()
	for preset in _generated_presets:
		var btn = Button.new()
		btn.text = preset.preset_name
		btn.pressed.connect(_on_preset_clicked.bind(preset))
		add_child(btn)

func _on_preset_clicked(preset: WeatherPreset) -> void:
	print("UI: Switching to ", preset.preset_name)
	WeatherManager.set_weather(preset, 3.0)

func _create_default_presets() -> void:
	# -- Clear --
	var p1 = WeatherPreset.new()
	p1.preset_name = "Clear Day"
	p1.weather_type = "Clear"
	p1.sky_color = Color("4a9aff") 
	p1.horizon_color = Color("a3cef1")
	p1.sun_energy = 1.2
	p1.ambient_energy = 0.5
	_generated_presets.append(p1)
	
	# -- Rain --
	var p2 = WeatherPreset.new()
	p2.preset_name = "Rain"
	p2.weather_type = "Rain"
	p2.sky_color = Color("6d6d6d")
	p2.horizon_color = Color("7a7a7a")
	p2.sun_energy = 0.5
	p2.fog_density = 0.02
	p2.wetness_level = 1.0 
	p2.ambient_sound = load("uid://bwb2772chawtg")
	_generated_presets.append(p2)
	
	# -- Storm --
	var p3 = WeatherPreset.new()
	p3.preset_name = "Storm"
	p3.weather_type = "Thunderstorm"
	p3.sky_color = Color("1a1a1a")
	p3.horizon_color = Color("2d2d2d")
	p3.fog_density = 0.05
	p3.wetness_level = 1.0
	p3.lightning_enabled = true
	p3.wind_strength = 10.0
	p3.wind_direction = Vector3(1, 0, 0)
	p3.ambient_sound = load("uid://bwb2772chawtg")
	_generated_presets.append(p3)
	
	# -- Snow --
	var p4 = WeatherPreset.new()
	p4.preset_name = "Snow"
	p4.weather_type = "Snow"
	p4.sky_color = Color("8d9bb0")
	p4.horizon_color = Color("9daebf")
	p4.snow_coverage = 1.0 
	p4.ambient_sound = load("uid://dppfqmbhpdu6b")
	_generated_presets.append(p4)
	
	# -- Hail --
	var p5 = WeatherPreset.new()
	p5.preset_name = "Hail"
	p5.weather_type = "Hail"
	p5.sky_color = Color("5d6b80")
	p5.wind_strength = 5.0
	_generated_presets.append(p5)
	
	# -- Sandstorm --
	var p6 = WeatherPreset.new()
	p6.preset_name = "Sandstorm"
	p6.weather_type = "Sandstorm"
	p6.sky_color = Color("c2a386")
	p6.fog_density = 0.1
	p6.fog_albedo = Color("c2a386")
	p6.wind_strength = 20.0
	p6.wind_direction = Vector3(1, 0, 0)
	p6.ambient_sound = load("uid://smpbm2lrochm")
	_generated_presets.append(p6)
