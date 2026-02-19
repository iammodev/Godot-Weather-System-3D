shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// --- Global Weather Uniforms ---
global uniform float weather_wetness_level; // 0.0 to 1.0
global uniform float weather_snow_height;   // 0.0 to 1.0 (Accumulation)

// --- Dynamic Occlusion Uniforms ---
global uniform sampler2D snow_mask_tex; // The top-down view from SnowViewport
global uniform vec3 snow_proj_pos;      // Center of that view
global uniform float snow_proj_size;    // Size of view (e.g. 50.0)

// --- Base Material ---
group_uniforms Base;
uniform vec3 base_color : source_color = vec3(0.5, 0.5, 0.5);
uniform float roughness : hint_range(0.0, 1.0) = 0.8;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D texture_normal : hint_normal, filter_linear_mipmap, repeat_enable;
uniform float normal_scale : hint_range(-16, 16) = 1.0;
uniform vec3 uv1_scale = vec3(1.0);
uniform vec3 uv1_offset = vec3(0.0);

// --- Snow Settings ---
group_uniforms Snow;
uniform vec3 snow_albedo : source_color = vec3(0.9, 0.95, 1.0);
uniform float snow_roughness : hint_range(0.0, 1.0) = 0.9;
uniform sampler2D texture_snow : source_color, filter_linear_mipmap, repeat_enable;
uniform float snow_texture_scale = 4.0;

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
}

// Helper for Triplanar Mapping
vec3 triplanar_texture(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos) {
	vec3 samp = vec3(0.0);
	samp += texture(p_sampler, p_triplanar_pos.xy).rgb * p_weights.z;
	samp += texture(p_sampler, p_triplanar_pos.xz).rgb * p_weights.y;
	samp += texture(p_sampler, p_triplanar_pos.zy * vec2(-1.0, 1.0)).rgb * p_weights.x;
	return samp;
}

void fragment() {
	// 1. Base Properties
	vec3 albedo_res = base_color;
	float roughness_res = roughness;
	float metallic_res = metallic;
	
	// Sample normal map
	vec3 normal_map = texture(texture_normal, UV).rgb;
	normal_map = mix(vec3(0.5, 0.5, 1.0), normal_map, normal_scale);
	
	// 2. Weather: Wetness
	float wetness = clamp(weather_wetness_level, 0.0, 1.0);
	if (wetness > 0.0) {
		albedo_res *= mix(1.0, 0.5, wetness); 
		roughness_res = mix(roughness_res, 0.1, wetness * 0.8); 
		metallic_res = mix(metallic_res, 0.2, wetness * 0.5); 
	}

	// 3. Weather: Snow Accumulation
	float snow_accum = clamp(weather_snow_height, 0.0, 1.0);
	
	// ONLY apply snow logic if there is actual accumulation
	if (snow_accum > 0.001) {
		// Calculate World Normal
		vec3 normal_world = mat3(INV_VIEW_MATRIX) * NORMAL;
		float up_dot = dot(normal_world, vec3(0.0, 1.0, 0.0));
		
		// 3a. Basic Angle Mask
		// Logic: Low accum (0.1) -> Threshold High (0.85) -> Only peaks
		//        High accum (1.0) -> Threshold Low (-0.2) -> Steep slopes too
		float threshold = 0.9 - (snow_accum * 1.1); 
		float snow_mask = smoothstep(threshold, threshold + 0.2, up_dot);
		
		// Scale intensity by accum so it fades in gently
		snow_mask *= smoothstep(0.0, 0.2, snow_accum);
		
		// 3b. DYNAMIC OCCLUSION
		vec3 w_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
		vec2 proj_uv = (w_pos.xz - snow_proj_pos.xz) / snow_proj_size + 0.5;
		
		if (proj_uv.x >= 0.0 && proj_uv.x <= 1.0 && proj_uv.y >= 0.0 && proj_uv.y <= 1.0) {
			float blocker = texture(snow_mask_tex, proj_uv).a;
			snow_mask *= (1.0 - blocker);
		}
		
		if (snow_mask > 0.01) {
			// Triplanar Snow Texture
			vec3 p_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz * snow_texture_scale;
			vec3 p_weights = abs(normal_world);
			p_weights /= (p_weights.x + p_weights.y + p_weights.z);
			
			vec3 snow_tex_col = triplanar_texture(texture_snow, p_weights, p_pos);
			
			// If texture is missing (black), force white
			if (length(snow_tex_col) < 0.01) snow_tex_col = vec3(1.0);
			
			vec3 final_snow_col = snow_albedo * snow_tex_col;
			
			albedo_res = mix(albedo_res, final_snow_col, snow_mask);
			roughness_res = mix(roughness_res, snow_roughness, snow_mask);
			metallic_res = mix(metallic_res, 0.0, snow_mask);
			
			// Flatten normals
			normal_map = mix(normal_map, vec3(0.5, 0.5, 1.0), snow_mask * 0.5);
		}
	}
	
	ALBEDO = albedo_res;
	ROUGHNESS = roughness_res;
	METALLIC = metallic_res;
	NORMAL_MAP = normal_map;
}
