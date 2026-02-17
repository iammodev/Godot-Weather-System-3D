@tool
class_name WeatherPreset
extends Resource

## Defines a complete weather configuration

@export_group("Identification")
@export var preset_name: String = "Clear"
@export_enum("Clear", "Rain", "Snow", "Hail", "Thunderstorm", "Fog", "Mist", "Sandstorm", "Hurricane") 
var weather_type: String = "Clear"

@export_group("Environment")
@export var sky_color: Color = Color(0.4, 0.6, 1.0)
@export var horizon_color: Color = Color(0.6, 0.7, 0.9)
@export_range(0.0, 16.0) var sun_energy: float = 1.0
@export_range(0.0, 5.0) var ambient_energy: float = 1.0

@export_group("Volumetric Fog")
@export_range(0.0, 1.0) var fog_density: float = 0.0
@export var fog_albedo: Color = Color(0.8, 0.8, 0.8)
@export_range(0.0, 1.0) var fog_emission_energy: float = 0.0

@export_group("Precipitation")
@export_range(0, 10000) var particle_amount: int = 0
@export_range(0.0, 100.0) var particle_speed: float = 0.0
@export var particle_texture: Texture2D = null

@export_group("Wind")
@export var wind_direction: Vector3 = Vector3.ZERO
@export_range(0.0, 50.0) var wind_strength: float = 0.0
@export_range(0.0, 10.0) var wind_turbulence: float = 0.0

@export_group("Surface Effects")
@export_range(0.0, 1.0) var wetness_level: float = 0.0
@export_range(0.0, 1.0) var snow_coverage: float = 0.0

@export_group("Audio")
@export var ambient_sound: AudioStream = null
@export_range(0.0, 1.0) var ambient_sound_volume: float = 0.5
@export_range(0.5, 2.0) var ambient_sound_pitch: float = 1.0

@export_group("Lightning (Thunderstorm)")
@export var lightning_enabled: bool = false
@export_range(0.1, 30.0) var lightning_interval: float = 5.0
