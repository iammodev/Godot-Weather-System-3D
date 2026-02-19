// Weather Surface Include
// Usage: #include "res://addons/ultimate_weather_3d/shaders/includes/weather_surface.gdshaderinc"
// Call apply_weather(ALBEDO, ROUGHNESS, METALLIC, NORMAL, VIEW_MATRIX);

global uniform float weather_wetness_level;
global uniform float weather_snow_height;

void apply_weather(inout vec3 albedo, inout float roughness, inout float metallic, vec3 normal_world) {
    // 1. Wetness (Darken + Shiny)
    float wetness = clamp(weather_wetness_level, 0.0, 1.0);
    
    if (wetness > 0.0) {
        // Darken Albedo (water absorbs light)
        // Lerp towards a darker version of the base color
        albedo *= mix(1.0, 0.5, wetness);
        
        // Reduce Roughness (water is smooth)
        // Wet surfaces are smoother, but not perfectly mirror-like everywhere
        roughness = mix(roughness, 0.05, wetness * 0.8); 
        
        // Increase Metallic slightly for reflection (approximate dielectric water reflection)
        metallic = mix(metallic, 0.2, wetness * 0.5);
    }
    
    // 2. Snow Accumulation (White on top)
    float snow_amount = clamp(weather_snow_height, 0.0, 1.0);
    
    if (snow_amount > 0.0) {
        // Check if surface points up (dot product with Up Vector)
        float up_dot = dot(normal_world, vec3(0.0, 1.0, 0.0));
        
        // Threshold for snow (e.g., surfaces flatter than 45 degrees)
        // Expand coverage as snow_amount increases
        // snow_amount 0.1 -> threshold 0.9 (only very flat tops)
        // snow_amount 1.0 -> threshold 0.2 (steep slopes get snow too)
        float snow_threshold = 0.6 - (snow_amount * 0.4); 
        
        // Smooth transition for soft edges
        float snow_mask = smoothstep(snow_threshold, snow_threshold + 0.1, up_dot);
        
        vec3 snow_color = vec3(0.9, 0.95, 1.0); // Slightly blueish white
        
        // Blend snow on top
        albedo = mix(albedo, snow_color, snow_mask);
        
        // Snow properties
        roughness = mix(roughness, 0.9, snow_mask); // Snow is rough/diffuse
        metallic = mix(metallic, 0.0, snow_mask);   // Snow is non-metallic
    }
}
