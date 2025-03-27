@tool
extends Node3D

@export var model: Mesh:
	set(value):
		model = value
		$MeshInstance3D.mesh = value

func nodeChanged(dependency: Dependency, node: NodePath):
	if(node == null):
		dependency.curve = null
		dependency.name = ""
		return
	dependency.curve = Curve3D.new()
	var nodeObject: Node3D = self.get_node(node)
	dependency.curve.add_point(nodeObject.position)
	dependency.curve.add_point(self.position)
	dependency.name = node.get_name(node.get_name_count() - 1)

func curveChanged(dependency: Dependency, curve: Curve3D):
	if(curve == null):
		if(dependency.node == null):
			return
		dependency.curve = Curve3D.new()
		var nodeObject: Node3D = self.get_node(dependency.node)
		dependency.curve.add_point(nodeObject.position)
		dependency.curve.add_point(self.position)
		return
	if(dependency.node == null):
		dependency.curve == null
		return
	if(dependency.path == null): return
	dependency.path.curve = curve

func nameChanged(dependency: Dependency, name: String):
	if(name == ""):
		dependency.path = null
	else:
		dependency.path = preload("res://Scenes/DependencyPath.tscn").instantiate()# DependencyPath.new()
		dependency.path.name = "DependencyPath_" + name

func pathChanged(dependency: Dependency, oldPath: Path3D, path: Path3D):
	if(oldPath != null):
		path.queue_free()
	if(path != null):
		print(path)
		self.add_child(path)
		path.owner = get_tree().edited_scene_root
		
func modelChanged(dependency: Dependency, model: Mesh):
	dependency.path.model = model

@export var dependencies: Array[Dependency]:
	set(value):
		dependencies = value
		for i in range(dependencies.size()):
			if(dependencies[i] == null):
				dependencies[i] = Dependency.new()
			var dependency = dependencies[i]
			dependency.nameChanged.connect(nameChanged)
			dependency.nodeChanged.connect(nodeChanged)
			dependency.curveChanged.connect(curveChanged)
			dependency.pathChanged.connect(pathChanged)
			dependency.modelChanged.connect(modelChanged)
