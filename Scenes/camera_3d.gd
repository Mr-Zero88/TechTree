extends Camera3D

const RAY_LENGTH = 100

var selected = false;

@export var ground: Node3D

var startpos: Vector3;
var startMousePos: Vector2;

func _process(delta: float) -> void:
	if(Engine.is_editor_hint()): return
	if(Input.is_action_just_pressed('slider_move')):
		var cast = mouseCast()
		if(cast != null):
			selected = cast.collider == ground
			startpos = position
			startMousePos = get_viewport().get_mouse_position()
	elif(Input.is_action_just_released('slider_move')):
		selected = false
	if Input.is_action_pressed('slider_move') && selected:
		var mousePos: Vector2 = get_viewport().get_mouse_position()
		var offset: Vector2 = mousePos - startMousePos;
		offset *= 0.025
		position = startpos - Vector3(offset.x, 0, offset.y)

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
	if(result.is_empty()):
		return null
	return result
