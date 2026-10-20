extends SceneTree


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	create_timer(5.0).timeout.connect(func(): quit(1))
	if not ResourceLoader.exists("res://scenes/main_menu.tscn"):
		push_error("FAIL: 主選單場景尚未建立")
		quit(1)
		return
	var menu = load("res://scenes/main_menu.tscn").instantiate()
	root.add_child(menu)
	current_scene = menu
	menu.get_node("Center/Card/Content/StartButton").pressed.emit()
	await process_frame
	await process_frame
	if current_scene == null or current_scene.name != "Battlefield":
		push_error("FAIL: 開始按鈕未進入戰場")
		quit(1)
		return
	var route: Path2D = current_scene.get_node("Map/Route")
	if route.curve.get_baked_length() < 1000.0:
		push_error("FAIL: 地圖缺少完整路線")
		quit(1)
		return
	current_scene.get_node("HUD/Sidebar/Content/MenuButton").pressed.emit()
	await process_frame
	await process_frame
	if current_scene.name != "MainMenu":
		push_error("FAIL: 無法返回主選單")
		quit(1)
		return
	print("PASS: 主選單 → 戰場地圖 → 主選單")
	quit()
