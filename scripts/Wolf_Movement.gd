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
var hasdash;
var wolf;

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity.x = 0;
	velocity.y = 0;
	acceleration.x = 0;
	acceleration.y = 2;
	jump_buffer = 0;
	hasdash = true;




# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	passsdlf
func get_dash_direction():
	var dash_d = Vector2()
	dash_d.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	dash_d.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	if dash_d.x == 0 and dash_d.y == 0:
		pass

func get_input():

	var LRJoy = Input.get_action_strength("right") - Input.get_action_strength("left")
	acceleration.x = LRJoy
	var LRKey = 0
	if Input.is_action_pressed("key_right"):
		LRKey += 1

	if Input.is_action_pressed("key_left"):
		LRKey -= 1
	if LRJoy == 0:
		acceleration.x = LRKey

	if hasdash and Input.is_action_just_pressed("dash"):
		var dash_d = get_dash_direction()
		
	
	if is_on_surface and Input.is_action_just_pressed("jump") and (surface_normal.y < -0.5 or velocity.y == 0):
		jumping = true
		jump_buffer = 0.15;
		velocity.y = -5;
	elif Input.is_action_pressed("jump") and jump_buffer > 0:
		jumping = true
	else:
		jumping = false
		jump_buffer = 0


func _physics_process(delta):
	# print(delta)
	get_input()
	
	if jumping:
		pass
	else:
		velocity.y += acceleration.y*30*delta
	
	if jump_buffer > 0:
		jump_buffer -= delta;
		# print(jump_buffer)
	
	velocity.y = min(velocity.y, 5)
	
	
	var v_x_limit = max(1.5*Input.get_action_strength("left"), 1.5*Input.get_action_strength("right"))
	if Input.is_action_pressed("key_left") or Input.is_action_pressed("key_right"):
		v_x_limit = 1.5;
	
	if acceleration.x == 0 or abs(velocity.x) > v_x_limit:
		acceleration.x = -0.5*velocity.x
		velocity.x += acceleration.x*30*delta
	else:
		velocity.x += acceleration.x*30*delta
		velocity.x = min( max( -v_x_limit, velocity.x ), v_x_limit )
		print(velocity.x)

	
	if is_on_surface == false:
		velocity.x *= 1.8
	else:
		velocity.x *= 1.2
	
	var motion = velocity*delta*movespeed
	
	if is_on_surface == false:
		velocity.x /= 1.8
	else:
		velocity.x /= 1.2

	var collision = move_and_collide(motion)
	if collision:
		#velocity -= velocity * velocity.dot(collision.normal);
		if collision.normal.y < -0.5:
			velocity.y = 0;
		var slide = collision.remainder.slide(collision.normal);
		velocity = velocity.slide(collision.normal)
		move_and_collide(slide)
		is_on_surface = true;
		surface_normal = collision.normal
		if collision.normal.y > 0.5:
			jump_buffer = 0;
	else:
		is_on_surface = false;
	
	if velocity.x > 0:
		$"WolfSprite".flip_h = false;
	elif velocity.x < 0:
		$"WolfSprite".flip_h = true;
	
