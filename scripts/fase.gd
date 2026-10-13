extends Node2D
## Script compartilhado pelas 3 fases. Textos e pontuação vêm do GameManager.

@export var numero_fase: int = 1
@export var largura_fase: int = 3600

@onready var titulo: Label = $UI/Titulo
@onready var descricao: Label = $UI/Descricao
@onready var cronometro: Label = $UI/Cronometro
@onready var jogador = $Jogador
@onready var porta = $Porta
@onready var resultado = $Resultado


func _ready() -> void:
	var dados: Dictionary = GameManager.FASES[numero_fase - 1]
	titulo.text = "Fase %d: %s" % [numero_fase, dados["titulo"]]
	descricao.text = dados["descricao"]
	GameManager.iniciar_fase(numero_fase)
	jogador.limite_direito = float(largura_fase)
	jogador.get_node("Camera").limit_right = largura_fase
	porta.jogador_entrou.connect(_on_porta_jogador_entrou)


func _process(_delta: float) -> void:
	cronometro.text = GameManager.formatar_tempo(GameManager.tempo_total)


func _on_porta_jogador_entrou() -> void:
	var r: Dictionary = GameManager.concluir_fase(numero_fase)
	var ultima := numero_fase >= GameManager.FASES.size()
	resultado.continuar.connect(_on_continuar, CONNECT_ONE_SHOT)
	if ultima:
		resultado.mostrar(
			"Jogo concluído!",
			"Tempo total: %s\nPontos totais: %d" % [GameManager.formatar_tempo(r["tempo_total"]), r["pontos_total"]],
			"Voltar ao menu")
	else:
		resultado.mostrar(
			"Fase %d concluída!" % numero_fase,
			"Tempo da fase: %s\nPontos da fase: %d\nTempo total: %s" % [
				GameManager.formatar_tempo(r["tempo_fase"]), r["pontos_fase"],
				GameManager.formatar_tempo(r["tempo_total"])],
			"Próxima fase")


func _on_continuar() -> void:
	GameManager.proxima_fase(numero_fase)
