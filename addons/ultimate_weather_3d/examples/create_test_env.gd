@tool
extends Node3D

## Generates a test environment with weather-reactive materials

@export_category("Configuration")
# We load the shader automatically now
var surface_shader: Shader = load("uid://dtc6hvlqo0r65")

@export var floor_color: Color = Color(0.2, 0.25, 0.2)
@export var house_color: Color = Color(0.6, 0.4, 0.3)
@export var roof_color: Color = Color(0.8, 0.2, 0.2)

# Tool Button
@export_tool_button("Regenerate Environment", "Reload") var refresh_action = _force_regenerate

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	# Only generate if empty. If nodes exist, we assume they are saved/edited.
	if get_child_count() == 0:
		_build_geometry()

func _force_regenerate() -> void:
	print("UltimateWeather3D: Regenerating Test Environment...")
	
	# Clear existing children
	for child in get_children():
		child.queue_free() # Use queue_free, simpler than immediate free in tool scripts usually
	
	# Defer build to wait for cleanup
	call_deferred("_build_geometry")

func _build_geometry() -> void:
	# 1. Create Floor
	var floor_mesh = MeshInstance3D.new()
	floor_mesh.name = "Floor"
	floor_mesh.mesh = PlaneMesh.new()
	floor_mesh.mesh.size = Vector2(100, 100)
	floor_mesh.material_override = _create_material(floor_color, 0.8)
	
	# Visual Layer 1 ONLY (Main Camera sees it, Snow Camera ignores it)
	floor_mesh.layers = 1 
	
	add_child(floor_mesh)
	_setup_editable(floor_mesh) # Make editable
	_add_collision(floor_mesh)
	
	# 2. Create House
	var house = Node3D.new()
	house.name = "TestHouse"
	house.position = Vector3(0, 0, -10)
	add_child(house)
	_setup_editable(house)
	
	# Walls (Blocker)
	var wall = MeshInstance3D.new()
	wall.name = "Walls"
	wall.mesh = BoxMesh.new()
	wall.mesh.size = Vector3(10, 4, 10)
	wall.position.y = 2
	wall.material_override = _create_material(house_color, 0.8)
	
	# Visual Layer 1 (Main Cam) + Layer 2 (Snow Cam sees it as blocker)
	# Binary 1 + 2 = 3
	wall.layers = 3 
	
	house.add_child(wall)
	_setup_editable(wall)
	_add_collision(wall)
	
	# Roof (Blocker)
	var roof = MeshInstance3D.new()
	roof.name = "Roof"
	roof.mesh = PrismMesh.new()
	roof.mesh.size = Vector3(12, 3, 12)
	roof.position.y = 5.5
	roof.material_override = _create_material(roof_color, 0.6)
	
	# Layer 1 + 2
	roof.layers = 3
	
	house.add_child(roof)
	_setup_editable(roof)
	_add_collision(roof)
	
	# 3. Random Cubes (Blockers)
	for i in range(10):
		var cube = MeshInstance3D.new()
		cube.name = "Cube_%d" % i
		cube.mesh = BoxMesh.new()
		cube.position = Vector3(randf_range(-20, 20), 0.5, randf_range(-20, 20))
		
		var col = Color(randf(), randf(), randf())
		cube.material_override = _create_material(col, 0.5)
		
		# Layer 1 + 2
		cube.layers = 3
		
		add_child(cube)
		_setup_editable(cube)
		_add_collision(cube)

func _create_material(color: Color, roughness: float) -> Material:
	if surface_shader:
		var mat = ShaderMaterial.new()
		mat.shader = surface_shader
		mat.set_shader_parameter("base_color", color)
		mat.set_shader_parameter("roughness", roughness)
		mat.set_shader_parameter("metallic", 0.0)
		return mat
	else:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = color
		mat.roughness = roughness
		return mat

func _add_collision(mesh_instance: MeshInstance3D) -> void:
	mesh_instance.create_trimesh_collision()
	var body = mesh_instance.get_child(0) as StaticBody3D
	if body:
		body.collision_layer = 1 
		body.collision_mask = 1
		# Ensure collision body is also editable
		_setup_editable(body)
		for child in body.get_children():
			_setup_editable(child)

func _setup_editable(node: Node) -> void:
	# This line makes the node visible in the Scene Tree and editable
	if Engine.is_editor_hint():
		node.owner = get_tree().edited_scene_root
