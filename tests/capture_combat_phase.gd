extends "res://tests/capture_preview.gd"

func capture() -> void:
	DirAccess.make_dir_recursive_absolute("res://builds/previews")
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.start_run(1)
	game.choose_question(0)
	game.answer_question(0)
	game.begin_combat()
	game.room.clear_enemies()
	game.room.set_combat(true)
	game.player.position = Vector2(330, 210)
	var cactus = game.room.spawn_enemy("cactus", Vector2(570, 210), game.player)
	var guard = game.room.spawn_enemy("centurion", Vector2(430, 310), game.player)
	cactus.set_physics_process(false)
	guard.set_physics_process(false)
	guard.phase = guard.Phase.RECOVERY
	guard.phase_time = 1.1
	guard.queue_redraw()
	await save_preview("40-cactus-narrow-guard-open")
	cactus.spread = 0.50
	cactus.queue_redraw()
	await save_preview("41-cactus-wide")
	root.size = Vector2i(1280, 720)
	await save_preview("42-combat-resized")
	root.size = Vector2i(960, 540)
	game.start_run()
	game.room_index = 3
	game.choose_question(0)
	game.answer_question(0)
	await save_preview("43-boss-tip")
	game.begin_combat()
	var boss = game.room.enemies[0]
	boss.set_physics_process(false)
	game.player.position = Vector2(510, 210)
	boss.phase = boss.Phase.APPROACH
	boss.phase_time = 1.6
	boss._physics_process(0.01)
	await save_preview("44-boss-sweep-warning")
	game.player.position = Vector2(510, 345)
	boss._physics_process(0.91)
	await save_preview("45-boss-sweep")
	boss._physics_process(0.21)
	await save_preview("46-boss-recovery")
	root.size = Vector2i(1280, 720)
	boss._physics_process(1.21)
	await save_preview("47-boss-charge-warning")
	root.size = Vector2i(960, 540)
	game.start_run(1)
	game.room_index = 2
	game.choose_question(0)
	game.answer_question(0)
	game.begin_combat()
	game.room.clear_enemies()
	game.room.set_combat(true)
	game.player.position = Vector2(65, 65)
	var cloud = game.room.spawn_enemy("cloud", Vector2(250, 65), game.player)
	var scientist = game.room.spawn_enemy("scientist", Vector2(250, 150), game.player)
	guard = game.room.spawn_enemy("centurion", Vector2(150, 65), game.player)
	for enemy in game.room.enemies:
		enemy.set_physics_process(false)
	cloud._physics_process(0.01)
	scientist._physics_process(0.01)
	guard._physics_process(0.01)
	var mixture = game.room.mixtures[0]
	mixture.set_physics_process(false)
	await save_preview("48-mixed-corner-warning")
	game.player.position = Vector2(65, 230)
	cloud._physics_process(0.81)
	mixture._physics_process(1.01)
	for shot in game.room.projectiles:
		shot.set_physics_process(false)
	await save_preview("49-mixed-corner-hazards")
	await process_frame
	game.queue_free()
	await process_frame
	await create_timer(0.2).timeout
	quit()
