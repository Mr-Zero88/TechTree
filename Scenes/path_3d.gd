extends Path3D

const RAY_LENGTH = 100
const SPEED = 30

func absoluteClosestSort(a, b) -> bool:
	return abs(a) - abs(b) < 0

func _process(delta: float) -> void:
	if Input.is_action_pressed('slider_move'):
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
			return
		var position: Vector3 = result.position
		position = self.to_local(position)
		var progress = self.curve.get_closest_offset(position)
		var follower: PathFollow3D = self.find_child("PathFollow3D")
		var length = self.curve.get_baked_length()
		var targets = [progress - length, progress, progress + length]
		var distances = [targets[0] - follower.progress, targets[1] - follower.progress, targets[2] - follower.progress]
		distances.sort_custom(absoluteClosestSort)
		var direction = 1 if distances[0] > 0 else -1;
		if(abs(distances[0]) < direction / length * SPEED):
			return
		follower.progress += direction / length * SPEED
		
