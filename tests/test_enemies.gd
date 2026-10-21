extends SceneTree

var failures: int = 0

func _initialize() -> void:
	call_deferred("run_tests")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func run_tests() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.start_run()
	game.choose_question(0)
	game.answer_question(0)
	game.begin_combat()
	game.room.clear_enemies()
	game.room.set_combat(true)
	game.player.position = Vector2(400, 210)
	var cloud = game.room.spawn_enemy("cloud", Vector2(600, 210), game.player)
	var guard = game.room.spawn_enemy("centurion", Vector2(480, 210), game.player)
	cloud.set_physics_process(false)
	guard.set_physics_process(false)
	await physics_frame
	await physics_frame
	check(cloud.health == 25 and guard.health == 45, "Cenas devem inicializar vida própria")
	check(cloud.has_node("Visual/AnimatedSprite2D") and guard.has_node("CollisionShape2D"), "Cenas precisam de visual separado da colisão")
	check(not cloud.has_sprite(), "Cena sem frames deve manter arte provisória")
	var frames := SpriteFrames.new()
	frames.add_animation("idle")
	var pixels := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	pixels.fill(Color.WHITE)
	frames.add_frame("idle", ImageTexture.create_from_image(pixels))
	cloud.get_node("Visual/AnimatedSprite2D").sprite_frames = frames
	cloud._update_visual("move")
	check(cloud.has_sprite(), "Sprite com idle deve funcionar mesmo sem animação move")
	check(cloud.get_node("CollisionShape2D").shape.radius == 16.0, "Sprite não deve alterar colisão")
	cloud._physics_process(0.01)
	check(cloud.phase == cloud.Phase.WARNING and game.room.projectiles.is_empty(), "Nuvem deve avisar antes de disparar")
	var locked: Vector2 = cloud.shot_direction
	game.player.position = Vector2(400, 290)
	cloud._physics_process(0.4)
	check(cloud.shot_direction == locked and game.room.projectiles.is_empty(), "Mira da nuvem deve permanecer fixa durante aviso")
	cloud._physics_process(0.41)
	check(game.room.projectiles.size() == 1 and cloud.phase == cloud.Phase.RECOVERY, "Aviso deve gerar só um disparo e recuperação")
	var shot = game.room.projectiles[0]
	shot.set_physics_process(false)
	check(shot.direction == locked, "Projétil deve usar mira anunciada")
	cloud._physics_process(0.2)
	check(game.room.projectiles.size() == 1, "Recuperação não pode disparar novamente")
	game.room.clear_projectiles()
	game.player.position = Vector2(400, 210)
	await physics_frame
	await physics_frame
	# Passo longo exige colisão varrida; o projétil não pode atravessar o jogador.
	game.room._spawn_projectile(cloud, Vector2(300, 210), Vector2.RIGHT)
	shot = game.room.projectiles[0]
	shot.set_physics_process(false)
	var before: int = game.player.health
	shot._physics_process(1.0)
	check(game.player.health == before - 12 and game.room.projectiles.is_empty(), "Projétil deve causar um dano e desaparecer")
	game.player.invulnerability = 0.0
	shot._physics_process(1.0)
	check(game.player.health == before - 12, "Projétil consumido não pode causar dano novamente")
	game.room._spawn_projectile(cloud, Vector2(750, 100), Vector2.RIGHT)
	shot = game.room.projectiles[0]
	shot.set_physics_process(false)
	shot._physics_process(1.0)
	check(game.room.projectiles.is_empty(), "Parede deve bloquear e remover projétil")
	game.room._spawn_projectile(cloud, Vector2(500, 100), Vector2.LEFT)
	shot = game.room.projectiles[0]
	shot.set_physics_process(false)
	shot._physics_process(4.0)
	check(game.room.projectiles.is_empty(), "Tempo de vida deve limitar projéteis")
	# Golpe anunciado: sem contato passivo, direção travada e oportunidade de esquiva.
	before = game.player.health
	guard._physics_process(0.01)
	check(guard.phase == guard.Phase.WARNING and game.player.health == before, "Centurião não deve causar dano ao iniciar aviso")
	locked = guard.attack_direction
	game.player.position = Vector2(550, 210)
	guard._physics_process(0.76)
	check(guard.attack_direction == locked and game.player.health == before, "Sair do cone deve evitar golpe; direção não acompanha jogador")
	guard._physics_process(0.19)
	check(guard.phase == guard.Phase.RECOVERY, "Golpe deve abrir recuperação")
	game.player.position = Vector2(400, 210)
	guard.phase = guard.Phase.APPROACH
	guard._physics_process(0.01)
	guard._physics_process(0.76)
	check(game.player.health == before - 18, "Jogador dentro do cone deve receber dano no golpe")
	game.player.invulnerability = 0.0
	guard._physics_process(0.05)
	check(game.player.health == before - 18, "Um golpe não pode atingir duas vezes")
	# Pausa real deve congelar os novos ataques e os projéteis.
	cloud.phase = cloud.Phase.WARNING
	cloud.phase_time = 0.6
	guard.phase = guard.Phase.WARNING
	guard.phase_time = 0.6
	cloud.set_physics_process(true)
	guard.set_physics_process(true)
	game.room._spawn_projectile(cloud, Vector2(600, 100), Vector2.LEFT)
	shot = game.room.projectiles[0]
	var saved_position: Vector2 = shot.position
	var saved_lifetime: float = shot.lifetime
	game.toggle_pause()
	for i in range(5):
		await physics_frame
	check(cloud.phase_time == 0.6 and guard.phase_time == 0.6, "Pausa deve congelar temporizadores dos monstros")
	check(shot.position == saved_position and shot.lifetime == saved_lifetime, "Pausa deve congelar projéteis")
	game.toggle_pause()
	cloud.set_physics_process(false)
	guard.set_physics_process(false)
	var deaths := [0]
	cloud.died.connect(func(_enemy: Node): deaths[0] += 1)
	cloud.take_damage(-10)
	check(cloud.health == 25, "Dano negativo não deve curar inimigo")
	cloud.take_damage(1000)
	cloud.take_damage(1000)
	cloud._physics_process(10.0)
	check(deaths[0] == 1 and game.room.projectiles.is_empty(), "Morte deve emitir uma vez e cancelar tiros da nuvem")
	guard.take_damage(1000)
	guard._physics_process(10.0)
	await process_frame
	check(game.state == game.State.CLEARED, "Morte dos novos inimigos deve concluir sala")
	game.start_run()
	check(game.room.enemies.is_empty() and game.room.projectiles.is_empty(), "Reinício deve limpar monstros e tiros")
	await process_frame
	game.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	print("ENEMIES TESTS: %d failure(s)" % failures)
	quit(1 if failures else 0)
