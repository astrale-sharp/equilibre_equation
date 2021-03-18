extends PanelContainer


var molecule : main.Molecule

var popup 

export var edit_mode : bool = true setget set_edit_mode
export var atom_edit_mode = true setget set_atom_edit_enable
export var charge_enabled : bool = true setget set_charge_enabled
var plus_sign : bool = false setget set_plus_sign

const atom_gui = preload("res://gui/molecule/atom_gui.tscn")



func from_molecule(m :main.Molecule):
	molecule = m
	$in_panel_molecule/molecule/Stoechiometrie.value = molecule.number
	for parts in m.molecparts:
		add_atom(parts)
	set_plus_sign(plus_sign)
	set_charge_enabled(charge_enabled)
	set_edit_mode(edit_mode)
	
func _ready() -> void:
	set_edit_mode(edit_mode)
	set_plus_sign(plus_sign)
	set_charge_enabled(charge_enabled)
	$in_panel_molecule/HBoxContainer/suppr.connect("pressed",self,"queue_free")
	$in_panel_molecule/HBoxContainer/expliquer.connect("pressed",self,"expliquer")

func add_atom(atom : main.Atom_as_MolecPart):
	var new_atom_gui = atom_gui.instance()
	new_atom_gui.charge_enabled = charge_enabled
	new_atom_gui.from_atom_as_part(atom)
	add_atom_gui(new_atom_gui)

func get_interactable():
	var res = [$in_panel_molecule/molecule/Stoechiometrie]
	for k in $in_panel_molecule/molecule.get_children():
		if k.name in ["plus_sign","Stoechiometrie"]:continue
		res += k.get_interactable()
	return res


#------GUI----------#
func set_plus_sign(value):
	plus_sign = value
	$in_panel_molecule/molecule/plus_sign.visible = value

func set_charge_enabled(value):
	charge_enabled = value
	#TODO TEST
	yield(self,"tree_entered")
	for c in $in_panel_molecule/molecule.get_children():
		if c.has_node("VBoxContainer/charge"):
			c.get_node("VBoxContainer/charge").visible = value

func set_edit_mode(value):
	edit_mode = value
	get_suppr_button().visible = value
	$in_panel_molecule/HBoxContainer/expliquer.visible = not value
	$in_panel_molecule/molecule/Stoechiometrie.editable = value
	for atom in $in_panel_molecule/molecule.get_children():
		if atom.has_method("set_edit_mode"):
			atom.edit_mode = value if atom_edit_mode else false
	


func set_atom_edit_enable(value):
	atom_edit_mode = value
	set_edit_mode(edit_mode)


func add_atom_gui(atom_gui): #: atom_gui
	atom_gui.connect("atom_changed",self,"on_change")
	$in_panel_molecule/molecule.add_child(atom_gui)


#------------Features-----------#


func get_suppr_button():
	return $in_panel_molecule/HBoxContainer/suppr

func get_accept_button():
	return $in_panel_molecule/HBoxContainer/accepter
	
#-------------private-----------#


func on_change():
	print("FIX ME")
	#on récupère les atoms, on rebake
	var arr = []
	for atom in $in_panel_molecule/molecule.get_children():
		if atom.name in ["plus_sign","Stoechiometrie"]:continue
		arr.append(atom.atom)
	for atom in $in_panel_molecule/molecule.get_children():
		if atom.name in ["plus_sign","Stoechiometrie"]:continue
		atom.queue_free()
	molecule.from(arr)
	from_molecule(molecule)
	print(molecule.display())


func _on_Stoechiometrie_value_changed(value: float) -> void:
	molecule.number = value
	on_change()

func expliquer():
	if not popup:
		popup = $Popup
	popup.get_node("Label").bbcode_text = molecule.bbcode_explain()
	popup.popup_centered()
	pass
