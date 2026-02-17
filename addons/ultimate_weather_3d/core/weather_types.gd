class_name WeatherTypes
extends RefCounted

## Global constants and enumerations for the weather system

enum WeatherType {
	CLEAR,
	RAIN,
	SNOW,
	HAIL,
	THUNDERSTORM,
	FOG,
	MIST,
	SANDSTORM,
	HURRICANE
}

enum Season {
	SPRING,
	SUMMER,
	AUTUMN,
	WINTER
}

# Shader global parameter names (must match Project Settings)
const SHADER_WETNESS: StringName = &"weather_wetness_level"
const SHADER_SNOW: StringName = &"weather_snow_height"
const SHADER_WIND_DIR: StringName = &"weather_wind_direction"
const SHADER_WIND_STRENGTH: StringName = &"weather_wind_strength"

# Performance constants
const MAX_PARTICLES: int = 10000
const PARTICLE_LIFETIME: float = 10.0
const WIND_UPDATE_RATE: float = 0.1  # Update wind every 0.1s for physics
