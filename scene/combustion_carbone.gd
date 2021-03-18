extends Control


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	var o = main.get_oxygen()
	o.number = 2
	var dioxygene = main.Molecule.new()
	dioxygene.from([o])
	
	
	var carbone = main.Molecule.new()
	carbone.from([main.get_carbone()])
	var dioxyde_de_carbone = main.Molecule.new()
	
	var o_b = main.get_oxygen()
	o_b.number = 2
	dioxyde_de_carbone.from([main.get_carbone(),o_b])

	$Main.rajouter_une_molecule(carbone,true)
	$Main.rajouter_une_molecule(dioxygene,true)
	$Main.rajouter_une_molecule(dioxyde_de_carbone,false)
	$Main.edit_mode = false
	$Main.atom_edit_mode = false


	var popup = AcceptDialog.new()
	popup.dialog_text = "Cette équation est équilibrée.\n Appuie sur le bouton en bas à droite pour le vérifier."
	add_child(popup)
	popup.popup_centered()
