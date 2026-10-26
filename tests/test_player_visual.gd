extends SceneTree

var failures: int = 0
var strikes: int = 0

func _initialize() -> void:
	call_deferred("run_tests")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func run_tests() -> void:
	var frames: SpriteFrames = load("res://school_rush_player/student_frames.tres")
	check(frames.get_animation_names().size() == 8, "Estudante deve ter oito animações fornecidas")
	for direction in ["down", "left", "right", "up"]:
		for action in ["walk", "attack"]:
			var animation_name: String = action + "_" + direction
			check(frames.get_frame_count(animation_name) == 6, "Cada animação deve conter seis quadros")
			check(frames.get_animation_loop(animation_name) == (action == "walk"), "Só caminhada deve repetir")
			for i in range(6):
				var texture: Texture2D = frames.get_frame_texture(animation_name, i)
				check(texture.get_size() == Vector2(224, 192), "Quadros devem preservar dimensões originais")
				var pixels: Image = texture.get_image()
				check(pixels.get_pixel(0, 0).a == 0 and pixels.get_used_rect().has_area(), "Quadro deve ser visível com fundo transparente")
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	var player = game.player
	var sprite: AnimatedSprite2D = player.visual
	check(sprite.sprite_frames == frames and sprite.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Cena deve usar arte fornecida com Nearest")
	check(player.scale == Vector2.ONE and player.get_node("CollisionShape2D").shape.radius == 15.0, "Arte não pode mudar colisão do Estudante")
	check(sprite.animation == "walk_down" and sprite.frame == 0 and not sprite.is_playing(), "Menu deve mostrar repouso para baixo")
	game.start_training()
	player.position = Vector2(400, 300)
	for action in ["move_left", "move_right", "move_up", "move_down"]:
		Input.action_press(action)
		for i in range(12):
			await physics_frame
		check(sprite.animation == action.replace("move", "walk") and sprite.is_playing(), "Movimento deve selecionar vista correspondente")
		check(sprite.frame > 0, "Caminhada deve avançar quadros")
		Input.action_release(action)
		await physics_frame
		await physics_frame
		check(sprite.frame == 0 and not sprite.is_playing(), "Parar deve restaurar repouso na última direção")
	Input.action_press("move_right")
	Input.action_press("sprint")
	await physics_frame
	await physics_frame
	check(is_equal_approx(sprite.speed_scale, 1.4), "Corrida deve acelerar caminhada junto ao deslocamento")
	Input.action_release("move_right")
	Input.action_release("sprint")
	player.facing = Vector2(1, -1).normalized()
	player.velocity = Vector2.ZERO
	player._update_visual()
	check(sprite.animation == "walk_up", "Diagonal usa vista vertical sem alterar direção física")
	check(player.facing.is_equal_approx(Vector2(1, -1).normalized()), "Seleção visual não pode quantizar a direção do golpe")
	# Exercita o golpe real contra um alvo passivo, mantendo saúde alta para não concluir a sala.
	game.training.stop()
	game.room.clear_enemies()
	var target = game.room.spawn_enemy("dice", Vector2(440, 210), player)
	game.room.combat_active = true
	target.health = 1000
	player.attacked.connect(func(_origin, _direction, _damage): strikes += 1)
	for direction in [Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT, Vector2.UP]:
		player.position = Vector2(400, 210)
		target.position = player.position + direction * 40
		player.facing = direction
		player.attack_cooldown = 0
		var before: int = target.health
		var before_strikes: int = strikes
		player.attack()
		var attack_name: String = "attack_" + player._visual_direction(direction)
		check(sprite.animation == attack_name and sprite.frame == 3 and player.attack_visual_active, "Ataque deve começar no impacto da direção correta")
		check(target.health == before - player.damage and strikes == before_strikes + 1, "Animação deve preservar dano imediato e único")
		player.facing = -direction
		player._update_visual()
		check(sprite.animation == attack_name and player.attack_direction == direction, "Mudar orientação após golpe não pode girar a animação ou cone já disparado")
		player.attack()
		check(strikes == before_strikes + 1, "Repetir ataque na recarga não deve reiniciar dano/animação")
		for i in range(16):
			await physics_frame
		check(not player.attack_visual_active and sprite.animation.begins_with("walk_"), "Recuperação deve retornar ao repouso sem travar")
		check(target.health == before - player.damage, "Avançar frames nunca pode reaplicar dano")
	player.attack_cooldown = 0
	player.attack()
	game.toggle_pause()
	var frame_before: int = sprite.frame
	var progress_before: float = sprite.frame_progress
	var cooldown_before: float = player.attack_cooldown
	await create_timer(0.25, true).timeout
	check(sprite.frame == frame_before and sprite.frame_progress == progress_before and player.attack_cooldown == cooldown_before, "Pausa deve congelar quadros e recarga juntos")
	game.toggle_pause()
	player.active = false
	check(not sprite.is_playing() and not player.attack_visual_active and sprite.frame == 0, "Fim de atividade deve interromper ataque visual")
	player.active = true
	player.take_damage(10)
	check(sprite.modulate != Color.WHITE, "Dano deve ter retorno visual")
	player.invulnerability = 0
	player.take_damage(1000)
	check(not sprite.is_playing() and sprite.modulate == Color(0.6, 0.6, 0.6), "Derrota deve congelar e escurecer o Estudante")
	game.start_run()
	check(sprite.animation == "walk_down" and sprite.frame == 0 and sprite.modulate == Color.WHITE and not player.attack_visual_active, "Reinício deve limpar orientação, ataque e dano visuais")
	game.music.stop()
	game.music.stream = null
	game.sounds.set_preferences(0, true)
	await process_frame
	game.queue_free()
	await process_frame
	await create_timer(0.2).timeout
	print("PLAYER VISUAL TESTS: %d failure(s)" % failures)
	quit(1 if failures else 0)
