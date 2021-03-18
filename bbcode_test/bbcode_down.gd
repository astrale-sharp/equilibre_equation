extends RichTextEffect
class_name RichTextIsDown


# Syntax: [do][/do]
var bbcode = "do"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	char_fx.offset += Vector2(0,+8)
	return true
