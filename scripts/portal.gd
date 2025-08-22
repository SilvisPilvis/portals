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
	shader_material.shader = shader
	
	# Set initial shader parameters
	shader_material.set_shader_parameter("portal_texture", sub_viewport.get_texture())
	
	# Apply to quad
	portal_quad.material_override = shader_material

# Add this new function to update the texture parameter when needed
func _process(_delta):
	if player_camera and portal_destination:
		update_portal_camera()
	
	# Update the portal texture in case it changes
	if portal_quad.material_override is ShaderMaterial:
		var mat = portal_quad.material_override as ShaderMaterial
		var current_texture = mat.get_shader_parameter("portal_texture")
		var viewport_texture = sub_viewport.get_texture()
		
		if current_texture != viewport_texture:
			mat.set_shader_parameter("portal_texture", viewport_texture)

func update_portal_camera():
	if not player_camera or not portal_destination:
		return

	# Get global transform of both portals
	var src_transform = global_transform
	var dst_transform = portal_destination.global_transform

	# Invert source to get relative position/rotation of player wrt source portal
	var relative_transform = src_transform.affine_inverse() * player_camera.global_transform

	# Mirror the relative transform across the portal plane (flip Z axis)
	relative_transform = relative_transform.scaled_local(Vector3(1, 1, -1))

	# Apply mirrored transform to destination portal's transform
	portal_camera.global_transform = dst_transform * relative_transform
	debug_camera.global_transform = portal_camera.global_transform

	# Match FOV and other settings
	portal_camera.fov = player_camera.fov
	portal_camera.near = player_camera.near
	portal_camera.far = player_camera.far

func set_player_camera(camera: Camera3D):
	player_camera = camera
