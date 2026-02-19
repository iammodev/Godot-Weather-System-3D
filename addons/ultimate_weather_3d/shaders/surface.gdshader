shader_type spatial;

// Include our weather logic
#include "res://addons/ultimate_weather_3d/shaders/includes/weather_surface.gdshaderinc"

uniform vec3 base_color : source_color = vec3(0.2, 0.5, 0.2); // Green Grass

void fragment() {
    // 1. Set Base Properties
    ALBEDO = base_color;
    ROUGHNESS = 0.8;
    METALLIC = 0.0;
    
    // 2. Calculate World Normal (Critical for Snow)
    // Godot provides NORMAL in View Space. We need World Space.
    vec3 normal_world = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
    
    // 3. Apply Weather
    apply_weather(ALBEDO, ROUGHNESS, METALLIC, normal_world);
}
