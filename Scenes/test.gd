extends Node3D

@export var path: Path3D;

func _ready():
	print(path.curve.get_baked_points()) #.count()
