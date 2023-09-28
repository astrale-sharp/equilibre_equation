extends GridContainer

"""
goal is to make appear a table of elements
"""

signal atom_choice(atom)
#export var SIZE : float = 40

var data = preload("res://data.tscn").instance()
var table


func _ready() -> void:
	table = data.get_atom_list()
	draw()
	

func draw():
	var number : Vector2
	# 1 à 56 en respectant rect x=groupe y = period

	var max_x = 0
	var max_y = 0
	for k in range(57):
		var atom : main.Atom = table[k]
		max_x = max(atom.group,max_x)
		max_y = max(atom.Period,max_y)
	
	columns = max_x + 1
	var dict : Dictionary = {}
	for k in range(57):
		var atom : main.Atom = table[k]
#		x = atom.group
#		y = atom.Period
		dict[ [atom.group,atom.Period] ] = atom
#		add_button(x,y,atom.Symbol,atom.color,atom)

	for y in range(max_y+1):
		for x in range(max_x+1):
			var elem = dict.get([x,y]) 
			if not elem:
				add_button("", Color.white, null, false)
			else:
				add_button(elem.Symbol,elem.color,elem)
	
	

func add_button(label,color,data,connect_it = true):
	var b = Button.new()
	b.size_flags_horizontal = 3
	b.size_flags_vertical = 3
	b.modulate = color
	b.text = label
#	b.rect_size = Vector2.ONE* 200
	if connect_it:
		b.connect("button_down",self,"_on_button_pressed",[data])
	self.add_child(b)
	
func _on_button_pressed(data):
	if data.has_method("display"):
		emit_signal("atom_choice",data)
