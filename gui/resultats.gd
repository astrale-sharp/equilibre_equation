extends VBoxContainer


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


func clean():
	$HBoxContainer2/ColorRect.color.a = 0
	$HBoxContainer2/phrase_de_conclusion.bbcode_text = ""
	$HBoxContainer/explication_gauche.bbcode_text = ""
	$HBoxContainer/explication_droite.bbcode_text = ""
	
func validate(conclusion,left_text,right_text,color):
	$HBoxContainer2/phrase_de_conclusion.bbcode_text = conclusion
	$HBoxContainer/explication_gauche.bbcode_text = left_text
	$HBoxContainer/explication_droite.bbcode_text = right_text
	$HBoxContainer2/ColorRect.color = color
