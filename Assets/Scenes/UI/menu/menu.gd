extends Node2D

@onready var bg_music = $BackgroundMusic
var enable_music: bool = false

func _ready():
	$UILayer/DisableMusicBox.set_pressed_no_signal(false)
	bg_music.set_stream_paused(false)
	bg_music.set_volume_db(-5)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://Assets/Scenes/game_world.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _process(delta):
	if !enable_music:
		bg_music.set_stream_paused(false)
	else:
		bg_music.set_stream_paused(true)

func _on_disable_music_box_pressed():
	enable_music = !enable_music
