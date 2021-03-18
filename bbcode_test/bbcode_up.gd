extends RichTextEffect
class_name RichTextIsUp


# Syntax: [up][/up]
var bbcode = "up"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	char_fx.offset += Vector2(0,-8)
	return true
