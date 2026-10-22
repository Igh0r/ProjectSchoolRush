extends "res://tests/capture_preview.gd"

func capture() -> void:
	DirAccess.make_dir_recursive_absolute("res://builds/previews")
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await save_preview("30-routes-menu")
	for index in range(4):
		game.start_run(1)
		game.room_index = index
		game._prepare_question()
		await save_preview("31-expedition-%d-choice" % index)
		game.choose_question(0)
		game.answer_question(int(game.questions.selected.correct))
		await save_preview("32-expedition-%d-tip" % index)
		game.begin_combat()
		for enemy in game.room.enemies:
			enemy.set_physics_process(false)
		await save_preview("33-expedition-%d-arena" % index)
		if index == 1:
			game.player.position = Vector2(400, 210)
			var cactus = game.room.enemies[1]
			cactus._lock_direction()
			cactus.queue_redraw()
			await save_preview("34-cactus-warning")
			cactus._physics_process(1.0)
			for shot in game.room.projectiles:
				shot.set_physics_process(false)
				shot.position += shot.direction * 65.0
			await save_preview("35-cactus-volley")
		if index == 2:
			game.player.position = Vector2(400, 210)
			var scientist = game.room.enemies[2]
			scientist.position = Vector2(600, 210)
			scientist._physics_process(0.01)
			var mixture = game.room.mixtures[0]
			mixture.set_physics_process(false)
			await save_preview("36-mixture-warning")
			game.player.position = Vector2(330, 210)
			mixture._physics_process(1.01)
			scientist._physics_process(1.01)
			await save_preview("37-mixture-active")
			root.size = Vector2i(1280, 720)
			await save_preview("38-mixture-resized")
			root.size = Vector2i(960, 540)
	game.queue_free()
	await process_frame
	await create_timer(0.2).timeout
	quit()
