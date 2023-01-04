extends Control

var start_epoch := 0

func _ready():
	start_epoch = Time.get_ticks_usec()

func _exit_tree():
	var end_epoch := Time.get_ticks_usec()
	Out.print_warning("Loading time (msec): " \
		+ str((end_epoch - start_epoch) / 1000.0))

func change_percentage(p: float):
	$ProgressBar.value = p * 100.0
#	print(p)
