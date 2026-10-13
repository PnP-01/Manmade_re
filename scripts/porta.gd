extends Area2D
## Porta de saída da fase. Quando o jogador encosta, avisa a fase.

signal jogador_entrou

var _usada := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(corpo: Node2D) -> void:
	if not _usada and corpo.is_in_group("jogador"):
		_usada = true
		jogador_entrou.emit()
