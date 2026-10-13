extends Node
## Autoload global (GameManager): controles, cronômetro, pontuação e troca de cenas.

const MENU := "res://cenas/ui/menu_principal.tscn"

# tempo_alvo = tempo (em segundos) para ganhar a pontuação máxima na fase
const FASES = [
	{
		"titulo": "Antes da Revolução Industrial",
		"descricao": "Produção artesanal e agrícola. O trabalho é manual e o ritmo é lento.",
		"cena": "res://cenas/fases/fase_1.tscn",
		"tempo_alvo": 60.0,
	},
	{
		"titulo": "Durante a Revolução Industrial",
		"descricao": "Surgem as máquinas a vapor e as fábricas. A produção acelera.",
		"cena": "res://cenas/fases/fase_2.tscn",
		"tempo_alvo": 90.0,
	},
	{
		"titulo": "Pós-Revolução Industrial",
		"descricao": "Industrialização consolidada, urbanização e novas tecnologias.",
		"cena": "res://cenas/fases/fase_3.tscn",
		"tempo_alvo": 120.0,
	},
]

const PONTOS_MAXIMOS := 1000.0
const PONTOS_MINIMOS := 100.0
const PERDA_POR_SEGUNDO := 10.0  # pontos perdidos por segundo acima do tempo alvo

var tempo_total := 0.0          # cronômetro corrido (soma de todas as fases)
var cronometro_ativo := false
var fase_concluida := false
var tempos_fim: Array = []      # tempo acumulado no término de cada fase
var pontos_fases: Array = []


func _ready() -> void:
	_registrar_controles()


func _process(delta: float) -> void:
	if cronometro_ativo:
		tempo_total += delta


# ---------- Controles (WASD + setas) ----------
func _registrar_controles() -> void:
	_acao("esquerda", [KEY_A, KEY_LEFT])
	_acao("direita", [KEY_D, KEY_RIGHT])
	_acao("pular", [KEY_W, KEY_UP, KEY_SPACE])
	_acao("agachar", [KEY_S, KEY_DOWN])
	_acao("pausar", [KEY_ESCAPE, KEY_P])


func _acao(nome: String, teclas: Array) -> void:
	if not InputMap.has_action(nome):
		InputMap.add_action(nome)
	for tecla in teclas:
		var evento := InputEventKey.new()
		evento.physical_keycode = tecla
		InputMap.action_add_event(nome, evento)


# ---------- Fluxo do jogo ----------
func novo_jogo() -> void:
	tempos_fim.clear()
	pontos_fases.clear()
	tempo_total = 0.0


func iniciar_jogo() -> void:
	novo_jogo()
	get_tree().paused = false
	get_tree().change_scene_to_file(FASES[0]["cena"])


func iniciar_fase(numero: int) -> void:
	# Ao (re)começar uma fase, o tempo volta para o término da fase anterior
	fase_concluida = false
	tempo_total = _tempo_base(numero)
	cronometro_ativo = true


func _tempo_base(numero: int) -> float:
	if numero <= 1 or tempos_fim.size() < numero - 1:
		return 0.0
	return tempos_fim[numero - 2]


func concluir_fase(numero: int) -> Dictionary:
	cronometro_ativo = false
	fase_concluida = true
	var tempo_fase := tempo_total - _tempo_base(numero)
	var pontos := calcular_pontos(numero, tempo_fase)
	while tempos_fim.size() < numero:
		tempos_fim.append(0.0)
		pontos_fases.append(0)
	tempos_fim[numero - 1] = tempo_total
	pontos_fases[numero - 1] = pontos
	var pontos_total := 0
	for p in pontos_fases:
		pontos_total += p
	return {
		"tempo_fase": tempo_fase,
		"pontos_fase": pontos,
		"tempo_total": tempo_total,
		"pontos_total": pontos_total,
	}


func calcular_pontos(numero: int, tempo_fase: float) -> int:
	var alvo: float = FASES[numero - 1]["tempo_alvo"]
	var pontos := PONTOS_MAXIMOS - maxf(0.0, tempo_fase - alvo) * PERDA_POR_SEGUNDO
	return int(maxf(pontos, PONTOS_MINIMOS))


func proxima_fase(numero_atual: int) -> void:
	get_tree().paused = false
	if numero_atual < FASES.size():
		get_tree().change_scene_to_file(FASES[numero_atual]["cena"])
	else:
		ir_para_menu()


func reiniciar_fase() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func ir_para_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU)


func formatar_tempo(segundos: float) -> String:
	var minutos := int(segundos / 60.0)
	var resto := fmod(segundos, 60.0)
	return "%02d:%04.1f" % [minutos, resto]
