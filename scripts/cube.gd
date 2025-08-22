@tool # This line is crucial for editor interaction
extends RigidBody3D

# Custom properties for size
@export var size: Vector3 = Vector3(1.0, 1.0, 1.0):
	set(setSize):
		size = setSize
		_update_dimensions()
		notify_property_list_changed() # Might help signal changes
		
@export var texture : Texture2D = Texture2D.new():
	set(setTex):
		texture = setTex
		_update_texture()
		notify_property_list_changed() # Might help signal changes
		
@export var normal_texture : Texture2D = Texture2D.new():
	set(setNormalTex):
		normal_texture = setNormalTex
		_update_texture()
		notify_property_list_changed() # Might help signal changes
		
# Nodes
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
#@onready var rigid_body: RigidBody3D = $RigidBody3D
@onready var rigid_body: RigidBody3D = self
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

@export_enum("BOUNCY", "SLIPPERY", "NORMAL") var CUBE_MATERIAL = 2

# Called when the node enters the scene tree or when loaded in editor
func _ready() -> void:
	# Ensure the structure is correct and nodes exist
	if not mesh_instance:
		push_warning("MeshInstance3D not found as a child.")
	if not rigid_body:
		push_warning("RigidBody3D not found as a child.")
	if not collision_shape:
		push_warning("CollisionShape3D not found as a child of RigidBody3D.")
		
	# Create default resources if not present (important for editor)
	if not collision_shape.shape:
		var new_box_shape := BoxShape3D.new()
		new_box_shape.size = size # Initialize with desired size
		collision_shape.shape = new_box_shape
		
	if not mesh_instance.mesh:
		var new_box_mesh := BoxMesh.new()
		new_box_mesh.size = size # Initialize with desired size
		mesh_instance.mesh = new_box_mesh
		
	if CUBE_MATERIAL == 0:
		var bouncy_mat = PhysicsMaterial.new()
		bouncy_mat.bounce = 1
		rigid_body.physics_material_override = bouncy_mat
	if CUBE_MATERIAL == 1:
		var slippery_mat = PhysicsMaterial.new()
		slippery_mat.friction = 0
		rigid_body.physics_material_override = slippery_mat
	if CUBE_MATERIAL == 2:
		var normal_mat = PhysicsMaterial.new()
		normal_mat.friction = 0.5
		normal_mat.bounce = 0.2
		rigid_body.physics_material_override = normal_mat
		
	# Initialize dimensions based on initial size
	_update_dimensions()
	_update_texture()

# Function to update the mesh and the collision shape
func _update_dimensions() -> void:
	# Ensure resources exist before trying to modify them
	if not mesh_instance:
		return
	if not mesh_instance.mesh:
		mesh_instance.mesh = BoxMesh.new()
		
	if not collision_shape:
		return
	if not collision_shape.shape:
		collision_shape.shape = BoxShape3D.new()

	# Update the mesh resource size directly
	if mesh_instance.mesh is BoxMesh:
		mesh_instance.mesh.size = size
		# Force update gizmo/visual in editor if possible
		if Engine.is_editor_hint() and mesh_instance.get_world_3d():
			mesh_instance.mesh.changed.emit()

	# Update the collision shape resource size directly
	if collision_shape.shape is BoxShape3D:
		collision_shape.shape.size = size
		# Force update gizmo in editor if possible
		if Engine.is_editor_hint():
			collision_shape.shape.changed.emit()
			
# Function to update the mesh and the collision shape
func _update_texture() -> void:
	# Ensure resources exist before trying to modify them
	if not mesh_instance:
		return
		
	if mesh_instance.get_active_material(0):
		var mat : StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_texture = texture
		mat.uv1_scale = Vector3i(3, 2, 1)
		mat.normal_enabled = true
		mat.normal_texture = normal_texture
		mesh_instance.mesh.surface_set_material(0, mat)
		
	# Update the mesh resource size directly
	if mesh_instance.mesh is BoxMesh:
		mesh_instance.mesh.size = size
		# Force update gizmo/visual in editor if possible
		if Engine.is_editor_hint() and mesh_instance.get_world_3d():
			mesh_instance.mesh.changed.emit()

	# Note: Modifying scale of the Node3D itself is usually not recommended for this,
	# as it affects children transforms and can cause the original warning.
	# Modifying the resources directly is the preferred method to avoid non-uniform node scale warnings.
