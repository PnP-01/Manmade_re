extends Control

@onready var botao_iniciar: Button = $Centro/Caixa/BotaoIniciar
@onready var botao_sair: Button = $Centro/Caixa/BotaoSair


func _ready() -> void:
	botao_iniciar.pressed.connect(GameManager.iniciar_jogo)
	botao_sair.pressed.connect(get_tree().quit)
