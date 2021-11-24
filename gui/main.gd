extends PanelContainer


onready var atom_selector := preload("res://gui/atom_selector/atom_selector.tscn")
onready var molecule_gui := preload("res://gui/molecule/molecule_gui.tscn")
onready var atom_gui := preload("res://gui/molecule/atom_gui.tscn")

var edit_mode : bool = true setget set_edit_mode 
var atom_edit_mode: bool setget set_atom_edit_enable 

var equation : main.Equation
var left_side : main.EquationSide
var right_side : main.EquationSide

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$screen/interactif/left_side/VBoxContainer/rajouter_molecule.connect("pressed",self,"ui_rajouter_une_molecule",[true])
	$screen/interactif/right_side/VBoxContainer/rajouter_molecule.connect("pressed",self,"ui_rajouter_une_molecule",[false])
	$screen/interactif/left_side/VBoxContainer/expliquer.connect("pressed",self,"_on_expliquer_equation_side",[true])
	$screen/interactif/right_side/VBoxContainer/expliquer.connect("pressed",self,"_on_expliquer_equation_side",[false])
	$screen/dead_space/show.connect("pressed",self,"montrer_les_resultats")
	$screen/dead_space/Retour_menu.connect("pressed",self,"retour_menu")

	set_edit_mode($screen/dead_space/OptionButton.get_index())
	
#-------------features------------#

func ui_rajouter_une_molecule(left : bool):
	var selector = atom_selector.instance()
	selector.connect("molecule",self,"atoms_received",[left])
	add_child(selector)
	selector.popup_centered(Vector2.ONE * 500)
	

func rajouter_une_molecule(molecule : main.Molecule,left=true):
	var m_gui = molecule_gui.instance()
	m_gui.from_molecule(molecule)
	m_gui.get_suppr_button().connect("pressed",self,"supprimer_molecule",[m_gui])
	m_gui.popup = $Popup
	var parent = $screen/equation_panels/left_molecules if left else $screen/equation_panels/right_molecules
	parent.add_child(m_gui)
	update_plus_sign()


func supprimer_molecule(molecule):
	yield(molecule,"tree_exited")
	update_plus_sign()
	

	
func montrer_les_resultats():
	left_side = molecules2EquationSide()
	right_side = molecules2EquationSide(false)
	equation = main.Equation.new()
	equation.from_sides(left_side,right_side)
	
	if equation.empty(): return
	var conclusion : String
	var color : Color

	if equation.is_equilibrated():
		conclusion = "Bravo, l'équation est équilibrée."
		color = Color.green
	else:
		color = Color.red
		var res = equation.compare()
		if typeof(res) != TYPE_DICTIONARY:
			var other_res = equation.what_atoms_are_missing()
			conclusion = "l'équation n'est pas valide:\n"
			if not other_res[0].empty():
				conclusion += "les atomes: "
				for k in other_res[0]:
					conclusion += k
					conclusion += ", "
					conclusion = conclusion.rstrip(", ")
				conclusion += " "
				conclusion += "sont présents à gauche de l'équation mais pas à droite.\n"
			if not other_res[1].empty():
				conclusion += "les atomes: "
				for k in other_res[1]:
					conclusion += k
					conclusion += ", "
				conclusion = conclusion.rstrip(", ")
				conclusion+= " "
				conclusion += "sont présents à droite de l'équation mais pas à gauche.\n"
		else:
			conclusion = "l'équation n'est pas équilibrée.\n"
			conclusion += "les atomes: "
			for k in res:
				conclusion += k
				conclusion += ", "
			conclusion = conclusion.rstrip(", ")
			conclusion+= " "
			conclusion += "ne sont pas présent dans la même quantité de chaque côté de l'équation.\n"
	
	var text_left = "Du côté gauche de l'équation:\n" + left_side.bbcode_explain()
	var text_right = "Du côté droit de l'équation:\n" + right_side.bbcode_explain()
	$screen/resultats.validate(conclusion,text_left,text_right,color)
	
	set_edit_mode(false)
	$screen/dead_space/OptionButton.select(1)
	$screen/dead_space/OptionButton.grab_focus()

#----------------Signal response-----------------#


func atoms_received(atoms : Array,left = true):
	var m_gui = molecule_gui.instance()
	var m := main.Molecule.new()
	m.from(atoms)
	rajouter_une_molecule(m,left)

func update_plus_sign():
	#disable plus sign if molecule is first
	#enable otherwise
	for path in [
		$screen/equation_panels/left_molecules,
		$screen/equation_panels/right_molecules
		]:
			for idx in path.get_child_count():
				var child = path.get_child(idx)
				if idx == 0:
					child.plus_sign = false
				else:
					child.plus_sign = true

func molecules2EquationSide(left=true):
	var molec_side := $screen/equation_panels/left_molecules if left else $screen/equation_panels/right_molecules
	var equation_side = main.EquationSide.new()
	var children = molec_side.get_children()
	var array_molecules = []
	for c in children:#molec_gui
		if c.molecule: array_molecules.append(c.molecule)
	equation_side.from_molecules(array_molecules)
	return equation_side


func set_edit_mode(value):
	edit_mode = value
	$screen/dead_space/OptionButton.select(0 if edit_mode else 1)
	for i in [
		$screen/equation_panels/left_molecules,
		$screen/equation_panels/right_molecules
		]:
		for k in i.get_children():
			if k.has_method("set_edit_mode"):
				k.atom_edit_mode = atom_edit_mode
				k.edit_mode = value
				for interactable in k.get_interactable():
					if not edit_mode:
						if not "\nAttention! ne fonctionne que en mode edition (bouton en bas à gauche)" in interactable.hint_tooltip:
							interactable.hint_tooltip += \
							"\nAttention! ne fonctionne que en mode edition (bouton en bas à gauche)"
					elif \
						"\nAttention! ne fonctionne que en mode edition (bouton en bas à gauche)"\
						in interactable.hint_tooltip:
							interactable.hint_tooltip \
							= interactable.hint_tooltip.rstrip("\nAttention! ne fonctionne que en mode edition (bouton en bas à gauche)")
	for i in [
		$screen/interactif/left_side/VBoxContainer,
		$screen/interactif/right_side/VBoxContainer
		]:
		i.get_node("rajouter_molecule").visible = edit_mode
		i.get_node("expliquer").visible = not edit_mode


func set_atom_edit_enable(value):
	atom_edit_mode = value
	set_edit_mode(edit_mode)


func _on_OptionButton_item_selected(index: int) -> void:
	#id 0 is edition
	set_edit_mode(index == 0)
	if edit_mode:
		print("clean")
		$screen/resultats.clean()

func _on_expliquer_equation_side(left=true):
	var label = $Popup/Label
	var p = $Popup
	var side = molecules2EquationSide(left)
	var t = "Ce côté de l'équation est celui des "
	t+= "réactifs" if left else "produits"
	t+= ".\n"
	if side.to_bbcode():
		t += "il contient: "
		for k in side.molecules:
			t += "{0} molécule{1} de formule ".format([k.number, "s" if k.number>1 else ""])
			t += k.to_bbcode()
			t += ", "
		t = t.rstrip(", ")
		t+=".\n"
	t += "Les molécules de ce côté vont disparaître et les atomes qui les constituent vont servir à construire les molécules de réactifs." \
				if left else\
		  "Les molécules de ce côté vont apparaître, elles sont construites à partir des atomes des réactifs." 
	label.bbcode_text = t
	p.popup_centered(Vector2.ONE * 500)
	
func retour_menu():
	get_tree().change_scene("res://scene/menu.tscn")
