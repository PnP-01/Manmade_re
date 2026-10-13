# Manmade

Jogo 2D de plataforma (estilo Mario) feito na **Godot 4.3+**, com 3 fases:

1. Antes da Revolução Industrial (cobras e javalis)
2. Durante a Revolução Industrial (mecânicos e atiradores)
3. Pós-Revolução Industrial (robôs e atiradores mais rápidos)

Em cada fase, o objetivo é chegar até a **porta** no final. O cronômetro é único
para o jogo todo e a pontuação de cada fase depende do tempo de término.

## Como rodar
1. Instale a Godot 4 (https://godotengine.org).
2. Abra a Godot → **Importar** → selecione o arquivo `project.godot`.
3. Aperte **F5** para jogar.

## Controles
- A / D ou ← → : andar
- W, ↑ ou ESPAÇO : pular (segure para pular mais alto)
- S ou ↓ : agachar (também desvia dos tiros)
- ESC ou P : pausa (continuar, reiniciar fase, sair)
- Pular na cabeça de um inimigo o derrota

## Pontuação
Cada fase vale 1000 pontos se terminar até o "tempo alvo" (em `scripts/game_manager.gd`).
Perde 10 pontos por segundo acima do alvo, com mínimo de 100.
Ao reiniciar uma fase, o cronômetro volta ao tempo do término da fase anterior.

## Como colocar a arte (sprites)
Coloque PNGs em `assets/sprites/<pasta>/` com o nome `<animacao>_<n>.png`
(n = 1, 2, 3... = quadros da animação). Enquanto não houver PNG, o jogo usa blocos coloridos.
Desenhe sempre **virado para a direita**: o jogo espelha automaticamente para a esquerda.

| Pasta | Animações | Tamanho de referência |
|---|---|---|
| `jogador` | `parado`, `andar`, `pular`, `agachar` | 32x64 (agachado 32x32) |
| `cobra` | `andar`, `atacar` | 48x28 |
| `javali` | `andar` | 56x40 |
| `mecanico` | `andar` | 36x56 |
| `robo` | `andar` | 40x56 |
| `atirador` | `parado`, `atacar` | 40x56 |

Exemplo: `assets/sprites/jogador/andar_1.png`, `andar_2.png`, `andar_3.png`.
Os "pés" do desenho ficam alinhados com o chão automaticamente.

## Estrutura
- `cenas/` – menu, pausa, resultado, fases, jogador, inimigo, plataforma, porta
- `scripts/` – GDScript (`game_manager.gd`: controles, cronômetro, pontos e troca de fases)
- `assets/` – sprites, áudio e fontes
