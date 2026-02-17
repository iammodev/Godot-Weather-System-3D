@tool
extends Node3D

func _ready() -> void:
	if GetNodeOrNull("Floor"): return # Don't recreate if exists
	
	# 1. Create Floor
	var floor_mesh = MeshInstance3D.new()
	floor_mesh.name = "Floor"
	floor_mesh.mesh = PlaneMesh.new()
	floor_mesh.mesh.size = Vector2(100, 100)
	
	var floor_mat = StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.2, 0.25, 0.2) # Dark grass green
	floor_mat.roughness = 0.8
	floor_mesh.material_override = floor_mat
	
	# Add collision for particles
	floor_mesh.create_trimesh_collision()
	add_child(floor_mesh)
	
	# 2. Create a House (to test rain occlusion)
	var house = Node3D.new()
	house.name = "TestHouse"
	house.position = Vector3(0, 0, -10)
	add_child(house)
	
	# Walls
	var wall = MeshInstance3D.new()
	wall.mesh = BoxMesh.new()
	wall.mesh.size = Vector3(10, 4, 10)
	wall.position.y = 2
	
	var wall_mat = StandardMaterial3D.new()
	wall_mat.albedo_color = Color(0.6, 0.4, 0.3) # Brown
	wall.material_override = wall_mat
	wall.create_trimesh_collision()
	house.add_child(wall)
	
	# Roof
	var roof = MeshInstance3D.new()
	roof.mesh = PrismMesh.new()
	roof.mesh.size = Vector3(12, 3, 12)
	roof.position.y = 5.5
	
	var roof_mat = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.8, 0.2, 0.2) # Red roof
	roof.material_override = roof_mat
	roof.create_trimesh_collision()
	house.add_child(roof)
	
	# 3. Add some random cubes for depth
	for i in range(10):
		var cube = MeshInstance3D.new()
		cube.mesh = BoxMesh.new()
		cube.position = Vector3(randf_range(-20, 20), 0.5, randf_range(-20, 20))
		cube.create_trimesh_collision()
		add_child(cube)

func GetNodeOrNull(name: String) -> Node:
	return get_node_or_null(name)
