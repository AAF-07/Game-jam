extends Node2D

# buat control UI Skill check dan sanity
var sanity = 100
var soul_collected = 0

@onready var sanity_bar = $CanvasLayer/TextureProgressBar
@onready var soul_label = $CanvasLayer/Label

var sanity_timer: Timer = null

func _ready() -> void:
	update_ui()
	
	# PERBAIKAN 2: Cari node berjenis Timer secara otomatis
	for child in get_children():
		if child is Timer:
			sanity_timer = child
			break # Jika ketemu, stop pencarian
			
	# PERBAIKAN 3: Validasi aman sebelum memanggil .start()
	if sanity_timer != null:
		sanity_timer.start()
		print("Keren! Timer otomatis ketemu dan dijalankan.")
	else:
		print("Waduh! Masih belum ada node Timer di Scene ini. Coba cek struktur Scene Tree kamu.")

func update_ui():
	if sanity_bar != null:
		sanity_bar.value = sanity
	if soul_label != null:
		soul_label.text = "Soul : " + str(soul_collected)

func CollectedSoul(amount: int):
	soul_collected += amount
	sanity += 5
	update_ui()
	print("tambah soul total = ", soul_collected) 
	print("sanity bertambah =", sanity)

func SanityBar(amount: int):
	sanity = clamp(sanity - amount, 0, 100)
	update_ui()

	if sanity <= 0:
		print("player gila")

func _on_sanity_timer_timeout() -> void:
	SanityBar(3)
	print("Sanity berkurang otomatis: ", sanity)
