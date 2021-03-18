extends Control



func _ready() -> void:
	$Main.edit_mode = true

	var popup = AcceptDialog.new()
	popup.dialog_text = "Cet outil permet d'éditer tes propres équation."
	add_child(popup)
	popup.popup_centered()
