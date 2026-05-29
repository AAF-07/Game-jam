extends CharacterBody2D

@export var SPEED = 150
var player_chase = false
var player = null

func _physics_process(delta: float) -> void:
	if player_chase:
		position += (player.position - position)/SPEED
		
		#buat nanti kalo ada animasi enemy
		#if (position.player - position) < 0:
			#flip_h = true
		#else:
			#flip_h = false
	else:
		pass #idle

func _on_area_2d_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	player = null
	player_chase = false
	
func _on_hitbox_2_body_entered(body: Node2D) -> void:
	if player_chase:
		print("skill check")
		
		var world = get_tree().current_scene
		if world.has_method("start_skill_check"):
			world.start_skill_check()
