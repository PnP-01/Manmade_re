extends CanvasLayer
## Tela exibida ao terminar uma fase (tempo e pontos).

signal continuar

@onready var titulo: Label = $Centro/Caixa/Titulo
@onready var info: Label = $Centro/Caixa/Info
@onready var botao: Button = $Centro/Caixa/Botao


func _ready() -> void:
	visible = false
	botao.pressed.connect(_on_botao_pressed)


func mostrar(texto_titulo: String, texto_info: String, texto_botao: String) -> void:
	titulo.text = texto_titulo
	info.text = texto_info
	botao.text = texto_botao
	visible = true
	get_tree().paused = true
	botao.grab_focus()


func _on_botao_pressed() -> void:
	visible = false
	continuar.emit()
