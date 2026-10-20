extends SceneTree

var failures := 0


func _initialize() -> void:
	call_deferred("run")


func expect(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("FAIL: " + message)


func run() -> void:
	create_timer(5.0).timeout.connect(func(): quit(1))
	if not ResourceLoader.exists("res://scenes/enemy.tscn"):
		expect(false, "敵人場景尚未建立")
		quit(1)
		return
	var game = load("res://scenes/battlefield.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.start_wave()
	game.set_process(false)
	expect(game.wave_active, "開始波次後應鎖住下一波")
	expect(game.get_node("HUD/Sidebar/Content/WaveButton").disabled, "波次按鈕應停用")
	var enemy = game.get_node("Map/Route").get_child(0)
	enemy.set_physics_process(false)
	enemy.speed = 90.0
	expect(enemy.position.is_equal_approx(Vector2(40, 250)), "敵人應從入口出生")
	enemy.advance(0.5)
	enemy.advance(0.5)
	expect(is_equal_approx(enemy.progress, 90.0), "移動距離應等於速度乘時間")
	expect(enemy.position.is_equal_approx(Vector2(130, 250)), "敵人應沿路線移動")
	enemy.advance(3.0)
	expect(enemy.position.distance_to(Vector2(240, 410)) < 1.0, "大 delta 應沿路線轉彎，實際：%s" % enemy.position)
	enemy.advance(100.0)
	expect(game.base_health == 9, "抵達終點應扣一點基地生命")
	enemy.advance(100.0)
	expect(game.base_health == 9, "已抵達敵人不可重複扣血")
	game.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: 波次鎖定、依時間沿路線移動、轉彎、終點只扣血一次")
	quit(1 if failures else 0)
