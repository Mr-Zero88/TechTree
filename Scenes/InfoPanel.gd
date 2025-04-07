extends Panel
class_name InfoPanel

signal show(text: String)

func _ready() -> void:
	show.connect(func (text):
		visible = true
		$RichTextLabel.text = text
	)
