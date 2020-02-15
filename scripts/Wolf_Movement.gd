extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var movespeed = 280
var jumpvelocity = 10.0
var gravityscale = 500.0
var velocity = Vector2()
var acceleration = Vector2()
var is_on_surface;
var surface_normal;
var jump_buffer;
var jumping;

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity.x = 0;
	velocity.y = 0;
	acceleration.x = 0;
	acceleration.y = 2;
	jump_buffer = 0;




# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	passsdlf

func get_input():

	var LRJoy = Input.get_action_strength("right") - Input.get_action_strength("left")
	acceleration.x = LRJoy
	
	if is_on_surface and Input.is_action_just_pressed("jump") and (surface_normal.y < -0.5 or velocity.y == 0):
		jumping = true
		jump_buffer = 0.15;
	elif Input.is_action_pressed("jump") and jump_buffer > 0:
		jumping = true
	else:
		jumping = false
		jump_buffer = 0


func _physics_process(delta):
	# print(delta)
	get_input()
	
	if jumping:
		velocity.y = -5
	else:
		velocity.y += acceleration.y*30*delta
	
	if jump_buffer > 0:
		jump_buffer -= delta;
		print(jump_buffer)
	
	velocity.y = min(velocity.y, 6.6)
	if acceleration.x == 0:
		acceleration.x = -velocity.x
	velocity.x += acceleration.x*30*delta
	
	velocity.x = min( max(-1.5*Input.get_action_strength("left"), velocity.x), 1.5*Input.get_action_strength("right") )
	
	if is_on_surface == false:
		velocity.x *= 1.8	
	else:
		velocity.x *= 1.2
	if velocity.x > 0:
		$"WolfSprite".flip_h = false;
	elif velocity.x < 0:
		$"WolfSprite".flip_h = true;
	
	var motion = velocity*delta*movespeed

	var collision = move_and_collide(motion)
	if collision:
		#velocity -= velocity * velocity.dot(collision.normal);
		var slide = collision.remainder.slide(collision.normal);
		velocity = velocity.slide(collision.normal)
		move_and_collide(slide)
		is_on_surface = true;
		surface_normal = collision.normal
		jump_buffer = 0;
	else:
		is_on_surface = false;
	
	if velocity.x > 0:
		$"WolfSprite".flip_h = false;
	elif velocity.x < 0:
		$"WolfSprite".flip_h = true;
	
