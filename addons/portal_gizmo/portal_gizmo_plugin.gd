# addons/portal_gizmo/portal_gizmo_plugin.gd
@tool
extends EditorNode3DGizmoPlugin
class_name PortalGizmoPlugin

func _init():
	create_material("main", Color.CYAN)

func _has_gizmo(spatial: Node3D) -> bool:
	return spatial is Portal

func _get_gizmo_name() -> String:
	return "Portal"

func _redraw(gizmo: EditorNode3DGizmo):
	gizmo.clear()
	
	var portal = gizmo.get_node_3d() as Portal
	if not portal:
		return
	
	# Get the forward direction and length
	var forward = Vector3(0, 0, 1)  # Local forward direction
	var length = 1.0  # Default length
	if portal.has_method("get_gizmo_length"):
		length = portal.get_gizmo_length()
	
	# Create a thick cylinder mesh for the arrow shaft
	var cylinder_mesh = CylinderMesh.new()
	cylinder_mesh.top_radius = 0.03  # Thickness of the line
	cylinder_mesh.bottom_radius = 0.03  # Same thickness at both ends
	cylinder_mesh.height = length
	cylinder_mesh.radial_segments = 8  # Smoothness
	
	# Create transform to rotate cylinder from Y-axis to Z-axis and position it
	var transform = Transform3D()
	# Rotate 90 degrees around X-axis to align cylinder with Z-axis
	transform = transform.rotated(Vector3.RIGHT, PI/2)
	# Position the cylinder to extend forward from the portal
	transform.origin = Vector3(0, 0, length / 2)
	
	# Add the cylinder mesh to the gizmo with the transform
	gizmo.add_mesh(cylinder_mesh, get_material("main", gizmo), transform)
