extends AudioStreamPlayer

@onready var track_1: AudioStreamWAV = preload("res://Assets/Music/Track 1.wav")
@onready var track_2: AudioStreamWAV = preload("res://Assets/Music/Track 2.wav")
@onready var track_3: AudioStreamWAV = preload("res://Assets/Music/Track 3.wav")
@onready var track_4: AudioStreamWAV = preload("res://Assets/Music/Track 4.wav")

var music_list: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	music_list.append(track_1)
	music_list.append(track_2)
	music_list.append(track_3)
	music_list.append(track_4)
	select_song_and_play()
	
func select_song_and_play():
	var index = randi_range(0, music_list.size() - 1)
	var song: AudioStreamWAV = music_list[index]
	set_stream(song)
	play(0.0)

func _on_finished():
	select_song_and_play()
