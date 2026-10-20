extends Node2D

const ENEMY_SCENE = preload("res://scenes/enemy.tscn")
const TOWER_SCENE = preload("res://scenes/tower.tscn")
const MAX_HEALTH := 10
const WAVE_SIZES := [6, 9, 12]
const SPAWN_INTERVAL := 0.85

var base_health := MAX_HEALTH
var wave_number := 0
var wave_active := false
var game_over := false
var victory := false
var kills := 0
var spawn_left := 0
var spawn_clock := 0.0

@onready var content: VBoxContainer = $HUD/Sidebar/Content


func _ready() -> void:
	$HUD/Sidebar/Content/MenuButton.pressed.connect(_return_to_menu)
	content.get_node("WaveButton").pressed.connect(start_wave)
	$HUD/Result/Center/Card/Content/RestartButton.pressed.connect(_restart)
	$HUD/Result/Center/Card/Content/MenuButton.pressed.connect(_return_to_menu)
	for tower_position in $Map.TOWER_POSITIONS:
		var tower = TOWER_SCENE.instantiate()
		tower.position = tower_position
		$Towers.add_child(tower)
	update_hud()


func _process(delta: float) -> void:
	if not wave_active or game_over:
		return
	spawn_clock -= delta
	while spawn_left > 0 and spawn_clock <= 0.0:
		spawn_enemy()
		spawn_clock += SPAWN_INTERVAL
	if spawn_left == 0 and get_tree().get_nodes_in_group("enemies").is_empty():
		wave_active = false
		if wave_number == WAVE_SIZES.size():
			finish_game(true)
		else:
			content.get_node("Status").text = "這一波結束了。\n準備下一次防守。"
		update_hud()


func _return_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func start_wave() -> void:
	if wave_active or game_over or wave_number >= WAVE_SIZES.size():
		return
	wave_number += 1
	wave_active = true
	spawn_left = WAVE_SIZES[wave_number - 1]
	spawn_clock = SPAWN_INTERVAL
	spawn_enemy()
	content.get_node("Status").text = "敵人進攻中…\n守住綠色基地！"
	update_hud()


func spawn_enemy() -> void:
	var enemy = ENEMY_SCENE.instantiate()
	enemy.setup(40 + wave_number * 20, 80.0 + wave_number * 8.0)
	enemy.escaped.connect(_on_enemy_escaped)
	enemy.defeated.connect(_on_enemy_defeated)
	$Map/Route.add_child(enemy)
	spawn_left -= 1


func _on_enemy_escaped() -> void:
	if game_over:
		return
	base_health = maxi(0, base_health - 1)
	if base_health == 0:
		finish_game(false)
	update_hud()


func _on_enemy_defeated() -> void:
	if game_over:
		return
	kills += 1
	update_hud()


func finish_game(won: bool) -> void:
	if game_over:
		return
	game_over = true
	victory = won and base_health > 0
	wave_active = false
	get_tree().call_group("enemies", "set_physics_process", false)
	for tower in $Towers.get_children():
		tower.set_physics_process(false)
	var result = $HUD/Result/Center/Card/Content
	result.get_node("Title").text = "防守成功！" if victory else "基地失守"
	result.get_node("Summary").text = "完成波次  %d / 3\n擊退敵人  %d\n基地生命  %d / 10" % [wave_number, kills, base_health]
	content.get_node("Status").text = "三波防守完成。" if victory else "防線被突破了。"
	$HUD/Result.show()
	result.get_node("RestartButton").grab_focus()
	update_hud()


func _restart() -> void:
	get_tree().reload_current_scene()


func update_hud() -> void:
	content.get_node("HealthLabel").text = "基地  %d / %d" % [base_health, MAX_HEALTH]
	content.get_node("WaveLabel").text = "波次  %d / %d" % [wave_number, WAVE_SIZES.size()]
	content.get_node("KillsLabel").text = "擊退  %d" % kills
	content.get_node("WaveButton").disabled = wave_active or game_over or wave_number >= WAVE_SIZES.size()
