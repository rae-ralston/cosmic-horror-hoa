extends Control

@onready var music_slider: HSlider = $CenterContainer/Panel/MarginContainer/VBoxContainer/MusicRow/MusicSlider
@onready var sfx_slider: HSlider = $CenterContainer/Panel/MarginContainer/VBoxContainer/SFXRow/SFXSlider
@onready var resume_button: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/ResumeButton

var music_bus_idx: int
var sfx_bus_idx: int


func _ready() -> void:
	music_bus_idx = AudioServer.get_bus_index("Music")
	sfx_bus_idx = AudioServer.get_bus_index("SFX")

	music_slider.value_changed.connect(_on_music_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	resume_button.pressed.connect(_on_resume_pressed)

	hide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("settings_toggle") and visible:
		close()
		get_viewport().set_input_as_handled()


func open() -> void:
	show()
	get_tree().paused = true


func close() -> void:
	hide()
	get_tree().paused = false


func _on_music_slider_changed(value: float) -> void:
	var db := linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(music_bus_idx, db)


func _on_sfx_slider_changed(value: float) -> void:
	var db := linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(sfx_bus_idx, db)


func _on_resume_pressed() -> void:
	close()
