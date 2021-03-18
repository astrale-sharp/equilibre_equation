extends Popup
"""
emits a list of atom_as_molecpart
"""
var atoms = []
signal molecule(data)

func _ready() -> void:
	$tableau_periodique_gui.connect("atom_choice",self,"data_received")

func data_received(data):
	var molec_part := main.Atom_as_MolecPart.new()
	molec_part.from_atom(data)
	for m in atoms:
		if molec_part.atom.Symbol == m.atom.Symbol:
			return

	atoms.append(molec_part)
	$Node2D/Label.text += " "
	$Node2D/Label.text += molec_part.atom.Symbol
	atoms.sort_custom(self,"sort_atoms")

func _on_OkButton_pressed() -> void:
	if len(atoms) > 0: emit_signal("molecule",atoms)
	for m in atoms:
		print(m.atom.Symbol)
	queue_free()

func sort_atoms(atom_a,atom_b):
	return atom_a.atom.Symbol < atom_b.atom.Symbol
