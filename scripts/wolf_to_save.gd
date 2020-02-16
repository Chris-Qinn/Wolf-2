extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var colour = "white"
var heart = preload("res://Heart.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.animation = colour


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_body_entered(body):
	if body.name == "WolfBody":
		body.has_colours.append(colour)
		self.queue_free()
		var h = heart.instance()
		h.position = get_position() + get_parent().get_position()
		get_node("/root").add_child(h)
