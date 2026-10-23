extends SceneTree

const CATALOG = preload("res://scripts/systems/curriculum_catalog.gd")
var failures: int = 0

func _initialize() -> void:
	var catalog = CATALOG.new()
	check(catalog.errors.is_empty(), "Catálogo de produção inválido")
	var original: Dictionary = catalog.data
	check(original.questions.size() == 80, "Entrega D1 deve conter oitenta questões")
	var prompts: Dictionary = {}
	for subject in original.subjects:
		var count := 0
		var topics: Dictionary = {}
		var difficulties := {"basic": 0, "intermediate": 0, "challenge": 0}
		for question in original.questions:
			if question.subject == subject.id:
				count += 1
				topics[question.topic] = true
				var prompt: String = question.prompt.strip_edges().to_lower()
				check(not prompts.has(prompt), "Enunciado de produção repetido: " + question.id)
				prompts[prompt] = true
				if difficulties.has(question.get("difficulty")):
					difficulties[question.difficulty] += 1
		check(count == 20, "Cada matéria deve ter vinte perguntas")
		check(topics.size() >= 4, "Cada matéria deve cobrir ao menos quatro temas")
		check(difficulties.basic == 8 and difficulties.intermediate == 8 and difficulties.challenge == 4, "Distribuição D1 deve ser 8 básicas, 8 intermediárias e 4 desafios por matéria")
	for invalid in [null, "", "easy", "Basic", 1, true, [], {}]:
		var invalid_difficulty := original.duplicate(true)
		invalid_difficulty.questions[0].difficulty = invalid
		check(not CATALOG.validate_data(invalid_difficulty).is_empty(), "Dificuldade inválida deve ser rejeitada")
	var missing_difficulty := original.duplicate(true)
	missing_difficulty.questions[0].erase("difficulty")
	check(not CATALOG.validate_data(missing_difficulty).is_empty(), "Dificuldade ausente deve ser rejeitada")
	for difficulty in CATALOG.DIFFICULTIES:
		var valid_difficulty := original.duplicate(true)
		valid_difficulty.questions[0].difficulty = difficulty
		check(CATALOG.validate_data(valid_difficulty).is_empty(), "Dificuldade suportada deve ser aceita")
	var broken := original.duplicate(true)
	broken.questions[0].correct = 4
	check(not CATALOG.validate_data(broken).is_empty(), "Índice fora das alternativas deve ser rejeitado")
	broken = original.duplicate(true)
	broken.questions[0].correct = 0.5
	check(not CATALOG.validate_data(broken).is_empty(), "Índice fracionário deve ser rejeitado")
	broken = original.duplicate(true)
	broken.questions[0].options[1] = broken.questions[0].options[0]
	check(not CATALOG.validate_data(broken).is_empty(), "Alternativa duplicada deve ser rejeitada")
	broken = original.duplicate(true)
	broken.questions[1].id = broken.questions[0].id
	check(not CATALOG.validate_data(broken).is_empty(), "ID duplicado deve ser rejeitado")
	broken = original.duplicate(true)
	broken.questions[0].subject = "unknown"
	check(not CATALOG.validate_data(broken).is_empty(), "Matéria desconhecida deve ser rejeitada")
	broken = original.duplicate(true)
	broken.subjects[3].reward.cap = -1
	check(not CATALOG.validate_data(broken).is_empty(), "Limite negativo deve ser rejeitado")
	broken = original.duplicate(true)
	broken.subjects[0].reward.type = "unknown"
	check(not CATALOG.validate_data(broken).is_empty(), "Tipo de recompensa inválido deve ser rejeitado")
	broken = original.duplicate(true)
	broken.subjects[2].reward.heal = "10"
	check(not CATALOG.validate_data(broken).is_empty(), "Cura deve ser numérica")
	check(not CATALOG.validate_data([]).is_empty(), "Raiz incorreta deve ser rejeitada")
	print("CATALOG TESTS: %d failure(s)" % failures)
	quit(1 if failures else 0)

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
