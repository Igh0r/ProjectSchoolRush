extends SceneTree

const CATALOG = preload("res://scripts/systems/curriculum_catalog.gd")
var failures: int = 0

func _initialize() -> void:
	var catalog = CATALOG.new()
	check(catalog.errors.is_empty(), "Catálogo de produção inválido")
	var original: Dictionary = catalog.data
	for subject in original.subjects:
		var count := 0
		for question in original.questions:
			if question.subject == subject.id:
				count += 1
		check(count == 5, "Cada matéria deve ter cinco perguntas")
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
