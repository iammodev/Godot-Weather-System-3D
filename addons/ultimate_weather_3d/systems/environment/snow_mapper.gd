extends Node3D

## Projects a top-down view of 'blockers' (Layer 2) to the global shader.

@export var target_node: Node3D
@export var projection_size: float = 50.0

var _viewport: SubViewport
var _camera: Camera3D

func _ready() -> void:
	# Create Viewport
	_viewport = SubViewport.new()
	_viewport.name = "SnowViewport"
	_viewport.size = Vector2i(1024, 1024)
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_viewport.transparent_bg = true # Important: Empty space = No Blocker
	add_child(_viewport)
	
	# Create Camera
	_camera = Camera3D.new()
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.size = projection_size
	_camera.near = 1.0
	_camera.far = 200.0
	# Look down
	_camera.transform.basis = Basis.from_euler(Vector3(-PI/2, 0, 0))
	_camera.position.y = 100.0
	
	# CULL MASK: Only see Layer 2 (Blockers)
	# Layer 1 is bit 0, Layer 2 is bit 1. Value = 2.
	_camera.cull_mask = 2 
	
	_viewport.add_child(_camera)
	
	# Set Global Size once
	RenderingServer.global_shader_parameter_set("snow_proj_size", projection_size)

func _process(delta: float) -> void:
	var center_pos = Vector3.ZERO
	if target_node:
		center_pos = target_node.global_position
	
	# Snap to pixel grid to avoid shivering textures
	var units_per_pixel = projection_size / float(_viewport.size.x)
	center_pos.x = round(center_pos.x / units_per_pixel) * units_per_pixel
	center_pos.z = round(center_pos.z / units_per_pixel) * units_per_pixel
	center_pos.y = 0.0
	
	# Move us (and camera)
	global_position = center_pos
	
	# Update Shader Globals
	RenderingServer.global_shader_parameter_set("snow_proj_pos", center_pos)
	RenderingServer.global_shader_parameter_set("snow_mask_tex", _viewport.get_texture())
