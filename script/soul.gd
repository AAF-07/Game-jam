extends Area2D

func _on_body_entered(_body: Node2D) -> void:
	var world = get_tree().current_scene
	
	if world.has_method("CollectedSoul"):
		world.CollectedSoul(1)
	
	queue_free()
