extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var velocity = Vector2(0, 0)
var pos_goal = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	velocity = pos_goal - position;
	if pos_goal.distance_squared_to(position) < 8000:
		position = pos_goal;
	else:
	
		position += velocity.normalized()*8000*delta;
	
	if position.x < 0:
		$"WolfSprite".flip_h = false;
	else:
		$"WolfSprite".flip_h = true;


func set_goal_pos( pos ):
	pos_goal = pos
	print(pos_goal)
	

func hide():
	$WolfSprite.visible = false

func show():
	$WolfSprite.visible = true


# Put wolf changing animations in here :D
func change_wolf(colour):
	var mycol = Color();
	if colour == "white":

		$WolfSprite.animation = "white"
		mycol.r = 1.0
		mycol.g = 1.0
		mycol.b = 1.0
	elif colour == "green" :

		mycol.r = 0.2
		mycol.g = 1
		mycol.b = 0.2
		$WolfSprite.animation = "green"
	elif colour == "yellow" :

		mycol.r = 1
		mycol.g = 1
		mycol.b = 0.2
		$WolfSprite.animation = "yellow"
	elif colour == "pink" :

		mycol.r = 1
		mycol.g = 0.5
		mycol.b = 0.5
		$WolfSprite.animation = "pink_wall_hold"
	$CPUParticles2D.color = mycol;
	$WolfSprite/Light2D.color = mycol;
