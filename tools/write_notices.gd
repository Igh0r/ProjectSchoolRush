extends SceneTree

func _initialize() -> void:
	var file := FileAccess.open("res://builds/windows/GODOT_NOTICES.txt", FileAccess.WRITE)
	if file == null:
		push_error("Não foi possível escrever os avisos do Godot")
		quit(1)
		return
	file.store_string(Engine.get_license_text())
	file.store_string("\n\nThird-party components\n" + JSON.stringify(Engine.get_copyright_info(), "  "))
	var licenses := Engine.get_license_info()
	for license_name in licenses:
		file.store_string("\n\n" + license_name + "\n" + licenses[license_name])
	file.close()
	quit()
