extends Node2D

# buat control UI Skill check dan sanity
var sanity = 1
var soul_collected = 0
var arrow_key = ["ui_left", "ui_right", "ui_up", "ui_down"]
var target_sequence = []
var current_index = 0
var is_skill_checking = false
var is_nightmare = false
var soul_total = 0

@onready var sanity_bar = $CanvasLayer/TextureProgressBar
@onready var soul_label = $CanvasLayer/Label
@onready var skillcheck_label = $CanvasLayer/SkillCheckLabel

var sanity_timer: Timer = null
var skill_check_timer: Timer = null 

func _ready() -> void:
	update_ui()
	var timers = []
	for child in get_children(): # nyari timer sanity
		if child is Timer:
			timers.append(child)	
	
	if timers.size() >= 2:
		sanity_timer = timers[0]
		skill_check_timer = timers[1]
		
		sanity_timer.start()
		
	soul_spawn_random()

func update_ui():
	if sanity_bar != null:
		sanity_bar.value = sanity
	if soul_label != null:
		soul_label.text = "Soul : " + str(soul_collected) + " / " + str(soul_total)
		
func CollectedSoul(amount: int):
	soul_collected += amount
	sanity += 5
	update_ui()
	print("tambah soul total = ", soul_collected) 
	print("sanity bertambah =", sanity)
	
	if soul_collected >= soul_total and soul_total > 0:
		win()

func SanityBar(amount: int):
	sanity = clamp(sanity - amount, 0, 100)
	update_ui()

	if sanity <= 0:
		nightmare_mode()

func _on_sanity_timer_timeout() -> void:
	if not is_skill_checking:
		SanityBar(3)
	print("Sanity berkurang otomatis: ", sanity)
	
	if sanity <= 0:
		sanity_timer.stop()
	
	if is_nightmare:
		sanity_timer.stop()


func _on_sc_timer_timeout() -> void:
	if is_skill_checking:
		SanityBar(5)
		print("Sanity bocor deras saat Skill Check: ", sanity)

func update_skill_check_text():
	if skillcheck_label == null: return
	var display_text = "TEKAN TOMBOL: \n"
	for i in range(target_sequence.size()):
		# Perbaikan typo: .replaced menjadi .replace
		var arrow_name = target_sequence[i].replace("ui_", "").to_upper()
		if i < current_index:
			display_text += "[OK] "
		else:
			# Perbaikan typo: display_text dan memanggil arrow_name (bukan arrow_key)
			display_text += arrow_name + " "
	skillcheck_label.text = display_text

func start_skill_check():
	if is_skill_checking: return
	
	is_skill_checking = true
	current_index = 0
	target_sequence.clear()
	
	# 1. HENTIKAN GAME (PAUSE TOTAL)
	# Ini akan membekukan Player, Monster, dan pergerakan lainnya otomatis
	get_tree().paused = true
	
	if not is_nightmare:
		if sanity_timer != null: sanity_timer.stop()
		if skill_check_timer != null: skill_check_timer.start()
	
	var jumlah = 10 if is_nightmare else 5
	for i in range(jumlah):
		var random_arrow = arrow_key[randi() % arrow_key.size()]
		target_sequence.append(random_arrow)
		
	update_skill_check_text()
	if skillcheck_label != null:
		skillcheck_label.show()

# PENTING: Tambahkan fungsi input ini agar World tetap bisa membaca tombol saat pause!
func _input(event: InputEvent) -> void:
	if get_tree().paused and not is_skill_checking:
		# Tekan R untuk Restart game dari awal
		if event is InputEventKey and event.pressed and event.keycode == KEY_R:
			get_tree().paused = false
			get_tree().reload_current_scene()
			return
		# Tekan ENTER untuk kembali ke Main Menu (Jika ada scene Main Menu nantinya)
		if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
			get_tree().paused = false
			# get_tree().change_scene_to_file("res://Scene/main_menu.tscn") # aktifkan jika sudah buat menu
			return
			
	if not is_skill_checking: return
			
	for action in arrow_key:
		if event.is_action_pressed(action):
			# Cek apakah tombol yang ditekan sesuai urutan
			if action == target_sequence[current_index]:
				current_index += 1
				update_skill_check_text()
				
				# Jika semua tombol sukses ditekan
				if current_index >= target_sequence.size():
					skill_check_success()
					return # Keluar dari fungsi agar tidak error
			else:
				# Jika salah pencet tombol
				skill_check_failed()
				return

func skill_check_success():
	is_skill_checking = false
	if skillcheck_label != null:
		skillcheck_label.hide()
		
	if skill_check_timer != null: skill_check_timer.stop()
	if sanity_timer != null: sanity_timer.start()
	
	# HADIAH & UNPAUSE GAME
	sanity = clamp(sanity + 15, 0, 100)
	update_ui()
	
	# KEMBALIKAN GAME AGAR BERJALAN NORMAL LAGI
	get_tree().paused = false
	
	var monster = get_node_or_null("Monster")
	if monster != null and monster.has_method("stun"):
		monster.stun(3)

func skill_check_failed():
	print("Salah pencet! Skill check gagal.")

	is_skill_checking = false
	if skillcheck_label != null: skillcheck_label.hide()
	if skill_check_timer != null: skill_check_timer.stop()
	if sanity_timer != null: sanity_timer.start()
	
	if is_nightmare:
		game_over()
		print("game over")

	
	get_tree().paused = true # Unpause

func nightmare_mode():
	is_nightmare = true
	
	sanity_timer.stop()
	skill_check_timer.stop()
	
	var monster = get_node_or_null("Monster")
	if monster != null:
		monster.SPEED = 245.0
		monster.player = $Player
		monster.player_chase = true
	
func soul_spawn_random():
	if not has_node("SpawnPoint"): 
		print("Waduh, node SpawnPoint tidak ketemu di scene!")
		return
		
	var points = $SpawnPoint.get_children()
	if points.size() == 0: 
		print("Waduh, isi didalam SpawnPoint kosong / tidak terbaca!")
		return
	
	points.shuffle()
	
	var _spawn_count = min(5, points.size())
	soul_total = _spawn_count
	
	for i in range(_spawn_count):
		# Menggunakan load() agar lebih aman mendeteksi file scene soul kamu
		var soul_scene = load("res://Scene/soul.tscn")
		if soul_scene:
			var new_soul = soul_scene.instantiate()
			new_soul.position = points[i].position
			add_child(new_soul)
		else:
			print("ERROR: File soul.tscn tidak ditemukan di folder res://Scene/")
	
	update_ui()
	
	
func win():
	sanity_timer.stop()
	skill_check_timer.stop()
	
	if skillcheck_label != null:
		skillcheck_label.text = "WAKE UP\n\nTekan [ R ] untuk Main Lagi"
		skillcheck_label.show()
	
	get_tree().paused = true

func game_over():
	sanity_timer.stop()
	skill_check_timer.stop()
	
	is_skill_checking = false
	
	if skillcheck_label != null:
		skillcheck_label.text = "YOU ARE TRAPPED IN A NIGHTMARE\n\nTekan [ R ] untuk Mengulang"
		skillcheck_label.show()
	
	get_tree().paused = true
	
