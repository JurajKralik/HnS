extends Label

@onready var state: PlayerState = get_node("/root/PlayerState");

func _process(delta):	
	var bullets = state.bullets;
	if state.reloading:
		text = "Reloading";
	else:
		text = "Bullets: " + str(state.bullets);
