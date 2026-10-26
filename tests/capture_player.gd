extends "res://tests/capture_preview.gd"

func capture() -> void:
	DirAccess.make_dir_recursive_absolute("res://builds/previews")
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.start_run(1)
	game.choose_question(0)
	game.answer_question(game.questions.selected.correct)
	game.begin_combat()
	game.room.clear_enemies()
	game.room.spawn_enemy("dice", Vector2(550, 180), game.player)
	game.room.spawn_enemy("centurion", Vector2(600, 290), game.player)
	game.player.set_physics_process(false)
	var directions := {"down": Vector2.DOWN, "left": Vector2.LEFT, "right": Vector2.RIGHT, "up": Vector2.UP}
	for name in directions:
		game.player.reset_run()
		game.player.active = true
		game.player.position = Vector2(400, 210)
		game.player.facing = directions[name]
		game.player._update_visual()
		await save_preview("e6-idle-" + name)
		game.player.velocity = directions[name] * game.player.speed
		game.player._update_visual()
		game.player.visual.set_frame_and_progress(2, 0)
		game.player.visual.pause() # Captura um quadro de caminhada; avanço real é coberto na suíte.
		await save_preview("e6-walk-" + name)
		game.player.attack()
		game.player.visual.pause() # Quadro do impacto para comparar arte e alcance.
		await save_preview("e6-attack-" + name)
	game.player.reset_run()
	game.player.active = true
	game.player.facing = Vector2(1, -1).normalized()
	game.player.attack()
	game.player.visual.pause()
	await save_preview("e6-diagonal")
	game.player.take_damage(10)
	await save_preview("e6-hurt")
	root.size = Vector2i(1280, 720)
	game.room.set_room_theme(3)
	game.player.reset_run()
	game.player._update_visual()
	await save_preview("e6-resized-gym")
	game.start_training()
	await save_preview("e6-training")
	game.music.stop()
	game.music.stream = null
	game.sounds.set_preferences(0, true)
	await process_frame
	game.queue_free()
	await process_frame
	await create_timer(0.2).timeout
	quit()
