extends KinematicBody2D

var movespeed = 280
var jumpvelocity = 5.0
var gravity = 2.0

var velocity = Vector2()
var acceleration = Vector2()
var is_on_surface = false;
var surface_normal = Vector2();
var jump_buffer = 0;
#var jumping;
var hasdash = false;

var state = "falling"
var dash_buffer = 0
var wolf = "white"
var is_bouncy = false

var has_colours = ["white"]

#var on_ground
#var on_wall
#var on_ceil

var LRJoy = 0
var UDJoy = 0
var LRKey = 0
var UDKey = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity.x = 0;
	velocity.y = 0;
	acceleration.x = 0;
	acceleration.y = 2;
	jump_buffer = 0;
	hasdash = true;
#	on_ceil = false
#	on_ground = false
#	on_wall = false


# Put wolf changing animations in here :D
func change_wolf(colour):
	if colour == "white":
		wolf = "white"
		$WolfSprite.animation = "white"
	elif colour == "green" and "green" in has_colours:
		wolf = "green"
		$WolfSprite.animation = "green"
	elif colour == "yellow" and "yellow" in has_colours:
		wolf = "yellow"
		$WolfSprite.animation = "yellow"
	elif colour == "pink" and "pink" in has_colours:
		wolf = "pink"
		$WolfSprite.animation = "pink_wall_hold"


# Update controls somewhat
func controls():
	# Set control variables
	LRJoy = Input.get_action_strength("right") - Input.get_action_strength("left")
	UDJoy = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	LRKey = 0
	if Input.is_action_pressed("key_right"):
		LRKey += 1
	if Input.is_action_pressed("key_left"):
		LRKey -= 1
	
	UDKey = 0
	if Input.is_action_pressed("key_up"):
		UDKey -= 1
	if Input.is_action_pressed("key_down"):
		UDKey += 1
	
	if Input.is_action_pressed("bounce"):
		is_bouncy = true
	else:
		is_bouncy = false


# This gets the direction to dash in. Important because of multiple possible control schemes
func get_dash_direction():
	var dash_d = Vector2()
	dash_d.x = LRJoy;
	dash_d.y = 0;
	if dash_d.x == 0 and dash_d.y == 0:
		dash_d.x = LRKey;
	return dash_d.normalized()


# This executes the dash functionality, whether dash is just called or we are dashing
func do_dash( delta ):
	if state == "dashprepping":
		dash_buffer -= delta
		
		# Do the dash
		if dash_buffer <= 0.07:
			state = "dashing"
			
			var h = load("res://Heart.tscn").instance()
			h.position = get_position() + get_parent().get_position()
			get_node("/root").add_child(h)
			
			velocity = velocity.normalized()*5;
			if velocity.x == 0 and get_dash_direction().x != 0:
				dash_buffer = 0.04
				velocity = 5*get_dash_direction();
			elif get_dash_direction().x == velocity.x/5:
				dash_buffer = 0.07
			elif get_dash_direction().x == 0:
				dash_buffer = 0.07
			else:
				dash_buffer = 0.04

		return "not"

	elif state == "dashing":
		dash_buffer -= delta
		if dash_buffer <= 0:
			velocity = 1.5*velocity.normalized()
			return "done"
	else:
		state = "dashprepping"
		hasdash = false
		var dash_d = get_dash_direction()
		print(dash_d)
		dash_buffer = 0.3
		velocity = dash_d*0.001
		return "not"


# This executes a jump
func do_jump():
	state = "jumping"
	velocity.y = -jumpvelocity;
	jump_buffer = 0.15;
	

# This executes a wall jump
func do_wall_jump(x):
	state = "jumping"
	$WolfSprite.animation = "pink"
	velocity.x = x
	velocity.y = -1
	velocity = jumpvelocity*velocity.normalized()
	jump_buffer = 0.10;


# Does state control using variables
func state_machine( delta ):

	# print(state)

	if state == "bouncing":
		if not is_bouncy:
			state = "falling"
			change_wolf( "white" )
	
	if state == "dashing" or state == "dashprepping":
		if do_dash( delta ) == "done":
			state = "falling"
			print("Falling now?");

	if hasdash and Input.is_action_just_pressed("dash") and "yellow" in has_colours:
		do_dash( delta )
		change_wolf( "yellow" )
	
	if state == "falling" or state == "grounded":
		if is_bouncy and "green" in has_colours:
			state = "bouncing"
			change_wolf( "green" )
	
	if state == "grounded" and Input.is_action_just_pressed("jump"):
		do_jump()
		change_wolf( "white" )
	elif state == "jumping":
		if jump_buffer > 0 && Input.is_action_pressed("jump"):
			jump_buffer -= delta
		else:
			state = "falling"
	
	if state == "rightwalling":
		if Input.is_action_just_pressed("jump"):
			do_wall_jump(-1.0);
		elif LRJoy <= 0 and LRKey <= 0:
			state = "falling"
			$WolfSprite.animation = "pink"
	
	if state == "leftwalling":
		if Input.is_action_just_pressed("jump"):
			do_wall_jump(1.0);
		elif LRJoy >= 0 and LRKey >= 0:
			state = "falling"
			$WolfSprite.animation = "pink"
#
#
#
#	acceleration.x = LRJoy
#
#	if LRJoy == 0:
#		acceleration.x = LRKey
#
#	if hasdash and Input.is_action_just_pressed("dash"):
#		var dash_d = get_dash_direction()
#		velocity = dash_d * 5;
#		hasdash = false
#
#	if Input.is_action_pressed("bounce"):
#		wolf = "bounce";
#	else:
#		wolf = "not";
#
#	if is_on_surface and (surface_normal.y < -0.5 or velocity.y == 0):
#		hasdash = true
#		if Input.is_action_just_pressed("jump"):
#			jumping = true
#			jump_buffer = 0.15;
#			velocity.y = -jumpvelocity;
#	elif Input.is_action_pressed("jump") and jump_buffer > 0:
#		jumping = true
#	else:
#		jumping = false
#		jump_buffer = 0


func _physics_process(delta):

	if position.x < -2000 or position.x > 2000 or position.y > 2000 or position.y < -2000:
		get_tree().reload_current_scene()

	# Define some states that help us figure out what we're doing
#	on_ground = is_on_surface and (surface_normal.y < -0.5)
#	on_wall = is_on_surface and (abs(surface_normal.y) <= 0.5)
#	on_ceil = is_on_surface and not on_wall and not on_ground

	controls()

	state_machine( delta )
	
	if LRJoy == 0:
		acceleration.x = LRKey
	else:
		acceleration.x = LRJoy
	
	acceleration.y = gravity
	
	if state == "bouncing":
		# X-velocity stays the same
		velocity.x += acceleration.x * 5 * delta
		velocity.x = min( max( -1.5, velocity.x ), 1.5 )
		velocity.y += acceleration.y * 30 * delta
	elif state == "jumping":
		# Y-velocity stays the same
		velocity.x += acceleration.x * 30 * delta
		velocity.x = min( max( -1.5, velocity.x ), 1.5 )
	elif state == "dashing" or state == "dashprepping":
		# No change in velocities
		pass
	elif state == "falling" or state == "grounded":
		if state == "grounded":
			acceleration.x += -0.3 * velocity.x
		velocity.x += acceleration.x * 30 * delta
		velocity.x = min( max( -1.5, velocity.x ), 1.5 )
		velocity.y += acceleration.y * 30 * delta
	
	elif state == "leftwalling" or state == "rightwalling":
		# Only slide slightly
		velocity.y = 0.5 * 30 * delta
		velocity.x += acceleration.x * 1 * delta
		velocity.x = min( max( -1.5, velocity.x ), 1.5 )
	
	if state != "grounded":
		velocity.x *= 1.6
	
	var motion = delta * velocity * movespeed
	
	if state != "grounded":
		velocity.x /= 1.6
	
	
	
	
	
	
#	var v_x_limit = max(1.5*Input.get_action_strength("left"), 1.5*Input.get_action_strength("right"))
#	if Input.is_action_pressed("key_left") or Input.is_action_pressed("key_right"):
#		v_x_limit = 1.5;
#
#
#	# Control velocity and acceleration in the x-axis
#	if on_ground and acceleration.x == 0:
#		# On the ground and not trying to accelerate
#		acceleration.x = -0.2*velocity.x
#		velocity.x += acceleration.x * 30 * delta
#	elif abs(velocity.x) > v_x_limit and ( 
#		(velocity.x<0 and acceleration.x<0) or (velocity.x>0 and acceleration.x>0)
#		):
#		# Cannot accelerate any faster
#		pass
#	elif on_ground:
#		velocity.x += acceleration.x*30*delta
#		velocity.x = min( max( -v_x_limit, velocity.x ), v_x_limit )
#	elif wolf != "bounce":
#		velocity.x += acceleration.x*30*delta
#		velocity.x = min( max( -v_x_limit, velocity.x ), v_x_limit )


	
#	if on_ground == false:
#		velocity.x *= 1.8
#	else:
#		velocity.x *= 1.2
#
#	var motion = velocity*delta*movespeed
#
#	if on_ground == false:
#		velocity.x /= 1.8
#	else:
#		velocity.x /= 1.2

	var collision = move_and_collide(motion)
	if collision:
#		is_on_surface = true;
		surface_normal = collision.normal
		
		# Check if this is ground enough to give dash back
		if collision.normal.y < -0.5:
			hasdash = true
		
		# If we are bouncy
		# Works even in the middle of a dash
		if is_bouncy and "green" in has_colours:
			var bounce = collision.remainder.bounce(collision.normal);
			velocity = velocity.bounce(collision.normal);
			velocity *= 0.95
			if state != "bouncing":
				state = "bouncing"
				change_wolf( "green" )
			#move_and_collide(bounce)
		else:
			if collision.normal.y < -0.5:
				velocity.y = 0;
				state = "grounded"
			elif collision.normal.x == 1 and "pink" in has_colours:
				state = "leftwalling"
				change_wolf( "pink" )
			elif collision.normal.x == -1 and "pink" in has_colours:
				state = "rightwalling"
				change_wolf( "pink" )
			if (collision.normal.x != 1 and collision.normal.x != -1) or not "pink" in has_colours:
				var slide = collision.remainder.slide(collision.normal);
				velocity = velocity.slide(collision.normal)
				move_and_collide(slide)
			else:
				velocity.x = 0;
				velocity.y = 0;
	elif state == "rightwalling" or state == "leftwalling" or state == "grounded":
		state = "falling"
		$WolfSprite.animation = "pink"

#	else:
#		is_on_surface = false;
	
	if velocity.x > 0 or state == "leftwalling":
		$"WolfSprite".flip_h = false;
	elif velocity.x < 0 or state == "rightwalling":
		$"WolfSprite".flip_h = true;
	
	
