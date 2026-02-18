shader_type spatial;
render_mode unshaded, cull_disabled, blend_add, depth_draw_never;

uniform vec4 core_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 glow_color : source_color = vec4(0.2, 0.4, 1.0, 1.0); // Electric Blue
uniform float alpha : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    // UV.x goes from 0 to 1 across the width of the bolt.
    // We want 0.5 to be the center (white) and 0.0/1.0 to be edges (transparent).
    
    float dist_from_center = abs(UV.x - 0.5) * 2.0; // 0.0 at center, 1.0 at edges
    
    // Core intensity (sharp dropoff)
    float core = smoothstep(0.6, 0.0, dist_from_center);
    
    // Glow intensity (soft dropoff)
    float glow = smoothstep(1.0, 0.0, dist_from_center);
    
    vec3 final_color = mix(glow_color.rgb, core_color.rgb, core);
    
    ALBEDO = final_color;
    ALPHA = glow * alpha;
}
