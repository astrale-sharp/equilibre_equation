extends "res://addons/gut/test.gd"




func test_atoms():
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
	eau.number = 2
	assert_eq_deep(eau.get_atom_to_number(),{
		"H": 4,
		"O":2
	})


func test_bbcode():
	var atom1 = main.get_atom_list()[0]
	var atom3 = main.get_atom_list()[6]

	var atom_as1 := main.Atom_as_MolecPart.new()
	var atom_as2 := main.Atom_as_MolecPart.new()
	var atom_as3 := main.Atom_as_MolecPart.new()
	
	atom_as1.from_atom(atom1)
	atom_as2.from_atom(atom1)
	atom_as3.from_atom(atom3)

	atom_as1.number = 2
	atom_as2.number = 4

	assert_eq(atom_as1.to_bbcode(),"H[do]2[/do]")
	assert_eq(atom_as2.to_bbcode(),"H[do]4[/do]")
	assert_eq(atom_as3.to_bbcode(),"N","pas de [do] quand pas de stoech")


	var molecule1 = main.Molecule.new()
	var molecule2 = main.Molecule.new()

	molecule1.from([atom_as1])
	molecule2.from([atom_as2,atom_as3])

	molecule2.number=2
	
	assert_eq(molecule1.to_bbcode(),"H[do]2[/do]","pas de 1 stoech qui apparait")
	
	assert_eq(molecule2.to_bbcode(),"2 H[do]4[/do]N")

	var eqs1 = main.EquationSide.new()
	var eqs2 = main.EquationSide.new()

	eqs1.from_molecules([molecule1,molecule2])
	eqs2.from_molecules([molecule1])
	
	var eq := main.Equation.new()
	eq.from_sides(eqs1,eqs2)
	
	assert_eq(eqs1.to_bbcode(),"H[do]2[/do] + 2 H[do]4[/do]N")
	assert_eq(eqs2.to_bbcode(),"H[do]2[/do]")
	assert_eq(eq.to_bbcode(),"H[do]2[/do] + 2 H[do]4[/do]N -> H[do]2[/do]")

func test_stoech():
	var atom1 = main.get_atom_list()[0]

	var atom_as1 := main.Atom_as_MolecPart.new()
	var atom_as2 := main.Atom_as_MolecPart.new()
	atom_as1.from_atom(atom1)
	atom_as2.from_atom(atom1)
	atom_as1.number = 4
	atom_as2.number = 2

	var molecule1 = main.Molecule.new()
	var molecule2 = main.Molecule.new()
	molecule1.from([atom_as1])
	molecule2.from([atom_as2])
	molecule2.number=2
	var eqs1 = main.EquationSide.new()
	var eqs2 = main.EquationSide.new()
	eqs1.from_molecules([molecule1])
	eqs2.from_molecules([molecule2])
	var eq := main.Equation.new()
	eq.from_sides(eqs1,eqs2)
	assert_true(eq.is_equilibrated())



func test_atoms2number():
	var atom1 = main.get_atom_list()[0]
	var atom2 = main.get_atom_list()[0]

	var atom_as1 := main.Atom_as_MolecPart.new()
	var atom_as2 := main.Atom_as_MolecPart.new()
	atom_as1.from_atom(atom1)
	atom_as2.from_atom(atom1)
	atom_as2.number = 2

	var molecule1 = main.Molecule.new()
	var molecule2 = main.Molecule.new()
	molecule1.from([atom_as1])
	molecule2.from([atom_as2])
	molecule2.number=2
	var eqs1 = main.EquationSide.new()
	var eqs2 = main.EquationSide.new()
	eqs1.from_molecules([molecule1])
	eqs2.from_molecules([molecule2])
	var eq := main.Equation.new()
	eq.from_sides(eqs1,eqs2)
	gut.p(eqs1.atoms)
	gut.p(eqs2.atoms)



func test_is_not_equilibrated():
	var atom1 = main.get_atom_list()[0]
	var atom2 = main.get_atom_list()[0]

	var atom_as1 := main.Atom_as_MolecPart.new()
	var atom_as2 := main.Atom_as_MolecPart.new()
	atom_as1.from_atom(atom1)
	atom_as2.from_atom(atom1)
	atom_as2.number = 2

	var molecule1 = main.Molecule.new()
	var molecule2 = main.Molecule.new()
	molecule1.from([atom_as1])
	molecule2.from([atom_as2])
	var eqs1 = main.EquationSide.new()
	var eqs2 = main.EquationSide.new()
	eqs1.from_molecules([molecule1])
	eqs2.from_molecules([molecule2])
	var eq := main.Equation.new()
	eq.from_sides(eqs1,eqs2)

	assert_false(eq.is_equilibrated())


func test_is_equilibrated():
	var atom1 = main.get_atom_list()[0]
	var atom2 = main.get_atom_list()[0]

	var atom_as1 := main.Atom_as_MolecPart.new()
	var atom_as2 := main.Atom_as_MolecPart.new()
	atom_as1.from_atom(atom1)
	atom_as2.from_atom(atom1)

	var molecule1 = main.Molecule.new()
	var molecule2 = main.Molecule.new()
	molecule1.from([atom_as1])
	molecule2.from([atom_as2])
	var eqs1 = main.EquationSide.new()
	var eqs2 = main.EquationSide.new()
	eqs1.from_molecules([molecule1])
	eqs2.from_molecules([molecule2])
	var eq := main.Equation.new()
	eq.from_sides(eqs1,eqs2)

	assert_true(eq.is_equilibrated())
