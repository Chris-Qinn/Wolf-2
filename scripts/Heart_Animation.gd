extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var life

# Called when the node enters the scene tree for the first time.
func _ready():
	life = 2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	life -= delta;
	position.y -= 10*delta
	if life <= 0:
		self.queue_free()
