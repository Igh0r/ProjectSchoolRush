extends "res://tests/capture_preview.gd"

func capture() -> void:
	DirAccess.make_dir_recursive_absolute("res://builds/previews")
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.start_run()
	game.choose_question(0)
	game.answer_question(0)
	game.begin_combat()
	game.room.clear_enemies()
	game.room.set_combat(true)
	game.player.position = Vector2(350, 300)
	var cloud = game.room.spawn_enemy("cloud", Vector2(520, 140), game.player)
	var guard = game.room.spawn_enemy("centurion", Vector2(440, 300), game.player)
	cloud.set_physics_process(false)
	guard.set_physics_process(false)
	cloud._physics_process(0.01)
	guard._physics_process(0.01)
	await save_preview("21-monsters-warning")
	cloud._physics_process(0.81)
	for shot in game.room.projectiles:
		shot.set_physics_process(false)
		shot.position += shot.direction * 80.0
	guard._physics_process(0.76)
	await save_preview("22-monsters-strike")
	guard._physics_process(0.19)
	await save_preview("23-monsters-recovery")
	root.size = Vector2i(1280, 720)
	guard.phase = guard.Phase.WARNING
	guard.queue_redraw()
	cloud.phase = cloud.Phase.WARNING
	cloud.queue_redraw()
	await save_preview("24-monsters-resized")
	root.size = Vector2i(960, 540)
	for room_index in [1, 2]:
		game.start_run()
		game.room_index = room_index
		game._prepare_question()
		game.choose_question(0)
		game.answer_question(int(game.questions.selected.correct))
		await save_preview("25-room-%d-tip" % (room_index + 1))
		game.begin_combat()
		await save_preview("26-room-%d-encounter" % (room_index + 1))
	game.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	quit()
