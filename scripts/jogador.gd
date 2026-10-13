extends CharacterBody2D
## Jogador: andar (A/D ou ←/→), pular (W, ↑ ou ESPAÇO) e agachar (S ou ↓).

const SpritesUtil = preload("res://scripts/sprites_util.gd")

const VELOCIDADE := 240.0
const VELOCIDADE_AGACHADO := 90.0
const FORCA_PULO := -650.0      # mais negativo = pulo mais alto
const CORTE_PULO := -350.0      # soltar o botão corta o pulo
const FORCA_QUIQUE := -420.0    # impulso ao pisar em inimigo
const GRAVIDADE := 1400.0
const TEMPO_COYOTE := 0.1       # ainda pode pular logo após sair da borda
const TEMPO_BUFFER := 0.1       # aceita o pulo apertado um pouco antes de pousar
const LARGURA := 32.0
const ALTURA_EM_PE := 64.0
const ALTURA_AGACHADO := 32.0

# Tamanhos dos sprites provisórios (os PNGs reais podem ter qualquer tamanho)
const ANIMACOES := {
	"parado": {"fps": 6.0, "tamanho": Vector2i(32, 64), "cor": Color(0.9, 0.3, 0.2)},
	"andar": {"fps": 10.0, "tamanho": Vector2i(32, 64), "cor": Color(0.95, 0.5, 0.2)},
	"pular": {"fps": 6.0, "tamanho": Vector2i(32, 64), "cor": Color(0.95, 0.7, 0.3), "loop": false},
	"agachar": {"fps": 6.0, "tamanho": Vector2i(32, 32), "cor": Color(0.6, 0.15, 0.1)},
}

var limite_direito: float = 2400.0  # a fase ajusta esse valor
var agachado := false
var morto := false
var olhando_esquerda := false
var tempo_coyote := 0.0
var tempo_buffer := 0.0

@onready var colisao: CollisionShape2D = $Colisao
@onready var sprite: AnimatedSprite2D = $Sprite


func _ready() -> void:
	sprite.sprite_frames = SpritesUtil.montar("jogador", ANIMACOES)
	sprite.play("parado")
	_definir_agachado(false)


func _physics_process(delta: float) -> void:
	if morto:
		return

	if not is_on_floor():
		velocity.y += GRAVIDADE * delta

	# Agachar / levantar
	var quer_agachar := Input.is_action_pressed("agachar") and is_on_floor()
	if quer_agachar and not agachado:
		_definir_agachado(true)
	elif not quer_agachar and agachado and _pode_levantar():
		_definir_agachado(false)

	# Pulo (com coyote time e buffer, para ficar mais gostoso de jogar)
	if is_on_floor():
		tempo_coyote = TEMPO_COYOTE
	else:
		tempo_coyote -= delta
	if Input.is_action_just_pressed("pular"):
		tempo_buffer = TEMPO_BUFFER
	else:
		tempo_buffer -= delta
	if tempo_buffer > 0.0 and tempo_coyote > 0.0 and not agachado:
		velocity.y = FORCA_PULO
		tempo_buffer = 0.0
		tempo_coyote = 0.0
	if velocity.y < CORTE_PULO and not Input.is_action_pressed("pular"):
		velocity.y = CORTE_PULO

	# Movimento horizontal
	var direcao := Input.get_axis("esquerda", "direita")
	if direcao != 0.0:
		olhando_esquerda = direcao < 0.0
	velocity.x = direcao * (VELOCIDADE_AGACHADO if agachado else VELOCIDADE)

	move_and_slide()

	position.x = clampf(position.x, LARGURA / 2.0, limite_direito - LARGURA / 2.0)

	# Caiu num buraco
	if position.y > 900.0:
		morrer()

	_atualizar_animacao()


func _atualizar_animacao() -> void:
	var anim := "parado"
	if agachado:
		anim = "agachar"
	elif not is_on_floor():
		anim = "pular"
	elif absf(velocity.x) > 10.0:
		anim = "andar"
	if sprite.animation != anim:
		sprite.play(anim)
	sprite.flip_h = olhando_esquerda
	# Mantém os "pés" do sprite sempre no chão, seja qual for o tamanho da arte
	var tex := sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	if tex:
		sprite.position.y = ALTURA_EM_PE / 2.0 - tex.get_height() / 2.0


func _definir_agachado(valor: bool) -> void:
	agachado = valor
	var altura := ALTURA_AGACHADO if valor else ALTURA_EM_PE
	var topo := ALTURA_EM_PE / 2.0 - altura  # os pés ficam sempre na mesma posição
	var forma := colisao.shape as RectangleShape2D
	forma.size = Vector2(LARGURA, altura)
	colisao.position.y = topo + altura / 2.0


func _pode_levantar() -> bool:
	return not test_move(global_transform, Vector2(0, -(ALTURA_EM_PE - ALTURA_AGACHADO)))


func quicar() -> void:
	velocity.y = FORCA_QUIQUE


func morrer() -> void:
	if morto:
		return
	morto = true
	GameManager.reiniciar_fase.call_deferred()
