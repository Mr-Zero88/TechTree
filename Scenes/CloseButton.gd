extends Button

func _ready() -> void:
	var panel: Panel = get_parent()
	self.pressed.connect(func ():
		panel.visible = false
	)
	panel.visible = false
