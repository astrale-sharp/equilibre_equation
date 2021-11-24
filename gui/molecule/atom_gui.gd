extends HBoxContainer

var atom : main.Atom_as_MolecPart
export(bool) var edit_mode setget set_edit_mode
export(bool) var charge_enabled = true setget set_charge_enabled


signal atom_changed

func _ready() -> void:
	if not atom:
		printerr("atom not initialized in atom_gui")
		queue_free()
	$VBoxContainer/charge/buttons/plus.connect("pressed",self,"_add_to_charge",[1])
	$VBoxContainer/charge/buttons/minus.connect("pressed",self,"_add_to_charge",[-1])
	$VBoxContainer/stoechiometrie/buttons/plus.connect("pressed",self,"_add_to_stoech",[1])
	$VBoxContainer/stoechiometrie/buttons/minus.connect("pressed",self,"_add_to_stoech",[-1])


func from_atom_as_part(_atom):
	self.atom = _atom
	$name.text = _atom.atom.Symbol
	$VBoxContainer/charge/Label.text = atom.get_charge_repr()
	$VBoxContainer/stoechiometrie/Label.text = atom.get_stoech_repr()

#--------------features--------------#
func set_edit_mode(value):
	edit_mode = value
	for k in _get_editable_gui():
		k.visible = value

func get_interactable():
	return $VBoxContainer/charge/buttons.get_children() + $VBoxContainer/stoechiometrie/buttons.get_children()

		
#--------------private-----------#
func _get_editable_gui():
	return $VBoxContainer/charge/buttons.get_children() +$VBoxContainer/stoechiometrie/buttons.get_children()


func _add_to_charge(add):
	if abs(atom.charge + add) >= 6: return
	atom.charge += add
	from_atom_as_part(atom)
	emit_signal("atom_changed")
	

func _add_to_stoech(add):
	if atom.number + add <= 0: return
	atom.number = atom.number + add
	from_atom_as_part(atom)
	emit_signal("atom_changed")


func set_charge_enabled(value):
	charge_enabled = value
	$VBoxContainer/charge.visible = value
