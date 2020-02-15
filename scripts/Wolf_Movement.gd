extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var walkspeed = 150.0
var jumpvelocity = 150.0
var gravityscale = 200.0
var velocity = Vector2()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	passsdlf

func get_input():

	var LRJoy = Input.get_action_strength("right") - Input.get_action_strength("left")
	velocity.x = LRJoy*walkspeed

	
			
func _physics_process(delta):
	
	get_input()
	var motion = velocity*delta
	velocity.y += delta*gravityscale
	var collision = move_and_collide(motion)
	if collision:
		velocity = velocity.slide(collision.normal)
		
	
