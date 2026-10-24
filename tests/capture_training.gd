extends "res://tests/capture_preview.gd"

func capture() -> void:
	DirAccess.make_dir_recursive_absolute("res://builds/previews")
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await save_preview("e5-menu")
	for resolution in [Vector2i(960, 540), Vector2i(1280, 720)]:
		root.size = resolution
		game.start_training()
		await save_preview("e5-%d-move" % resolution.x)
		game.player.position = game.training.WALK_MARKER
		game.training._physics_process(0)
		await save_preview("e5-%d-sprint" % resolution.x)
		game.player.position = game.training.RUN_MARKER
		game.training.sprint_distance = game.training.REQUIRED_SPRINT_DISTANCE
		game.training._physics_process(0)
		await save_preview("e5-%d-target" % resolution.x)
		game.toggle_pause()
		await save_preview("e5-%d-pause" % resolution.x)
		game.toggle_pause()
		game.player.position = game.training.TARGET_POINT + Vector2(-40, 0)
		game.player.facing = Vector2.RIGHT
		for i in range(3):
			game.player.attack_cooldown = 0
			game.player.attack()
		game.training._physics_process(0)
		await save_preview("e5-%d-exit" % resolution.x)
		game.player.position = game.room.DOOR
		game.advance_room()
		await save_preview("e5-%d-complete" % resolution.x)
	await process_frame
	game.queue_free()
	await process_frame
	await create_timer(0.2).timeout
	quit()
