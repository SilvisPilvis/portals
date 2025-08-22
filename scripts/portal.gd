@tool
extends Node3D
class_name Portal

@export var portal_destination: Portal  # The other portal
@export var portal_resolution: Vector2i = Vector2i(512, 512)
@export var shader: Shader

@onready var sub_viewport: SubViewport = $SubViewport
@onready var portal_camera: Camera3D = $SubViewport/PortalCamera
@onready var portal_quad: MeshInstance3D = $PortalQuad
@onready var debug_camera: MeshInstance3D= $SubViewport/PortalCamera/DebugCamera

@export var player_camera: Camera3D
var portal_material: StandardMaterial3D
var frame_material: StandardMaterial3D

var destination_portal_quad: MeshInstance3D

func _ready():
	setup_portal()

func setup_portal():
	# Configure SubViewport
	sub_viewport.size = portal_resolution
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	# Create the shader material
	var shader_material = ShaderMaterial.new()
	# Set the portal shader as shader for the material
	shader_material.shader = shader
	
	# Set initial shader parameters
	shader_material.set_shader_parameter("portal_texture", sub_viewport.get_texture())
	
	# Apply to quad
	portal_quad.material_override = shader_material
	
	# Flip the portal quad on the Y axis
	portal_quad.scale = Vector3(portal_quad.scale.x, -portal_quad.scale.y, portal_quad.scale.z)

# Add this new function to update the texture parameter when needed
func _process(_delta):
	# If player camera and portal camera is not null
	if player_camera and portal_destination:
		# Update portal camera
		update_portal_camera()
	
	# Update the portal texture in case it changes
	if portal_quad.material_override is ShaderMaterial:
		var mat = portal_quad.material_override as ShaderMaterial
		var current_texture = mat.get_shader_parameter("portal_texture")
		var viewport_texture = sub_viewport.get_texture()
		
		if current_texture != viewport_texture:
			mat.set_shader_parameter("portal_texture", viewport_texture)

func update_portal_camera():
	# If player camera or portal destination is null return
	if not player_camera or not portal_destination:
		return

	# Get global transform of current portal
	var current_portal_transform: Transform3D = self.global_transform
	# Get global transform of linked portal
	var linked_portal_transform: Transform3D = portal_destination.global_transform
	# Player cam global transform
	var player_camera_transform: Transform3D = player_camera.global_transform
	
	# Get player's position relative to the current portal
	var relative_transform: Transform3D = current_portal_transform.affine_inverse() * player_camera_transform
	
	# Apply that relative transform to the destination portal
	#var final_transform: Transform3D = linked_portal_transform * relative_transform
	var m: Transform3D = linked_portal_transform * relative_transform
	
	# Apply to portal camera
	portal_camera.global_transform = m
	
	# Match camera properties
	portal_camera.fov = player_camera.fov
	portal_camera.near = player_camera.near
	portal_camera.far = player_camera.far

func set_player_camera(camera: Camera3D):
	player_camera = camera
