extends Control

func add_button(button: Button, bellow: Node = null):
	add_defered(button, bellow)

func add_defered(button: Button, bellow: Node):
	if is_instance_valid(button.get_parent()):
		Out.print_error("Button already has a parent", get_stack())
		return
	if is_instance_valid(bellow):
		call_deferred("add_child_below_node", button, bellow)
	else:
		call_deferred("add_child", button)
	button.owner = owner
