# addons/portal_gizmo/plugin.gd
@tool
extends EditorPlugin

func _enter_tree():
	add_node_3d_gizmo_plugin(PortalGizmoPlugin.new())

func _exit_tree():
	pass
