@tool
extends Path3D
class_name DependencyPath

const RAY_LENGTH = 100
const SPEED = 5

var follower: PathFollow3D;
var body: StaticBody3D;
var length: float;
var selected = false;
var done = false;

@export var start: TechNode;
@export var end: TechNode;

@export var model: Mesh:
	set(value):
		model = value
		$PathFollow3D/MeshInstance3D.mesh = value

#func absoluteClosestSort(a, b) -> bool:
	#return abs(a) - abs(b) < 0

func _process(delta: float) -> void:
	if(Engine.is_editor_hint()): return
	if(Input.is_action_just_pressed('slider_move')) && !selected && !done && start.active:
		var cast = mouseCast()
		if(cast != null):
			selected = cast.collider == body
	elif(Input.is_action_just_released('slider_move')) && selected:
		selected = false
		if(follower.progress == length - end.distance):
			done = true
			end.completePath.emit();
	if Input.is_action_pressed('slider_move') && selected:
		var cast = mouseCast()
		if(cast != null):
			var position: Vector3 = self.to_local(cast.position)
			var target = self.curve.get_closest_offset(position)
			var distance = target - follower.progress;
			var direction = 1 if distance > 0 else -1;
			if(abs(distance) < direction / length * SPEED):
				return
			follower.progress += direction / length * SPEED
			if(follower.progress < start.distance): follower.progress = start.distance
			if(follower.progress > length - end.distance): follower.progress = length - end.distance

func mouseCast():
	var mousePos = get_viewport().get_mouse_position()
	var camera_3d = get_viewport().get_camera_3d()
	var from = camera_3d.project_ray_origin(mousePos)
	var to = from + camera_3d.project_ray_normal(mousePos) * RAY_LENGTH
	var space = get_world_3d().direct_space_state
	var rayQuery = PhysicsRayQueryParameters3D.new()
	rayQuery.from = from
	rayQuery.to = to
	var result = space.intersect_ray(rayQuery)
	if(!result.has("position")):
		return null
	return result

func _ready() -> void:
	follower = self.find_child("PathFollow3D")
	body = follower.find_child("StaticBody3D")
	follower.progress = start.distance
	length = self.curve.get_baked_length()
	start.positionChanged.connect(func (nodePosition):
		curve.set_point_position(0, to_local(nodePosition))
	)
	end.positionChanged.connect(func (nodePosition):
		curve.set_point_position(0, to_local(nodePosition))
	)
