extends RefCounted

var elapsed_seconds: float = 0.0
var combat_seconds: float = 0.0
var answers: Array[Dictionary] = []
var cleared_rooms: Array[int] = []
var route: String = ""
var result: Dictionary = {}
var saved_path: String = ""

func reset(route_name: String) -> void:
	elapsed_seconds = 0.0
	combat_seconds = 0.0
	answers.clear()
	cleared_rooms.clear()
	route = route_name
	result.clear()
	saved_path = ""

func advance_time(delta: float, in_combat: bool) -> void:
	if not result.is_empty() or delta <= 0.0:
		return
	elapsed_seconds += delta
	if in_combat:
		combat_seconds += delta

func record_answer(question: Dictionary, option: int, room_number: int, subject_name: String) -> void:
	if not result.is_empty() or option < 0 or option >= question.options.size():
		return
	for answer in answers:
		if answer.room == room_number:
			return
	var correct: bool = option == int(question.correct)
	answers.append({
		"room": room_number, "id": question.id, "subject": question.subject,
		"subject_name": subject_name, "topic": question.topic, "difficulty": question.difficulty,
		"prompt": question.prompt, "selected_answer": question.options[option],
		"correct_answer": question.options[int(question.correct)], "correct": correct,
		"explanation": question.explanation, "reward_status": "reserved" if correct else "none",
	})

func clear_room(room_number: int, reward_changed: bool) -> void:
	if not result.is_empty() or room_number in cleared_rooms:
		return
	cleared_rooms.append(room_number)
	for answer in answers:
		if answer.room == room_number and answer.reward_status == "reserved":
			answer.reward_status = "received" if reward_changed else "no_effect"

func finish(outcome: String, room_number: int, attributes: Dictionary) -> void:
	if not result.is_empty():
		return
	var correct_count: int = 0
	var by_difficulty := {
		"basic": {"answered": 0, "correct": 0},
		"intermediate": {"answered": 0, "correct": 0},
		"challenge": {"answered": 0, "correct": 0},
	}
	for answer in answers:
		by_difficulty[answer.difficulty].answered += 1
		if answer.correct:
			correct_count += 1
			by_difficulty[answer.difficulty].correct += 1
		if answer.reward_status == "reserved":
			answer.reward_status = "cancelled"
	result = {
		"schema_version": 1, "game_version": ProjectSettings.get_setting("application/config/version", ""),
		"finished_at_utc": Time.get_datetime_string_from_system(true), "route": route,
		"outcome": outcome, "room_reached": room_number, "rooms_cleared": cleared_rooms.size(),
		"elapsed_seconds": snappedf(elapsed_seconds, 0.01), "combat_seconds": snappedf(combat_seconds, 0.01),
		"correct_answers": correct_count, "answered_questions": answers.size(),
		"difficulty_breakdown": by_difficulty,
		"answers": answers.duplicate(true), "final_attributes": attributes.duplicate(true),
	}

func snapshot() -> Dictionary:
	return result.duplicate(true)

func save_json(directory: String = "user://reports") -> Dictionary:
	if result.is_empty():
		return {"error": ERR_UNAVAILABLE, "path": ""}
	if not saved_path.is_empty() and FileAccess.file_exists(saved_path):
		return {"error": OK, "path": saved_path}
	if FileAccess.file_exists(directory):
		return {"error": ERR_ALREADY_EXISTS, "path": ""}
	var error := DirAccess.make_dir_recursive_absolute(directory)
	if error != OK:
		return {"error": error, "path": ""}
	var stem := "school-rush-%s" % result.finished_at_utc.replace(":", "-")
	var path := directory.path_join(stem + ".json")
	var suffix: int = 1
	while FileAccess.file_exists(path):
		path = directory.path_join("%s-%d.json" % [stem, suffix])
		suffix += 1
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return {"error": FileAccess.get_open_error(), "path": ""}
	file.store_string(JSON.stringify(result, "\t") + "\n")
	file.flush()
	error = file.get_error()
	file.close()
	if error != OK:
		DirAccess.remove_absolute(path)
		return {"error": error, "path": ""}
	saved_path = path
	return {"error": OK, "path": saved_path}

static func format_duration(seconds: float) -> String:
	var total := int(seconds)
	return "%02d:%02d" % [total / 60, total % 60]

static func reward_text(status: String) -> String:
	return {
		"none": "Sem bônus: resposta incorreta.",
		"reserved": "Bônus reservado até vencer a sala.",
		"received": "Bônus recebido após vencer a sala.",
		"no_effect": "Bônus sem efeito: atributo já no limite.",
		"cancelled": "Bônus cancelado: a sala não foi concluída.",
	}.get(status, "")
