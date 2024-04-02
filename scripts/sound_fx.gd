extends Node

enum SoundName {
	Click,
	Fall,
	Jump
}

var sounds = {
	SoundName.Click : load("res://assets/sound/Click.wav"),
	SoundName.Fall: load("res://assets/sound/Fall.wav"),
	SoundName.Jump : load("res://assets/sound/Jump.wav")
}

@onready var sound_players = get_children()

func play(sound_name : SoundName):
	var sound_to_play = sounds[sound_name]
	for sound_player in sound_players:
		if !sound_player.playing:
			sound_player.stream = sound_to_play
			sound_player.play()
			return
