shader_type sky;

uniform vec3 sky_top_color : source_color = vec3(0.35, 0.6, 1.0);
uniform vec3 sky_horizon_color : source_color = vec3(0.7, 0.8, 0.9);
uniform vec3 cloud_color : source_color = vec3(1.0, 1.0, 1.0);

uniform float cloud_coverage : hint_range(0.0, 1.0) = 0.5;
uniform float cloud_softness : hint_range(0.0, 1.0) = 0.5;
uniform float time_scale = 0.01;

// Simple noise function
float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

// Value Noise
float noise(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

// Fractal Brownian Motion
float fbm(vec2 uv) {
    float v = 0.0;
    float amp = 0.5;
    for (int i = 0; i < 4; i++) {
        v += noise(uv) * amp;
        uv *= 2.0;
        amp *= 0.5;
    }
    return v;
}

void sky() {
    // 1. Basic Sky Gradient based on view angle
    vec3 final_sky = mix(sky_top_color, sky_horizon_color, pow(1.0 - EYEDIR.y, 2.0));
    
    // 2. Cloud Plane Mapping (Only render clouds above horizon)
    if (EYEDIR.y > 0.0) {
        // Project view direction onto a plane
        vec2 uv = EYEDIR.xz / EYEDIR.y;
        float t = TIME * time_scale;
        
        // Scroll clouds
        vec2 scroll = vec2(t, t * 0.5);
        
        float clouds = fbm(uv * 0.5 + scroll);
        
        // Thresholding for coverage
        // coverage 0.0 -> threshold 1.0 (no clouds)
        // coverage 1.0 -> threshold 0.0 (full clouds)
        float threshold = 1.0 - cloud_coverage;
        
        float cloud_alpha = smoothstep(threshold, threshold + cloud_softness, clouds);
        
        // Darken clouds at bottom to simulate thickness/shadow
        vec3 c_color = mix(cloud_color * 0.8, cloud_color, clouds);
        
        final_sky = mix(final_sky, c_color, cloud_alpha);
    }
    
    COLOR = final_sky;
}
