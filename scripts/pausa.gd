extends CanvasLayer
## Menu de pausa (ESC ou P): Continuar, Reiniciar fase, Sair do jogo.

@onready var botao_continuar: Button = $Centro/Caixa/BotaoContinuar
@onready var botao_reiniciar: Button = $Centro/Caixa/BotaoReiniciar
@onready var botao_sair: Button = $Centro/Caixa/BotaoSair


func _ready() -> void:
	visible = false
	botao_continuar.pressed.connect(_retomar)
	botao_reiniciar.pressed.connect(_reiniciar)
	botao_sair.pressed.connect(get_tree().quit)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pausar") and not GameManager.fase_concluida:
		if visible:
			_retomar()
		else:
			_pausar()
		get_viewport().set_input_as_handled()


func _pausar() -> void:
	visible = true
	get_tree().paused = true
	botao_continuar.grab_focus()


func _retomar() -> void:
	visible = false
	get_tree().paused = false


func _reiniciar() -> void:
	visible = false
	GameManager.reiniciar_fase()
