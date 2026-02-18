extends MeshInstance3D
class_name LightningBolt

## Generates a jagged 3D lightning bolt mesh

func _ready() -> void:
	# Create a custom shader material for the glow effect
	var mat = ShaderMaterial.new()
	mat.shader = load("res://addons/ultimate_weather_3d/shaders/lightning.gdshader")
	material_override = mat
	
	# Disable shadows for performance and look
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func generate(start: Vector3, end: Vector3, segments: int = 15, jaggedness: float = 2.0, width: float = 0.5) -> void:
	var mesh_data = ImmediateMesh.new()
	var points = _calculate_jagged_points(start, end, segments, jaggedness)
	
	mesh_data.clear_surfaces()
	mesh_data.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	
	# Create a ribbon that always faces somewhat towards the camera
	# (For a perfect billboard, we'd do this in the vertex shader, but this is cheaper)
	var cam = get_viewport().get_camera_3d()
	var cam_pos = cam.global_position if cam else Vector3.ZERO
	
	for i in range(points.size()):
		var p = points[i]
		var dir_to_cam = (cam_pos - p).normalized()
		var bolt_dir = (end - start).normalized()
		var side = bolt_dir.cross(dir_to_cam).normalized() * width
		
		# UV.x = 0 (left edge), UV.x = 1 (right edge)
		# UV.y = progress along bolt (0 to 1)
		var t = float(i) / float(points.size())
		
		mesh_data.surface_set_uv(Vector2(0.0, t))
		mesh_data.surface_add_vertex(p - side)
		
		mesh_data.surface_set_uv(Vector2(1.0, t))
		mesh_data.surface_add_vertex(p + side)
		
	mesh_data.surface_end()
	mesh = mesh_data
	
	# Force AABB to avoid culling
	custom_aabb = AABB(Vector3(-1000, -1000, -1000), Vector3(2000, 2000, 2000))
	
	_animate_flash()

func _calculate_jagged_points(start: Vector3, end: Vector3, segments: int, jaggedness: float) -> PackedVector3Array:
	var points: PackedVector3Array = []
	points.append(start)
	
	var axis = end - start
	var step = axis / segments
	
	for i in range(1, segments):
		var base_pos = start + (step * i)
		
		# Random offset
		var offset = Vector3(
			randf_range(-jaggedness, jaggedness),
			randf_range(-jaggedness, jaggedness),
			randf_range(-jaggedness, jaggedness)
		)
		points.append(base_pos + offset)
		
	points.append(end)
	return points

func _animate_flash() -> void:
	var mat = material_override as ShaderMaterial
	var tween = create_tween()
	
	# Flash the "alpha" parameter in the shader
	tween.tween_method(func(v): mat.set_shader_parameter("alpha", v), 0.0, 1.0, 0.05) # Fade In
	tween.tween_method(func(v): mat.set_shader_parameter("alpha", v), 1.0, 0.5, 0.05) # Flicker
	tween.tween_method(func(v): mat.set_shader_parameter("alpha", v), 0.5, 1.0, 0.05) # Bright
	tween.tween_method(func(v): mat.set_shader_parameter("alpha", v), 1.0, 0.0, 0.2)  # Fade Out
	tween.tween_callback(queue_free)
