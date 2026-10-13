extends Area2D
## Tiro do inimigo atirador. Mata o jogador ao encostar; some ao bater na parede/chão.

var direcao := 1.0
var velocidade := 320.0
var tempo_vida := 5.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position.x += direcao * velocidade * delta
	tempo_vida -= delta
	if tempo_vida <= 0.0:
		queue_free()


func _on_body_entered(corpo: Node2D) -> void:
	if corpo.is_in_group("jogador"):
		corpo.morrer()
	queue_free()
