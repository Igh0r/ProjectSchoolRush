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
	await process_frame
	game.queue_free()
	await process_frame
	await create_timer(0.2).timeout
	quit()
