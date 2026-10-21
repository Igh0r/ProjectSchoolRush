extends RefCounted

const PATH := "res://data/curriculum.json"
var data: Dictionary = {}
var errors := PackedStringArray()

func _init() -> void:
	var file := FileAccess.open(PATH, FileAccess.READ)
	if file == null:
		errors.append("Banco de questões não encontrado: " + PATH)
		return
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		errors.append("JSON inválido na linha %d: %s" % [json.get_error_line(), json.get_error_message()])
		return
	errors = validate_data(json.data)
	if errors.is_empty():
		data = json.data

static func is_number(value: Variant) -> bool:
	return value is int or value is float

static func is_text(value: Variant) -> bool:
	return value is String and not value.strip_edges().is_empty()

static func validate_data(value: Variant) -> PackedStringArray:
	var issues := PackedStringArray()
	if not value is Dictionary:
		return PackedStringArray(["O catálogo deve ser um objeto JSON."])
	if not is_text(value.get("audience")):
		issues.append("Público ausente.")
	if not value.get("subjects") is Array or not value.get("questions") is Array:
		return PackedStringArray(["Disciplinas e questões devem ser listas."])
	var subjects: Dictionary = {}
	for subject in value.subjects:
		if not subject is Dictionary or not is_text(subject.get("id")) or not is_text(subject.get("name")):
			issues.append("Disciplina sem ID ou nome válido.")
			continue
		if subjects.has(subject.id):
			issues.append("Disciplina duplicada: " + subject.id)
		subjects[subject.id] = 0
		var reward: Variant = subject.get("reward")
		if not reward is Dictionary or not reward.get("type", "") in ["damage", "heal", "max_health", "speed"]:
			issues.append("Recompensa inválida: " + subject.id)
			continue
		if not is_number(reward.get("amount")) or reward.amount <= 0:
			issues.append("Valor de recompensa inválido: " + subject.id)
			continue
		if reward.type != "speed" and reward.amount != int(reward.amount):
			issues.append("Vida e dano exigem valores inteiros: " + subject.id)
		if reward.type == "speed":
			if not is_number(reward.get("cap")) or reward.cap < reward.amount or reward.cap > 100:
				issues.append("Limite de velocidade inválido: " + subject.id)
		if reward.type == "max_health":
			if not is_number(reward.get("heal")) or reward.heal < 0 or reward.heal != int(reward.heal):
				issues.append("Cura adicional inválida: " + subject.id)
	if subjects.size() < 2:
		issues.append("São necessárias pelo menos duas disciplinas.")
	var ids: Dictionary = {}
	for question in value.questions:
		if not question is Dictionary:
			issues.append("Questão deve ser um objeto.")
			continue
		var valid_text := true
		for field in ["id", "subject", "topic", "prompt", "explanation"]:
			if not is_text(question.get(field)):
				valid_text = false
		if not valid_text:
			issues.append("Questão com campos de texto ausentes.")
			continue
		if ids.has(question.id):
			issues.append("Questão duplicada: " + question.id)
		ids[question.id] = true
		if not subjects.has(question.subject):
			issues.append("Disciplina desconhecida: " + question.id)
		else:
			subjects[question.subject] += 1
		var options: Variant = question.get("options")
		if not options is Array or options.size() != 4:
			issues.append("São necessárias quatro alternativas: " + question.id)
		else:
			var unique: Dictionary = {}
			for option in options:
				if not is_text(option):
					issues.append("Alternativa vazia: " + question.id)
				elif unique.has(option.strip_edges().to_lower()):
					issues.append("Alternativa repetida: " + question.id)
				else:
					unique[option.strip_edges().to_lower()] = true
		var correct: Variant = question.get("correct")
		if not is_number(correct) or correct != int(correct) or correct < 0 or correct > 3:
			issues.append("Índice da resposta inválido: " + question.id)
	for subject_id in subjects:
		if subjects[subject_id] < 2:
			issues.append("Disciplina precisa de pelo menos duas questões: " + subject_id)
	return issues
