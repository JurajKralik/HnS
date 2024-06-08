extends Node

@onready var state: PlayerState = get_node("/root/PlayerState");

# Called when the node enters the scene tree for the first time.
func _ready():
	$Dark.visible = true;
	$Blood.visible = false;
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if state.dead:
		$Blood.visible = true;
		$Dark.visible = false;
	else:
		$Dark.visible = true;
		$Blood.visible = false;
