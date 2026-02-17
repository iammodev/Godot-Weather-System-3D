````markdown
# UltimateWeather3D for Godot 4.6

A high-performance, modular weather system designed for 3D games.

## Features

- **GPU Particles:** Optimized Rain & Snow with collision and camera following.
- **Volumetric Fog:** Dynamic density, color, and emission blending.
- **Day/Night Cycle:** Automatic sun rotation and sky color interpolation.
- **Interactions:**
  - **Puddles:** Decals that fade in/out based on wetness.
  - **Wind:** Physics objects react to wind direction and strength.
- **Audio:** Dynamic ambient loops and thunder.

## Setup

1. **Enable Plugin:** Go to `Project > Project Settings > Plugins` and enable "UltimateWeather3D".
2. **Add Environment:** Add `WeatherEnvironmentController` to your scene and assign your `WorldEnvironment` and `DirectionalLight3D`.
3. **Add Particles:** Add `WeatherParticleController` and ensure it has `Rain` and `Snow` GPU particle children.
4. **Control Weather:**

   ```gdscript
   # Create a preset
   var preset = WeatherPreset.new()
   preset.weather_type = "Rain"
   preset.wetness_level = 1.0

   # Apply it
   WeatherManager.set_weather(preset, 5.0) # 5s transition
   ```
````

## Requirements

- Godot 4.6+
- Forward+ Renderer (recommended for Volumetric Fog)

<img width="833" height="467" alt="image" src="https://github.com/user-attachments/assets/74f1366a-f863-47c2-a8fd-aa723ec43bf9" />
