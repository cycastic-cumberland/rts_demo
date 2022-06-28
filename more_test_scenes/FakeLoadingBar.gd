extends Control


func change_percentage(p: float):
	$ProgressBar.value = p * 100.0
#	print(p)
