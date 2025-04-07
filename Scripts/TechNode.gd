@tool
extends Node3D
class_name TechNode

signal positionChanged(position: Vector3)
signal activeChanged(active: bool)

signal completePath()

var isready = false;

@export var model: Mesh:
	set(value):
		model = value
		$MeshInstance3D.mesh = value

@export var unlockText: String = "";

@export var distance: float = 1;

@export var active = false:
	set(value):
		active = value
		print(value)
		activeChanged.emit(value)
		var material = StandardMaterial3D.new()
		if(value):
			material.albedo_color = Color(1, 0, 0, 1)
		else:
			material.albedo_color = Color(1, 1, 1, 1)
		if(model != null):
			model.surface_set_material(0, material)

@export var dependencies: Array[Dependency]:
	set(value):
		if(!isready):
			dependencies = value
			return
		for i in range(dependencies.size()):
			if(dependencies[i] != null):
				if(!value.has(dependencies[i])):
					dependencies[i].node = ""
		for i in range(value.size()):
			if(value[i] == null):
				value[i] = Dependency.new()
				value[i].model = BoxMesh.new()
			if(!dependencies.has(value[i])):
				connect_dependency(value[i])
		dependencies = value

var completeCounter = 0;

func _ready() -> void:
	isready = true;
	for i in range(dependencies.size()):
		connect_dependency(dependencies[i])
	completePath.connect(func():
		completeCounter += 1;
		if(completeCounter == dependencies.size()):
			active = true
			var main: Main = find_parent("Main");
			main.infoPanel.show.emit(name, unlockText)
	)

func _init() -> void:
	set_notify_transform(true)
	set_notify_local_transform(true)

func _notification(what):
	if(what == NOTIFICATION_TRANSFORM_CHANGED):
		positionChanged.emit(position)

func connect_dependency(dependency: Dependency):
	var nodeChanged = func(dependency: Dependency, node: NodePath):
		if(!has_node(dependency.node)):
			dependency.curve = null
			dependency.name = ""
			return
		dependency.curve = null
		dependency.name = node.get_name(node.get_name_count() - 1)
	
	var curveChanged = func(dependency: Dependency, curve: Curve3D):
		if(!has_node(dependency.node)):
			dependency.curve == null
			return
		if(curve == null):
			if(has_node(dependency.node)):
				var nodeObject: TechNode = get_node(dependency.node)
				dependency.curve = Curve3D.new()
				dependency.curve.add_point(to_local(nodeObject.position))
				dependency.curve.add_point(Vector3(0, 0, 0))
		if(dependency.path == null): return
		dependency.path.curve = curve
	
	var nameChanged = func(dependency: Dependency, name: String):
		if(name == ""):
			dependency.path = null
		else:
			var path: DependencyPath = find_child(name + "_Path")
			if(path == null):
				path = preload("res://Scenes/DependencyPath.tscn").instantiate()
			path.name = name + "_Path"
			path.model = dependency.model
			path.curve = dependency.curve
			path.end = self;
			path.start = get_node(dependency.node);
			dependency.path = path
	
	var pathChanged = func(dependency: Dependency, oldPath: Path3D, path: Path3D):
		if(oldPath != null):
			oldPath.queue_free()
		if(path != null):
			if(path.get_parent() == self):
				return
			add_child(path)
			path.owner = get_tree().edited_scene_root
			path.curve = dependency.curve
	
	var modelChanged = func(dependency: Dependency, model: Mesh):
		dependency.path.model = model
	
	dependency.nameChanged.connect(nameChanged)
	dependency.nodeChanged.connect(nodeChanged)
	dependency.curveChanged.connect(curveChanged)
	dependency.pathChanged.connect(pathChanged)
	dependency.modelChanged.connect(modelChanged)
	
	if(has_node(dependency.node)):
		dependency.name = dependency.node.get_name(dependency.node.get_name_count() - 1)
