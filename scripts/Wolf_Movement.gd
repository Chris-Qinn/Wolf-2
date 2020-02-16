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

var heart = preload("res://Heart.tscn");

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
	var mycol = Color();
	if colour == "white":
		wolf = "white"
		$WolfSprite.animation = "white"
		mycol.r = 1.0
		mycol.g = 1.0
		mycol.b = 1.0
	elif colour == "green" and "green" in has_colours:
		wolf = "green"
		mycol.r = 0.2
		mycol.g = 1
		mycol.b = 0.2
		$WolfSprite.animation = "green"
	elif colour == "yellow" and "yellow" in has_colours:
		wolf = "yellow"
		mycol.r = 1
		mycol.g = 1
		mycol.b = 0.2
		$WolfSprite.animation = "yellow"
	elif colour == "pink" and "pink" in has_colours:
		wolf = "pink"
		mycol.r = 1
		mycol.g = 0.5
		mycol.b = 0.5
		$WolfSprite.animation = "pink_wall_hold"
	$CPUParticles2D.color = mycol;
	$WolfSprite/Light2D.color = mycol;


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
			
			var h = heart.instance()
			h.position = get_position() + get_parent().get_position()
			get_node("/root").add_child(h)
			
			velocity = velocity.normalized()*5;
			if velocity.x == 0 and get_dash_direction().x != 0:
				dash_buffer = 0.04
				velocity = 5*get_dash_direction();
			elif Input.is_action_pressed("dash"):
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
		dash_buffer = 0.15
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

	if hasdash and Input.is_action_just_pressed("dash") and "yellow" in has_colours and state != "dashprepping":
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


func _physics_process(delta):

	if position.x < -2000 or position.x > 2000 or position.y > 2000 or position.y < -2000:
		get_tree().reload_current_scene()


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
	
	
	
	
	

	var collision = move_and_collide(motion)
	if collision:
#		is_on_surface = true;
		surface_normal = collision.normal
		print("Collision");
		
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
		if wolf == "pink":
			$WolfSprite.animation = "pink"

#	else:
#		is_on_surface = false;
	
	if velocity.x > 0 or state == "leftwalling":
		$"WolfSprite".flip_h = false;
	elif velocity.x < 0 or state == "rightwalling":
		$"WolfSprite".flip_h = true;
	
	if state == "leftwalling" or state == "rightwalling":
		velocity.y = -1;
	
#	get_parent().get_node("CPUParticles2D").direction = -velocity.normalized()
	$"CPUParticles2D".direction = -velocity.normalized()
	
	var mini_cols = has_colours.duplicate()
	mini_cols.erase(wolf)
	for i in range(3):
		var m_w
		if i==0: m_w = $WolfSprite/M1
		elif i==1: m_w = $WolfSprite/M2
		else: m_w = $WolfSprite/M3

		if len(mini_cols) > i:
			
			m_w.show();
			m_w.set_goal_pos((-300-300*i)*velocity.normalized())
			m_w.change_wolf(mini_cols[i])
		else:
			m_w.hide();
	
	













