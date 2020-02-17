extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var nextLevel = String()
var nextL

# Called when the node enters the scene tree for the first time.
func _ready():
	nextL = load("res://"+nextLevel);


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Progress_body_entered(body):
	if body.name == "WolfBody":
		get_tree().change_scene_to(nextL);
