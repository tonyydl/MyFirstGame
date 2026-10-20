extends SceneTree

var failures := 0


func _initialize() -> void:
	call_deferred("run")


func expect(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("FAIL: " + message)


func run() -> void:
	create_timer(15.0).timeout.connect(func(): quit(1))
	var game = load("res://scenes/battlefield.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	game.process_mode = Node.PROCESS_MODE_DISABLED
	if not game.has_method("finish_game"):
		expect(false, "勝敗流程尚未建立")
		quit(1)
		return
	# Drive the real spawner, enemies and towers at a fixed simulation step.
	var checked_final_pending := false
	for wave in range(3):
		game.start_wave()
		game.start_wave()
		expect(game.wave_number == wave + 1, "連按開始不能跳過波次")
		for frame in range(12000):
			game._process(1.0 / 60.0)
			for enemy in get_nodes_in_group("enemies"):
				enemy.advance(1.0 / 60.0)
			for tower in game.get_node("Towers").get_children():
				tower.tick(1.0 / 60.0)
			if wave == 2 and game.spawn_left == 0 and not get_nodes_in_group("enemies").is_empty() and not checked_final_pending:
				expect(not game.game_over, "最後一波出生完但仍有敵人時不能勝利")
				checked_final_pending = true
			if not game.wave_active:
				break
		expect(not game.wave_active, "每一波都必須能結束")
		expect(game.base_health > 0, "預設塔應足以守住三波敵人")
		if wave < 2:
			expect(not game.game_over, "前兩波清空後不可提早勝利")
	expect(game.game_over and game.victory, "第三波清空後應勝利")
	expect(checked_final_pending, "必須實際驗證最後一波等待殘餘敵人清空")
	expect(game.kills > 0, "擊退計數應更新")
	expect(game.get_node("HUD/Result").visible, "結束時應顯示結果介面")
	# Restart through the actual button, rather than resetting fields in the test.
	game.get_node("HUD/Result/Center/Card/Content/RestartButton").pressed.emit()
	await process_frame
	await process_frame
	game = current_scene
	game.process_mode = Node.PROCESS_MODE_DISABLED
	expect(game.base_health == 10 and game.wave_number == 0 and game.kills == 0, "重玩應重置狀態")
	# One remaining base HP: a single escape must lose and stop other actors.
	game.start_wave()
	game.start_wave()
	expect(game.wave_number == 1, "進攻中不可再開一波")
	game.base_health = 1
	game.spawn_enemy()
	var survivor = game.get_node("Map/Route").get_child(1)
	var enemy = game.get_node("Map/Route").get_child(0)
	enemy.advance(999.0)
	expect(game.base_health == 0 and game.game_over and not game.victory, "基地歸零應失敗")
	expect(not survivor.is_physics_processing(), "失敗後必須停止仍存活的敵人")
	var remaining_spawns: int = game.spawn_left
	game._process(999.0)
	expect(game.spawn_left == remaining_spawns, "失敗後不可繼續生成敵人")
	game.start_wave()
	expect(game.wave_number == 1, "失敗後不可開始下一波")
	expect(not game.get_node("Towers").get_child(0).is_physics_processing(), "結束後應停止塔攻擊")
	game.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: 三波實際戰鬥、勝利、重玩重置、基地失敗、波次防重入")
	quit(1 if failures else 0)
