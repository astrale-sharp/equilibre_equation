extends Node2D

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
#	$TileMap.cell_size = Vector2.ONE * SIZE
	#get size according to bound
	var bound = $bound.position - position
	var number : Vector2
	# 1 à 56 en respectant rect x=groupe y = period
	var x : int 
	var y : int
	var max_x = 0
	var max_y = 0
	for k in range(57):
		var atom : main.Atom = table[k]
		x = atom.group 
		y = atom.Period
		max_x = max(x,max_x)
		max_y = max(y,max_y)
	
	number = Vector2(max_x+1,max_y+1)
	
	$TileMap.cell_size = bound/number#Vector2(bound.x/number.x,bound.y/number.y)
	
	for k in range(57):
		var atom : main.Atom = table[k]
		x = atom.group
		y = atom.Period
		add_button(x,y,atom.Symbol,atom.color,atom)
	
	
#	add_button(x + 1,y,"...",Color.white,"this is not valid data",false)
	# 57 <- 57 à 71
	#72 à 88 prise en compte offset1
	# 89 <- 89 à 103
	#104 à 118 prise en compte offset 1 et 2


func add_button(x,y,label,color,data,connect_it = true):
	var b = Button.new()
	b.rect_position = $TileMap.map_to_world(Vector2(x,y))
	b.modulate = color
	b.text = label
	b.rect_size = $TileMap.cell_size
	b.connect("button_down",self,"_on_button_pressed",[data])
	$buttons.add_child(b)
	
func _on_button_pressed(data):
	if data.has_method("display"):
		emit_signal("atom_choice",data)
