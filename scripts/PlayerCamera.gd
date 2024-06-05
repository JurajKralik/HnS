extends Camera2D

@export var player: CharacterBody2D;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var result = lerp(position, player.position, 0.01);
	position = result;
