extends Label

@onready var state: PlayerState = get_node("/root/PlayerState");

func _process(delta):
	text = "Kills: " + str(state.kills);
