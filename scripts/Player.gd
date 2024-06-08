extends CharacterBody2D

@export var bullet: PackedScene;

@onready var state: PlayerState = get_node("/root/PlayerState");

var speed = 125;
var shot_cooldown = Time.get_ticks_msec();
var muzzle_cooldown = Time.get_ticks_msec();
var damage_cooldown = Time.get_ticks_msec();
var player_damage_flash = false;
var player_arm_jitter = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN);
	var res = DisplayServer.window_get_size();
	position.x = res.x / 2;
	position.y = res.y / 2;
	
func toggleMuzzleFlash(value: bool):
	if (value):
		$PlayerArms/Flashlight.texture_scale = 2.5;
		$PlayerArms/Flashlight.energy = 0.9;
		muzzle_cooldown = Time.get_ticks_msec() + 10;
		
	if (!value):
		$PlayerArms/Flashlight.texture_scale = 1.95;
		$PlayerArms/Flashlight.energy = 0.5;

	$MuzzleController/MuzzleFlash.visible = value;
	$MuzzleController/MuzzleOverlay.enabled = value;
	
func isMuzzleEnabled():
	return $MuzzleController/MuzzleFlash.visible

func leftClick(mouseCursor):
	if (!Input.is_action_pressed("click")):
		return;
		
	if (Time.get_ticks_msec() < shot_cooldown):
		return;
	
	if state.bullets == 1:
		shot_cooldown = Time.get_ticks_msec() + 1000;
		$Reload.play();
		state.reloading = true;
	else:
		shot_cooldown = Time.get_ticks_msec() + 175;
	
	# Bullet Spawner
	var bullet_instance: CharacterBody2D = bullet.instantiate();
	bullet_instance.setup($Marker2D.global_position, get_global_mouse_position());
	state.bullets -= 1;
	get_tree().get_root().add_child(bullet_instance);
	
	# Sounds
	$Gunshot.play();
	
	# Muzzle Flash
	toggleMuzzleFlash(true);
	
	# Arm Jitter
	player_arm_jitter = true;
	$PlayerArms.offset.y = 5;
	$PlayerArms/Flashlight.offset.y = 5;

func _process(delta):
	if state.dead:
		dead();
		return;
		
	var current_time = Time.get_ticks_msec();
	var mouseCursor = get_global_mouse_position()
	leftClick(mouseCursor);
	look_at(mouseCursor);
	
	velocity = Vector2();
	
	if (Input.is_action_pressed("move_up")):
		velocity.y -= 1;
		
	if (Input.is_action_pressed("move_down")):
		velocity.y += 1;
		
	if (Input.is_action_pressed("move_left")):
		velocity.x -= 1;
		
	if (Input.is_action_pressed("move_right")):
		velocity.x += 1;
		
	if (Input.is_key_pressed(KEY_R)) && !state.reloading :
		$Reload.play();
		shot_cooldown = Time.get_ticks_msec() + 600;
		state.bullets = 12;
		state.reloading = true;
		
	if (current_time > muzzle_cooldown && isMuzzleEnabled()):
		toggleMuzzleFlash(false);
		
	if (current_time > damage_cooldown - 900 && player_damage_flash):
		player_damage_flash = false;
		$PlayerHead.modulate = Color(1,1,1);
		$PlayerArms.modulate = Color(1,1,1);
		
	state.pos = position;

func damage():
	if (Time.get_ticks_msec() < damage_cooldown):
		return;
		
	damage_cooldown = Time.get_ticks_msec() + 1000;
	player_damage_flash = true;
	$PlayerHead.modulate = Color(1,0,0);
	$PlayerArms.modulate = Color(1,0,0);
	
	if (state.health <= 0):
		state.dead = true;
	else:
		state.health -= 25;
		$Damage.play();
		if (state.health <= 0):
			state.dead = true;
	
func reload():
	if state.reloading && (Time.get_ticks_msec() > shot_cooldown):
		state.reloading = false;
		state.bullets = 12;
func dead():
	if Input.is_action_pressed("click"):
		get_tree().reload_current_scene()
		state.dead = false;
		state.health = 100;
		state.kills = 0;
		state.bullets = 12;
		state.reloading = false;
			
func _draw():
	draw_line($Marker2D.position, get_local_mouse_position(), Color(1, 1, 1, 0.1));

func _physics_process(delta):
	if($PlayerArms.offset.y != 0):
		$PlayerArms.offset.y = lerpf($PlayerArms.offset.y, 0, 0.4);
		$PlayerArms/Flashlight.offset.y = lerpf($PlayerArms/Flashlight.offset.y , 0, 0.4);

	velocity = velocity.normalized();
	velocity = velocity * speed;
	move_and_slide()
	queue_redraw();
	reload()
