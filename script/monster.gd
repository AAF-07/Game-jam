extends CharacterBody2D

@export var SPEED = 150.0
@export var is_chasing: bool = true

var player: CharacterBody2D = null 

func _ready() -> void:
	# Mengambil objek pertama yang ada di dalam group "player"
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0] as CharacterBody2D
	else:
		print("PERINGATAN: Tidak ada objek di group 'player'. Pastikan Player sudah dimasukkan ke group!")

func _physics_process(delta: float) -> void:
	# Validasi: Pastikan player ketemu dan mode mengejar aktif
	if is_chasing and player != null:
		# Hitung arah ke player (menghasilkan koordinat X dan Y)
		var direction = position.direction_to(player.position)
		
		# Mengisi velocity untuk arah X dan Y sekaligus
		velocity = direction * SPEED
		
		# Logika membalik sprite (Flip) berdasarkan arah X
		if direction.x < 0:
			$Sprite2D.flip_h = true  # Menghadap kiri
		elif direction.x > 0:
			$Sprite2D.flip_h = false # Menghadap kanan
			
		# PENTING: Fungsi ini yang menggerakkan monster di sumbu X dan Y
		move_and_slide()
	else:
		velocity = Vector2.ZERO
