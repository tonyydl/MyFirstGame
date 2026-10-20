extends Control


func _ready() -> void:
	$Center/Card/Content/StartButton.pressed.connect(_start_game)
	$Center/Card/Content/QuitButton.pressed.connect(get_tree().quit)
	$Center/Card/Content/StartButton.grab_focus()


func _start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/battlefield.tscn")
