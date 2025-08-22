@tool # This line is crucial for editor interaction
extends StaticBody3D

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
		
#@export var color: Color = Color.MINT_CREAM:
@export var color: Color = Color.BLACK:
	set(setColor):
		color = setColor
		_update_texture()
		
# Nodes
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var rigid_body: StaticBody3D = self
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

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
	# IMPORTANT: Always create NEW resources to avoid sharing between instances
	if not collision_shape.shape:
		var new_box_shape := BoxShape3D.new()
		new_box_shape.size = size # Initialize with desired size
		collision_shape.shape = new_box_shape
	else:
		# If shape exists but might be shared, create a new one
		var new_box_shape := BoxShape3D.new()
		new_box_shape.size = size
		collision_shape.shape = new_box_shape
		
	if not mesh_instance.mesh:
		var new_box_mesh := BoxMesh.new()
		new_box_mesh.size = size # Initialize with desired size
		mesh_instance.mesh = new_box_mesh
	else:
		# If mesh exists but might be shared, create a new one
		var new_box_mesh := BoxMesh.new()
		new_box_mesh.size = size
		mesh_instance.mesh = new_box_mesh
		
	# Initialize dimensions based on initial size
	_update_dimensions()
	_update_texture()

# Function to update the mesh and the collision shape
func _update_dimensions() -> void:
	# Ensure resources exist before trying to modify them
	if not mesh_instance:
		return
		
	# Always create new mesh if it doesn't exist or ensure it's unique
	if not mesh_instance.mesh or not (mesh_instance.mesh is BoxMesh):
		mesh_instance.mesh = BoxMesh.new()
	
	# Make sure we have a unique mesh instance (not shared)
	if mesh_instance.mesh.get_reference_count() > 1:
		var new_mesh = BoxMesh.new()
		new_mesh.size = size
		mesh_instance.mesh = new_mesh
	else:
		mesh_instance.mesh.size = size
		
	# Force update gizmo/visual in editor if possible
	if Engine.is_editor_hint() and mesh_instance.get_world_3d():
		mesh_instance.mesh.changed.emit()
		
	if not collision_shape:
		return
		
	# Always create new shape if it doesn't exist or ensure it's unique
	if not collision_shape.shape or not (collision_shape.shape is BoxShape3D):
		collision_shape.shape = BoxShape3D.new()
	
	# Make sure we have a unique shape instance (not shared)
	if collision_shape.shape.get_reference_count() > 1:
		var new_shape = BoxShape3D.new()
		new_shape.size = size
		collision_shape.shape = new_shape
	else:
		collision_shape.shape.size = size
		
	# Force update gizmo in editor if possible
	if Engine.is_editor_hint():
		collision_shape.shape.changed.emit()
			
# Function to update the texture
func _update_texture() -> void:
	# Ensure resources exist before trying to modify them
	if not mesh_instance:
		return
		
	# Always create a new material to avoid sharing
	var mat : StandardMaterial3D = StandardMaterial3D.new()
	if texture:
		mat.albedo_texture = texture
		mat.uv1_scale = Vector3(3, 2, 1) # Fixed: should be Vector3, not Vector3i
		mat.normal_enabled = true
		mat.normal_texture = normal_texture
		
	if color != Color.BLACK:
		mat.albedo_color = color
		mat.uv1_scale = Vector3(3, 2, 1) # Fixed: should be Vector3, not Vector3i
		mat.normal_enabled = true
		mat.normal_texture = normal_texture
	
	# Apply the material
	if mesh_instance.mesh:
		mesh_instance.mesh.surface_set_material(0, mat)

	# Note: Modifying scale of the Node3D itself is usually not recommended for this,
	# as it affects children transforms and can cause the original warning.
	# Modifying the resources directly is the preferred method to avoid non-uniform node scale warnings.
