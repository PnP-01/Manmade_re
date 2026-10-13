extends CharacterBody2D
## Inimigo configurável pelo "Tipo" no Inspetor: cobra, javali, mecanico, robo, atirador.
## Para derrotar: pular em cima da cabeça. Encostar de outro jeito = morrer.

const SpritesUtil = preload("res://scripts/sprites_util.gd")
const PROJETIL = preload("res://cenas/projetil.tscn")

const GRAVIDADE := 1400.0
const VEL_INVESTIDA := 170.0
const ALCANCE_BOTE := 130.0     # distância em que a cobra ataca
const ALCANCE_VISAO := 600.0    # distância em que o atirador enxerga o jogador

const TIPOS = {
	"cobra": {"largura": 48, "altura": 28, "velocidade": 45.0, "cor": Color(0.2, 0.65, 0.2), "anims": ["andar", "atacar"], "ataque": "investida"},
	"javali": {"largura": 56, "altura": 40, "velocidade": 95.0, "cor": Color(0.5, 0.33, 0.2), "anims": ["andar"], "ataque": ""},
	"mecanico": {"largura": 36, "altura": 56, "velocidade": 110.0, "cor": Color(0.55, 0.55, 0.6), "anims": ["andar"], "ataque": ""},
	"robo": {"largura": 40, "altura": 56, "velocidade": 150.0, "cor": Color(0.3, 0.6, 0.85), "anims": ["andar"], "ataque": ""},
	"atirador": {"largura": 40, "altura": 56, "velocidade": 0.0, "cor": Color(0.75, 0.3, 0.3), "anims": ["parado", "atacar"], "ataque": "tiro"},
}

@export var tipo: String = "cobra"
@export var distancia_patrulha: float = 120.0
@export var intervalo_tiro: float = 2.0

var cfg: Dictionary
var altura := 0.0
var origem_x := 0.0
var direcao := -1
var morto := false
var tempo_ataque := 0.0
var recarga := 0.0
var jogador = null
var frames: SpriteFrames

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var colisao: CollisionShape2D = $Colisao
@onready var dano: Area2D = $Dano
@onready var colisao_dano: CollisionShape2D = $Dano/ColisaoDano


func _ready() -> void:
	cfg = TIPOS[tipo]
	altura = float(cfg["altura"])
	var largura := float(cfg["largura"])
	origem_x = global_position.x

	var forma := RectangleShape2D.new()
	forma.size = Vector2(largura, altura)
	colisao.shape = forma
	var forma_dano := RectangleShape2D.new()
	forma_dano.size = Vector2(largura + 6.0, altura + 6.0)
	colisao_dano.shape = forma_dano

	var anims := {}
	for nome in cfg["anims"]:
		anims[nome] = {
			"fps": 8.0,
			"tamanho": Vector2i(int(largura), int(altura)),
			"cor": cfg["cor"] if nome != "atacar" else cfg["cor"].lightened(0.4),
			"loop": nome != "atacar",
		}
	frames = SpritesUtil.montar(tipo, anims)
	sprite.sprite_frames = frames
	sprite.play("parado" if frames.has_animation("parado") else "andar")


func _physics_process(delta: float) -> void:
	if morto:
		return
	if not is_on_floor():
		velocity.y += GRAVIDADE * delta
	recarga = maxf(recarga - delta, 0.0)
	tempo_ataque = maxf(tempo_ataque - delta, 0.0)

	var alvo = _achar_jogador()
	if cfg["ataque"] == "tiro":
		_comportamento_atirador(alvo)
	else:
		_patrulhar(float(cfg["velocidade"]))
		if cfg["ataque"] == "investida":
			_comportamento_investida(alvo)

	move_and_slide()
	_atualizar_animacao()
	_checar_jogador()


func _achar_jogador():
	if jogador == null or not is_instance_valid(jogador):
		jogador = get_tree().get_first_node_in_group("jogador")
	return jogador


func _patrulhar(vel: float) -> void:
	if tempo_ataque > 0.0:
		return
	if global_position.x <= origem_x - distancia_patrulha:
		direcao = 1
	elif global_position.x >= origem_x + distancia_patrulha:
		direcao = -1
	elif is_on_wall():
		direcao = -direcao
	velocity.x = direcao * vel


func _comportamento_investida(alvo) -> void:
	if tempo_ataque > 0.0:
		velocity.x = direcao * VEL_INVESTIDA
		return
	if alvo == null or recarga > 0.0:
		return
	var dx: float = alvo.global_position.x - global_position.x
	var dy: float = absf(alvo.global_position.y - global_position.y)
	if absf(dx) < ALCANCE_BOTE and dy < 70.0:
		direcao = 1 if dx > 0.0 else -1
		tempo_ataque = 0.5
		recarga = 1.8
		sprite.play("atacar")


func _comportamento_atirador(alvo) -> void:
	velocity.x = 0.0
	if alvo == null:
		return
	var dx: float = alvo.global_position.x - global_position.x
	var dy: float = absf(alvo.global_position.y - global_position.y)
	if absf(dx) < ALCANCE_VISAO and dy < 200.0:
		direcao = 1 if dx > 0.0 else -1
		if recarga <= 0.0:
			_atirar()
			recarga = intervalo_tiro


func _atirar() -> void:
	tempo_ataque = 0.3
	sprite.play("atacar")
	var tiro = PROJETIL.instantiate()
	tiro.direcao = direcao
	get_parent().add_child(tiro)
	# Altura do tiro: acerta quem está em pé, mas passa por cima de quem está agachado
	tiro.global_position = global_position + Vector2(direcao * 30.0, -18.0)


func _atualizar_animacao() -> void:
	sprite.flip_h = direcao < 0
	var anim := "andar"
	if tempo_ataque > 0.0 and frames.has_animation("atacar"):
		anim = "atacar"
	elif absf(velocity.x) < 1.0 and frames.has_animation("parado"):
		anim = "parado"
	if sprite.animation != anim:
		sprite.play(anim)
	var tex := frames.get_frame_texture(sprite.animation, sprite.frame)
	if tex:
		sprite.position.y = altura / 2.0 - tex.get_height() / 2.0


func _checar_jogador() -> void:
	for corpo in dano.get_overlapping_bodies():
		var j = corpo
		if not j.is_in_group("jogador"):
			continue
		var pes: float = j.global_position.y + 32.0
		var topo := global_position.y - altura / 2.0
		if j.velocity.y > 0.0 and pes <= topo + 24.0:
			_derrotar()
			j.quicar()
		else:
			j.morrer()
		return


func _derrotar() -> void:
	morto = true
	velocity = Vector2.ZERO
	colisao.set_deferred("disabled", true)
	dano.set_deferred("monitoring", false)
	var tween := create_tween()
	tween.tween_property(sprite, "scale:y", 0.15, 0.15)
	tween.tween_callback(queue_free)
