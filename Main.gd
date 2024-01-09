extends Node2D

@onready var anim = $AnimationPlayer
@onready var music: AudioStreamPlayer2D = $Music

var current_scene
var queued_scene

func _ready():
	goto_scene("res://start/main-menu.tscn")

func goto_scene(path):
	print(path)
	var s = ResourceLoader.load(path)
		
	queued_scene = s.instantiate()
	queued_scene.z_index = -1000

	if current_scene: anim.play("fade_in")
	else: setNewScene()


func _on_animation_player_animation_finished(anim_name:StringName):
	match anim_name:
		"fade_in":
			setNewScene()

func setNewScene():
	add_child(queued_scene)
	if current_scene: current_scene.queue_free()
	current_scene = queued_scene
	current_scene.z_index = 0
	queued_scene = null
	anim.play("fade_out")

#sound stuff
var audio: AudioStream
var loop: bool
var tween

func startPlaying():
	music.stream = audio
	music.stream.loop = loop
	music.volume_db = -100.0
	music.play()
	tween = get_tree().create_tween()
	tween.tween_property(music, "volume_db", 0.0, 0.6).set_trans(Tween.TRANS_LINEAR)

func tryPlaySound(url: String, localLoop: bool = true):
	audio = load(url)
	self.loop = localLoop
	
	if audio:
		if !localLoop:
			music.stream = audio
			music.play()
		elif music.playing:
			tween = get_tree().create_tween()
			tween.tween_property(music, "volume_db", -100.0, 0.6).set_trans(Tween.TRANS_LINEAR)
			tween.tween_callback(startPlaying)
			startPlaying()
		else:
			startPlaying()

func moveAudio(pos: Vector2):
	music.position = pos
