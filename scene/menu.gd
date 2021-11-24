extends PanelContainer


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/buttons/MenuButton.get_popup().connect("id_pressed",self,"on_id_pressed")


func on_id_pressed(id):
	var _path = ""
	match id:
		0:_path = "res://scene/combustion_carbone.tscn"
		1:_path = "res://scene/combustion_methane.tscn"
		2:_path = "res://scene/edition.tscn"
		
	get_tree().change_scene(_path)
