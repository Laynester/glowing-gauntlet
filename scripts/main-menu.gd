extends Control

@onready var music: AudioStreamPlayer2D = $Music
@onready var bg  = $UI/Background
@onready var totalRubies = $UI/Rubys/Total
var tween: Tween
var audio: AudioStream
var loop: bool

var curGame: Node2D

func _ready():
	Main.game().moveAudio(Vector2(0,0))
	Main.game().tryPlaySound("res://assets/audio/main-loop.mp3")

	Main.Storage.loadData()

	totalRubies.text = str(Main.Storage.totalRubies)
	
func _onPlay():
	Main.goto_scene("res://game/MazeRunner.tscn")

func _on_scores_pressed():
	var source = ResourceLoader.load("res://start/scores.tscn")
	var scene = source.instantiate()

	add_child(scene)
