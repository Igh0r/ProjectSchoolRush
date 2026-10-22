extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("run_tests")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func run_tests() -> void:
	for kind in ["dice", "cloud", "centurion", "boss", "scientist", "cactus"]:
		var frames = load("res://assets/monsters/%s/frames.tres" % kind)
		check(frames is SpriteFrames and frames.get_frame_count("idle") == 4, "Idle precisa de quatro frames: " + kind)
		for animation in frames.get_animation_names():
			for i in range(frames.get_frame_count(animation)):
				var atlas: AtlasTexture = frames.get_frame_texture(animation, i)
				check(Rect2(Vector2.ZERO, atlas.atlas.get_size()).encloses(atlas.region), "Recorte deve estar dentro da folha: " + kind)
				check(atlas.atlas.get_image().get_pixel(0, 0).a == 0.0, "Fundo dos monstros deve ter transparência real")
		if kind in ["scientist", "cactus"]:
			check(frames.get_frame_count("attack") == 3, "Frame isolado de efeito não pode substituir o personagem")
	for kind in ["dice", "cloud", "centurion", "boss", "cactus", "scientist"]:
		var enemy = load("res://scenes/enemies/%s.tscn" % kind).instantiate()
		root.add_child(enemy)
		check(enemy.has_sprite(), "Cena deve ativar sprite: " + kind)
		check(enemy.scale == Vector2.ONE, "Arte não pode escalar corpo físico")
		var sprite = enemy.get_node("Visual/AnimatedSprite2D")
		check(sprite.scale == Vector2(0.16, 0.16), "Escala deve ficar no nó visual")
		var start_frame: int = sprite.frame
		await create_timer(0.2).timeout
		check(sprite.frame != start_frame, "Animação deve avançar: " + kind)
		paused = true
		var saved: int = sprite.frame
		await create_timer(0.2, true).timeout
		check(sprite.frame == saved, "Pausa deve congelar sprite: " + kind)
		paused = false
		enemy.queue_free()
	await process_frame
	print("ART TESTS: %d failure(s)" % failures)
	quit(1 if failures else 0)
