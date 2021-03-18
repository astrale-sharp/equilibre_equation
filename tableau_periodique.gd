extends Node
class_name main


class Atom:
	extends Resource
	var AtomicNumber : int
	var Element : String
	var Symbol : String
	var Period : int
	var type : String
	var group : int
	var color : Color

	func copy() -> Atom:
		var a = Atom.new()
		a.AtomicNumber = AtomicNumber
		a.Element = Element
		a.Symbol = Symbol
		a.Period = Period
		a.type = type
		a.group = group
		a.color = color
		return a


	func display():
		return str(AtomicNumber,Element,Symbol,Period,type)

"""
one atom and his stoech as part of a molecule
"""
class Atom_as_MolecPart:
	extends Resource
	var number : int
	var atom : Atom
	var charge : int
	
	func from_atom(_atom : Atom)-> Atom_as_MolecPart:
		atom = _atom
		number = 1
		charge = 0
		return self


	func get_charge_repr():
		var text = " "
		var sign_ = ""
		if not charge == 0:
			if sign(charge) > 0: sign_ = "+"
			elif sign(charge) < 0: sign_ = "-"
			text = str(abs(charge)) + " " + sign_
		return text

	func get_stoech_repr():
		var text = str(number)
		if number == 1: text = ""
		return text
	
	func to_bbcode()-> String:
		var res = ""
		res += atom.Symbol
		if get_stoech_repr():
			res += "[do]"
			res += get_stoech_repr()
			res += "[/do]"
		if charge != 0:
			res += "[up]"
			var text = " "
			var sign_ = ""
			if not charge == 0:
				if sign(charge) > 0: sign_ = "+"
				elif sign(charge) < 0: sign_ = "-"
				text = str(abs(charge)) + " " + sign_
			res += text
			res += "[/up]"
		return res


	func display():
		return str(number) +" " + atom.display() +get_charge_repr()
	


class Molecule:
	extends Resource
	var name
	var number := 1
	var charge := 0
	var atoms := {} #atom2number in molecule
	var molecparts := []
	
	func copy()-> Molecule:
		var m = Molecule.new()
		return m.from(molecparts.duplicate(true))

	func from(molecPart_list):
		atoms = {}
		molecparts = molecPart_list
		molecparts.sort_custom(self,"sort_atoms")

		#1 passe pour leurs charge et nombre
		for m in molecparts:
			var molec_part : Atom_as_MolecPart = m

			if not molec_part.atom.Symbol in atoms.keys():
				atoms[molec_part.atom.Symbol] = 0

			atoms[molec_part.atom.Symbol] += molec_part.number
			charge += molec_part.charge
		return self
		
	#-------------features-------------#
	"""returns the atom -> number of time there is the atom in molec x stoech"""
	func get_atom_to_number()->Dictionary:
		var res = atoms.duplicate(true)
		for k in res.keys():
			res[k] *= number
		return res

	"""dosnet take the stoech into account"""
	func to_bbcode() -> String:
		var res : String = ""
		for m in molecparts:
			var molec_part : Atom_as_MolecPart = m
			res += molec_part.to_bbcode()
			
		return res
	
	func bbcode_explain():
		var res = \
	"""{0} molécule{2} de formule chimique: {1}.\npar molécule, on trouve:""".format([
										number,
										to_bbcode(),
										"s" if number > 1 else ""
									])
		for k in atoms:
			var v = atoms[k]
			res += "\n- {0} atomes de {1}".format([v,k])
		if number > 1:
			res += "\nComme il y a [b]{0}[/b] molécules, on trouve:".format([number,])
			
			var iter = get_atom_to_number()
			for k in iter:
				var v = iter[k]
				res += "\n- {0} atomes de {1}".format([v,k])
		return res

	func display():
		var res : String = ""
		res += str(number)
		res += " "
		for m in molecparts:
			var molec_part : Atom_as_MolecPart = m
			res += molec_part.atom.Symbol
			res += str(molec_part.number)
		var text = " "
		var sign_ = ""
		if not charge == 0:
			if sign(charge) > 0: sign_ = "+"
			elif sign(charge) < 0: sign_ = "-"
			text = str(abs(charge)) + " " + sign_
		res += text
		return res

	#------------private------------#
	func _sort_atoms(atom_a,atom_b):
		return atom_a.Symbol < atom_b.Symbol
	
class EquationSide:
	extends Resource
	var molecules := []
	var atoms := {}

	func empty():
		return molecules.empty()

	func from_molecules(array):
		molecules = array
		_atom_used()

	func _atom_used():
		atoms = {}
		var res = {}
		var arr = []
		for m in molecules:
			arr.append(m.get_atom_to_number())

		for atm2nbr in arr:
			for k in atm2nbr:
				var value = atm2nbr[k]
				if not k in res.keys():
					res[k] = 0
				res[k] += value

		atoms = res.duplicate(true)
	
	func display():
		var res = ""
		for k in molecules:
			res += k.display()
			res += " "
		return res

	func to_bbcode() -> String:
		var res : String = ""
		for m in molecules:
			res += m.to_bbcode()
			res += " + "
		return res.rstrip("+ ")
	
	func bbcode_explain():
		var res = "on trouve:\n"
		_atom_used()
		for k in atoms:
			var v = atoms[k]
			res += "- {0} atomes de {1}.\n".format([v,k])
		return res

class Equation:
	extends Resource
	var leftside : EquationSide
	var rightside : EquationSide


	func bbcode_explain():
		var table = "[table={number}]{content}[/table]"
		var _ceil = "{0}"
		# var _ceil = "[cell]{0}[/cell]"

		var res = table.format({
							"number" : 2,
							"content" : _ceil.format(["gauche"]) + _ceil.format(["droite"])
						})
		return res

	func to_bbcode():
		return leftside.to_bbcode() + " -> " + rightside.to_bbcode()

	func from_sides(l,r):
		leftside = l
		rightside = r
	#TESTME
	func is_valid():
		var l_res = leftside.atoms
		var r_res = rightside.atoms

		for k in l_res.keys():
			if not k in r_res: return false
		for k in r_res.keys():
			if not k in l_res: return false
		return true
	#TESTME
	"""
	compares 
	can fail
	"""
	func compare():
		var res = {}
		if not is_valid():return FAILED	
		var l_res = leftside.atoms
		var r_res = rightside.atoms
		for k in l_res.keys():
			var value_left = l_res[k]
			var value_right = r_res[k]
			if value_left != value_right:
				res[k] = [value_left, value_right]
		return res

	func is_equilibrated():
		var value = compare()
		if typeof(value) != TYPE_DICTIONARY:
			return false
		elif value.empty():
			return true
		else:
			return false
	
	func what_atoms_are_missing():
		var in_left_not_right = []
		var in_right_not_left = []
		var l_res = leftside.atoms
		var r_res = rightside.atoms
		for k in l_res.keys():
			if not k in r_res.keys():
				in_left_not_right.append(k)
		for k in r_res.keys():
			if not k in l_res.keys():
				in_right_not_left.append(k)
		return [in_left_not_right,in_right_not_left]
	func empty():
		return leftside.empty() and rightside.empty()

func charge2string(charge):
	var text = " "
	var sign_ = ""
	if not charge == 0:
		if sign(charge) > 0: sign_ = "+"
		elif sign(charge) < 0: sign_ = "-"
		text = str(abs(charge)) + " " + sign_
	return text

#----------------------------------MAIN-----------------------#
static func get_atom_list():
	var list = t.split("\n")
	var res := []
	for k in len(list):
		var my_list = list[k].split("\t",false)
		if len(my_list) == 0:continue
		var an_atom := Atom.new()
		an_atom.AtomicNumber = my_list[0]
		an_atom.Element = my_list[1]
		an_atom.Symbol = my_list[2]
		an_atom.Period = int(my_list[3]) - 1
		an_atom.type = my_list[4]
		an_atom.group = int(my_list[5]) - 1 if len(my_list) >= 6 else -1
		an_atom.color = Type2Color[an_atom.type]
		
		if not Type2Color.has(my_list[4]):
			printerr(str(my_list[1])," not has groupe")
			printerr(my_list[4])
		res.append(an_atom)
	return res
	

static func get_hydrogen():
	var atom = Atom_as_MolecPart.new()
	atom.from_atom( get_atom_list()[0])
	return atom
	
static func get_carbone():
	var atom = Atom_as_MolecPart.new()
	atom.from_atom(get_atom_list()[5])
	return atom
	
static func get_oxygen():
	var atom = Atom_as_MolecPart.new()
	atom.from_atom(get_atom_list()[7])
	return atom



#AtomicNumber	Element	Symbol	Period	Type
const Type2Color = {
	"Actinide":Color.rosybrown,
	"Alkali Metal":Color.red,
	"Alkaline Earth Metal":Color.yellowgreen,
	"Halogen":Color.yellow,
	"Lanthanide":Color.palevioletred,
	"Metal": Color.gray,
	"Metalloid":Color.palegoldenrod,
	"Noble Gas":Color.paleturquoise,
	"None":Color.white,
	"Nonmetal":Color.palegreen,
	"Transactinide":Color.white,
	"Transition Metal":Color.pink,
}
#AtomicNumber	Element	Symbol	Period	Type	Group
const t=\
"""1	Hydrogen	H	1	Nonmetal	1
2	Helium	He	1	Noble Gas	18
3	Lithium	Li	2	Alkali Metal	1
4	Beryllium	Be	2	Alkaline Earth Metal	2
5	Boron	B	2	Metalloid	13
6	Carbon	C	2	Nonmetal	14
7	Nitrogen	N	2	Nonmetal	15
8	Oxygen	O	2	Nonmetal	16
9	Fluorine	F	2	Halogen	17
10	Neon	Ne	2	Noble Gas	18
11	Sodium	Na	3	Alkali Metal	1
12	Magnesium	Mg	3	Alkaline Earth Metal	2
13	Aluminum	Al	3	Metal	13
14	Silicon	Si	3	Metalloid	14
15	Phosphorus	P	3	Nonmetal	15
16	Sulfur	S	3	Nonmetal	16
17	Chlorine	Cl	3	Halogen	17
18	Argon	Ar	3	Noble Gas	18
19	Potassium	K	4	Alkali Metal	1
20	Calcium	Ca	4	Alkaline Earth Metal	2
21	Scandium	Sc	4	Transition Metal	3
22	Titanium	Ti	4	Transition Metal	4
23	Vanadium	V	4	Transition Metal	5
24	Chromium	Cr	4	Transition Metal	6
25	Manganese	Mn	4	Transition Metal	7
26	Iron	Fe	4	Transition Metal	8
27	Cobalt	Co	4	Transition Metal	9
28	Nickel	Ni	4	Transition Metal	10
29	Copper	Cu	4	Transition Metal	11
30	Zinc	Zn	4	Transition Metal	12
31	Gallium	Ga	4	Metal	13
32	Germanium	Ge	4	Metalloid	14
33	Arsenic	As	4	Metalloid	15
34	Selenium	Se	4	Nonmetal	16
35	Bromine	Br	4	Halogen	17
36	Krypton	Kr	4	Noble Gas	18
37	Rubidium	Rb	5	Alkali Metal	1
38	Strontium	Sr	5	Alkaline Earth Metal	2
39	Yttrium	Y	5	Transition Metal	3
40	Zirconium	Zr	5	Transition Metal	4
41	Niobium	Nb	5	Transition Metal	5
42	Molybdenum	Mo	5	Transition Metal	6
43	Technetium	Tc	5	Transition Metal	7
44	Ruthenium	Ru	5	Transition Metal	8
45	Rhodium	Rh	5	Transition Metal	9
46	Palladium	Pd	5	Transition Metal	10
47	Silver	Ag	5	Transition Metal	11
48	Cadmium	Cd	5	Transition Metal	12
49	Indium	In	5	Metal	13
50	Tin	Sn	5	Metal	14
51	Antimony	Sb	5	Metalloid	15
52	Tellurium	Te	5	Metalloid	16
53	Iodine	I	5	Halogen	17
54	Xenon	Xe	5	Noble Gas	18
55	Cesium	Cs	6	Alkali Metal	1
56	Barium	Ba	6	Alkaline Earth Metal	2
57	Lanthanum	La	6	Lanthanide	3
58	Cerium	Ce	6	Lanthanide	
59	Praseodymium	Pr	6	Lanthanide	
60	Neodymium	Nd	6	Lanthanide	
61	Promethium	Pm	6	Lanthanide	
62	Samarium	Sm	6	Lanthanide	
63	Europium	Eu	6	Lanthanide	
64	Gadolinium	Gd	6	Lanthanide	
65	Terbium	Tb	6	Lanthanide	
66	Dysprosium	Dy	6	Lanthanide	
67	Holmium	Ho	6	Lanthanide	
68	Erbium	Er	6	Lanthanide	
69	Thulium	Tm	6	Lanthanide	
70	Ytterbium	Yb	6	Lanthanide	
71	Lutetium	Lu	6	Lanthanide	
72	Hafnium	Hf	6	Transition Metal	4
73	Tantalum	Ta	6	Transition Metal	5
74	Wolfram	W	6	Transition Metal	6
75	Rhenium	Re	6	Transition Metal	7
76	Osmium	Os	6	Transition Metal	8
77	Iridium	Ir	6	Transition Metal	9
78	Platinum	Pt	6	Transition Metal	10
79	Gold	Au	6	Transition Metal	11
80	Mercury	Hg	6	Transition Metal	12
81	Thallium	Tl	6	Metal	13
82	Lead	Pb	6	Metal	14
83	Bismuth	Bi	6	Metal	15
84	Polonium	Po	6	Metalloid	16
85	Astatine	At	6	Noble Gas	17
86	Radon	Rn	6	Alkali Metal	18
87	Francium	Fr	7	Alkaline Earth Metal	1
88	Radium	Ra	7	Actinide	2
89	Actinium	Ac	7	Actinide	3
90	Thorium	Th	7	Actinide	
91	Protactinium	Pa	7	Actinide	
92	Uranium	U	7	Actinide	
93	Neptunium	Np	7	Actinide	
94	Plutonium	Pu	7	Actinide	
95	Americium	Am	7	Actinide	
96	Curium	Cm	7	Actinide	
97	Berkelium	Bk	7	Actinide	
98	Californium	Cf	7	Actinide	
99	Einsteinium	Es	7	Actinide	
100	Fermium	Fm	7	Actinide	
101	Mendelevium	Md	7	Actinide	
102	Nobelium	No	7	Actinide	
103	Lawrencium	Lr	7	Actinide	
104	Rutherfordium	Rf	7	Transactinide	4
105	Dubnium	Db	7	Transactinide	5
106	Seaborgium	Sg	7	Transactinide	6
107	Bohrium	Bh	7	Transactinide	7
108	Hassium	Hs	7	Transactinide	8
109	Meitnerium	Mt	7	Transactinide	9
110	Darmstadtium 	Ds 	7	Transactinide	10
111	Roentgenium 	Rg 	7	Transactinide	11
112	Copernicium 	Cn 	7	Transactinide	12
113	Nihonium	Nh	7	None	13
114	Flerovium	Fl	7	Transactinide	14
115	Moscovium	Mc	7	None	15
116	Livermorium	Lv	7	Transactinide	16
117	Tennessine	Ts	7	None	17
118	Oganesson	Og	7	Noble Gas	18"""
