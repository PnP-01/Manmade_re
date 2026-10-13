@tool
extends StaticBody2D
## Plataforma/chão retangular. A posição é o CENTRO da plataforma.
## Mude "Tamanho" e "Cor" no Inspetor; o visual e a colisão se ajustam sozinhos.

@export var tamanho: Vector2 = Vector2(160, 24):
	set(valor):
		tamanho = valor
		_atualizar()

@export var cor: Color = Color(0.3, 0.22, 0.12, 1):
	set(valor):
		cor = valor
		_atualizar()


func _ready() -> void:
	_atualizar()


func _atualizar() -> void:
	if not is_inside_tree():
		return
	var visual := get_node_or_null("Visual") as ColorRect
	var colisao := get_node_or_null("Colisao") as CollisionShape2D
	if visual:
		visual.size = tamanho
		visual.position = -tamanho / 2.0
		visual.color = cor
	if colisao:
		var forma := RectangleShape2D.new()
		forma.size = tamanho
		colisao.shape = forma
