@tool
extends Resource
class_name Dependency

signal nodeChanged(dependency: Dependency, node: NodePath)
signal curveChanged(dependency: Dependency, curve: Curve3D)
signal modelChanged(dependency: Dependency, model: Mesh)
signal nameChanged(dependency: Dependency, name: String)
signal pathChanged(dependency: Dependency, oldPath: Path3D, path: Path3D)

@export_node_path("Node3D") var node: NodePath = "":
	set(value):
		node = value
		nodeChanged.emit(self, value)
@export var curve: Curve3D = null:
	set(value):
		curve = value
		curveChanged.emit(self, value)
@export var model: Mesh = null:
	set(value):
		model = value
		model.size = Vector3(0.5, 0.5, 0.5)
		modelChanged.emit(self, value)
var name: String = "":
	set(value):
		name = value
		nameChanged.emit(self, value)
var path: DependencyPath = null:
	set(value):
		var oldPath = path
		path = value
		pathChanged.emit(self, oldPath, value)
