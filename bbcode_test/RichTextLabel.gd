extends RichTextLabel


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


func _on_LineEdit_text_entered(new_text: String) -> void:
	bbcode_text = new_text
