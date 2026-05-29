extends CharacterBody2D


@export var walk_speed = 150.0
@export var run_speed = 250.0
@export var jump_force = -400.0
@export var acceleration = 1500.0  
@export var deceleration = 2000.0
#@export_range(0, 1) var decelerate_on_jump_release = 0.5


func _physics_process(delta: float) -> void:

	## Handle jump.
	#if Input.is_action_pressed("jump") and is_on_floor():
		#velocity.y = jump_force
	#
	#if Input.is_action_just_released("jump") and velocity.y < 0 :
		#velocity.y *= decelerate_on_jump_release
	
	var speed
	if Input.is_action_pressed("run"):      
		speed = run_speed
	else:
		speed = walk_speed

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction : Vector2 = Input.get_vector("left", "right", "ui_up", "ui_down")
	
	if Input.is_action_pressed("right") or Input.is_action_pressed("right"):
		direction.y = 0.0
	elif Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down"):
		direction.x = 0.0
	
	if direction != Vector2.ZERO:
		var target_velocity = direction.normalized() * speed
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)

	move_and_slide()
