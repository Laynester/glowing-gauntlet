extends Control

@onready var anim = $AnimationPlayer

func _ready():
	anim.play("fade_out")
	
func _on_animation_player_animation_finished(anim_name:StringName):
	anim.play("fade_out")
