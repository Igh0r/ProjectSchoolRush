extends RefCounted

var music_percent: float = 100.0
var effects_percent: float = 100.0
var effects_muted: bool = false

func reset() -> void:
	music_percent = 100.0
	effects_percent = 100.0
	effects_muted = false

func load_from(path: String) -> Error:
	reset()
	var config := ConfigFile.new()
	var error := config.load(path)
	if error != OK:
		return error
	music_percent = _valid_percent(config.get_value("audio", "music", 100.0))
	effects_percent = _valid_percent(config.get_value("audio", "effects", 100.0))
	var muted: Variant = config.get_value("audio", "effects_muted", false)
	effects_muted = muted if muted is bool else false
	return OK

func save_to(path: String) -> Error:
	var config := ConfigFile.new()
	config.set_value("audio", "music", music_percent)
	config.set_value("audio", "effects", effects_percent)
	config.set_value("audio", "effects_muted", effects_muted)
	return config.save(path)

func _valid_percent(value: Variant) -> float:
	if not (value is float or value is int) or not is_finite(float(value)):
		return 100.0
	return clampf(float(value), 0.0, 100.0)
