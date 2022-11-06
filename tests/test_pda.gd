extends GutTest

class State_TestAtom1 extends State:
	func _init():
		state_name = "State_TestAtom1"

	func _start(with: StateAutomaton):
		with.client.append("UwU")

	func _poll(with: StateAutomaton):
		with.client.append("Awawawawa")
		return "__next"

	func _finalize(with: StateAutomaton):
		with.client.erase("UngaBunga")

class State_TestAtom2 extends State:
	func _init():
		state_name = "State_TestAtom2"

	func _start(_with: StateAutomaton):
		pass

	func _poll(with: StateAutomaton):
		with.client.append("OmO")
		if "A" in with.client:
			return "__stop"
		return "__next"

	func _finalize(_with: StateAutomaton):
		pass

class State_TestAtom3 extends State:
	func _init():
		state_name = "State_TestAtom3"

	func _start(with: StateAutomaton):
		with.client.append("UngaBunga")

	func _poll(with: StateAutomaton):
		with.client.append("A")
		return "__first"

	func _finalize(with: StateAutomaton):
		with.client.append("I'm Skyler White Yo")

class State_TestAtom4 extends State:
	func _init():
		state_name = "State_TestAtom4"

	func _start(with: StateAutomaton):
		with.client.name = "UngaBoomaga"

func initialization_test(which: String):
	var instance = ClassDB.instance(which)
	assert_eq(instance != null, true, "Could not instance class " + which)
	return instance

func test_pda():
	var ins: PushdownAutomaton = initialization_test("PushdownAutomaton")
	if not ins: return
	var _a
	_a = ins.add_state(State_TestAtom1.new())
	_a = ins.add_state(State_TestAtom2.new())
	_a = ins.add_state(State_TestAtom3.new())
	assert_eq(ins.get_all_states().size(), 3, "Failed to initialize 3 unique states")

func test_state():
	var ins: State = initialization_test("State")
	if not ins: return
	var new_state := State_TestAtom1.new()
	assert_eq(new_state.state_name.begins_with("State_TestAtom"), true, "Incorrect State's name")

func test_state_automaton():
	var ins: StateAutomaton = initialization_test("StateAutomaton")
	if not ins: return
	var pda := PushdownAutomaton.new()
	var ser := Serializable.new()
	var _a
	_a = pda.add_state(State_TestAtom1.new())
	_a = pda.add_state(State_TestAtom2.new())
	_a = pda.add_state(State_TestAtom3.new())
	ins.pda = pda
	ins.client = []
	ins.boot()
	ins.poll(PI)
	ins.finalize()
	var pda2 := PushdownAutomaton.new()
	_a = pda2.add_state(State_TestAtom4.new())
	var ins2 := StateAutomaton.new()
	ins2.pda = pda2
	ins2.client = ser
	ins2.boot()
	assert_eq(ins.client.size(), 7, "Unexpected Array size")
	assert_eq(pda.get_state_by_name("UnchaBucha"), null, "Unexpected state find value")
	assert_eq(abs(ins.get_delta() - PI) < 0.0001, true, "Unexpected delta value")
	assert_eq(ser.name, "UngaBoomaga", "Unexpected serializable's name")
#	gut.p(str(ins.client))

