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
	if not ResourceLoader.exists("res://scenes/tower.tscn"):
		expect(false, "防禦塔場景尚未建立")
		quit(1)
		return
	var stage := Node2D.new()
	root.add_child(stage)
	var route := Path2D.new()
	route.curve = Curve2D.new()
	route.curve.add_point(Vector2.ZERO)
	route.curve.add_point(Vector2(1000, 0))
	stage.add_child(route)
	var enemy = load("res://scenes/enemy.tscn").instantiate()
	enemy.setup(60, 0.0)
	route.add_child(enemy)
	enemy.set_physics_process(false)
	var tower = load("res://scenes/tower.tscn").instantiate()
	stage.add_child(tower)
	tower.set_physics_process(false)
	enemy.progress = 400
	tower.tick(0.0)
	expect(enemy.health == 60, "塔不可攻擊射程外的敵人")
	enemy.progress = 100
	tower.tick(0.0)
	expect(enemy.health == 40, "射程內攻擊應扣除 20 生命")
	tower.tick(0.1)
	expect(enemy.health == 40, "冷卻期間不可攻擊")
	tower.tick(0.6)
	expect(enemy.health == 20, "冷卻結束應再次攻擊")
	var escape_count := [0]
	var death_count := [0]
	enemy.escaped.connect(func(): escape_count[0] += 1)
	enemy.defeated.connect(func(): death_count[0] += 1)
	tower.tick(1.0)
	expect(enemy.health == 0 and enemy.resolved, "致命攻擊應將生命歸零")
	expect(not enemy.is_in_group("enemies"), "死亡敵人應立即退出目標群組")
	enemy.take_damage(99)
	enemy.advance(999)
	expect(death_count[0] == 1 and escape_count[0] == 0, "死亡與漏怪事件只能擇一發生一次")
	stage.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: 射程、傷害、攻擊冷卻、敵人死亡與漏怪排他")
	quit(1 if failures else 0)
