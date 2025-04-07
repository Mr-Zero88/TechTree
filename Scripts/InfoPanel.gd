extends Panel
class_name InfoPanel

signal show(name: String, text: String)

func _ready() -> void:
	show.connect(func (name, text):
		visible = true
		$RichTextLabel.text = text
		$RichTextLabel2.text = name
	)
