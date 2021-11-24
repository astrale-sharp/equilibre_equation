extends PanelContainer

onready var menu_button = $VBoxContainer/buttons/MenuButton
func _ready() -> void:
	menu_button.get_popup().connect("id_pressed",self,"on_id_pressed")


func on_id_pressed(id):
	print("5")
	var _path = ""
	match id:
		0:_path = "res://scene/combustion_carbone.tscn"
		1:_path = "res://scene/combustion_methane.tscn"
		2:_path = "res://scene/edition.tscn"
		
	get_tree().change_scene(_path)
