extends RefCounted
## Monta animações a partir de PNGs em  assets/sprites/<pasta>/<animacao>_<n>.png
## (n = 1, 2, 3...). Se não houver PNG, usa um bloco colorido provisório.

static func montar(pasta: String, animacoes: Dictionary) -> SpriteFrames:
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")
	for nome in animacoes.keys():
		var cfg: Dictionary = animacoes[nome]
		frames.add_animation(nome)
		frames.set_animation_speed(nome, cfg.get("fps", 8.0))
		frames.set_animation_loop(nome, cfg.get("loop", true))
		var n := 1
		var achou := false
		while true:
			var caminho := "res://assets/sprites/%s/%s_%d.png" % [pasta, nome, n]
			if not ResourceLoader.exists(caminho):
				break
			frames.add_frame(nome, load(caminho))
			achou = true
			n += 1
		if not achou:
			frames.add_frame(nome, _provisorio(cfg["tamanho"], cfg["cor"]))
	return frames


static func _provisorio(tamanho: Vector2i, cor: Color) -> Texture2D:
	var img := Image.create(tamanho.x, tamanho.y, false, Image.FORMAT_RGBA8)
	img.fill(cor)
	# "olho" no lado direito: mostra para onde o personagem está olhando
	img.fill_rect(Rect2i(tamanho.x - 12, 8, 6, 6), Color.WHITE)
	return ImageTexture.create_from_image(img)
