extends Control

var file_path = "res://data/molecules/"
onready var atom_selector = preload("res://gui/atom_selector/atom_selector.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$OkButton.connect("pressed",self,"on_ok")
	$SaveButton.connect("pressed",self,"on_save")

func on_ok():
	var select = atom_selector.instance()
	select.connect("molecule",self,"on_molecule")
	add_child(select)
	select.popup_centered()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
func on_molecule(data):
	var molecule = main.Molecule.new()
	molecule.from(data)
	molecule.name = $LineEdit.text
	$MoleculePanel.from_molecule(molecule)

func on_save():
	var f := File.new()
	var res = ResourceSaver.save("molecule_" + $LineEdit.text,$MoleculePanel.molecule,ResourceSaver.FLAG_RELATIVE_PATHS)
	if OK != res:
		print("CANT SAVE")
		print(res)

