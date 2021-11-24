extends Control


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var c = main.get_carbone()
	var h = main.get_hydrogen()
	h.number = 4
	var methane = main.Molecule.new()
	methane.from([c,h])
	
	var o = main.get_oxygen()
	o.number = 2
	var dioxygene = main.Molecule.new()
	dioxygene.from([o])
	
	var c_b = main.get_carbone()
	var o_b = main.get_oxygen()
	o_b.number = 2
	var dioxyde_de_carbone = main.Molecule.new()
	dioxyde_de_carbone.from([c_b,o_b])

	var h_ter = main.get_hydrogen()
	h_ter.number = 2

	var eau = main.Molecule.new()
	eau.from([h_ter,main.get_oxygen()])


	$Main.rajouter_une_molecule(methane,true)
	$Main.rajouter_une_molecule(dioxygene,true)

	$Main.rajouter_une_molecule(dioxyde_de_carbone,false)
	$Main.rajouter_une_molecule(eau,false)
	$Main.atom_edit_mode = false
	$Main.edit_mode = true

	var popup = AcceptDialog.new()
	popup.dialog_text = "Cette équation n'est pas équilibrée! C'est à toi d'essayer de l'équilibrer.\n Appuie sur le bouton en bas à droite pour voir si tu as réussi."
	add_child(popup)
	popup.popup_centered()
