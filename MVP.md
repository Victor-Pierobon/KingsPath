# Kings Path — Especificação Técnica

> App de gamificação de vida diária inspirado em Solo Leveling.  
> Interface em painéis flutuantes e arrastáveis. Cross-platform: Linux desktop + Android.

---

## 1. Stack

| Camada | Tecnologia | Motivo |
|---|---|---|
| Framework | **Flutter 3.41 / Dart 3.11** | Um codebase para Linux e Android |
| Banco de dados | **Supabase (PostgreSQL)** | Gratuito, sync em tempo real, RLS por usuário |
| Auth | **Email + senha** via Supabase Auth | Sem dependências externas |
| State | **Riverpod** | Simples, reativo, sem boilerplate excessivo |
| UI flutuante desktop | `window_manager` | Janela frameless, always-on-top, transparente |
| Charts | `fl_chart` | Radar chart dos atributos |
| CI/CD | **GitHub Actions** | Build automático de APK e bundle Linux por tag |

### Por que Supabase e não Google Sheets?
- Auth próprio — sem OAuth2 do Google, sem `google-services.json`
- PostgreSQL real com Row Level Security: cada usuário vê apenas seus dados
- Funciona offline-first com reconexão transparente
- Gratuito no tier pessoal (500 MB, 50k usuários)

---

## 2. Conceito Visual

Painéis semi-transparentes estilo HUD de Solo Leveling, flutuando sobre o desktop.

```
╔══════════════════════════════════╗
║  VICTOR   Rank D  •  Lv. 12      ║
║  ✦ MAGO   Nv. 7/10               ║
║──────────────────────────────────║
║         Sabedoria                 ║
║            /\                     ║
║  Carisma  /  \  Inteligência      ║
║          / ●  \                   ║
║  Relac. <      > Força            ║
║          \    /                   ║
║           \  /                    ║
║         Destreza                  ║
║──────────────────────────────────║
║  [Quests]  [+ Nova]  [Cal] [Stats]║
╚══════════════════════════════════╝
```

- **Paleta:** fundo `#0A0A1A` (azul-noite), texto `#E0E8FF`, destaque `#7B5CF0` (roxo), dourado `#F0C040`
- **Bordas** com glow roxo (`BoxShadow`)
- **Fonte:** Rajdhani (Google Fonts)
- Todos os painéis são **arrastáveis** via `DraggablePanel`

---

## 3. Atributos

| ID | Nome | Representa |
|---|---|---|
| `forca` | ⚡ Força | Musculação, disciplina corporal, esporte |
| `inteligencia` | 📘 Inteligência | Programação, estudo técnico, cursos |
| `sabedoria` | 🌿 Sabedoria | Journaling, meditação, reflexão, terapia |
| `destreza` | 💨 Destreza | Corrida, ciclismo, HIIT, agilidade |
| `carisma` | 👁 Carisma | Comunicação, liderança, presença |
| `relacionamento` | 🤝 Relacionamento | Vínculos, networking, conexões sociais |

---

## 4. Arquétipos Junguianos

Calculados dinamicamente com base nos atributos mais desenvolvidos.

| Arquétipo | Atributos primários | Ícone | Cor |
|---|---|---|---|
| ⚔ Guerreiro | Força + Destreza | `⚔` | Vermelho `#EF5350` |
| ✦ Mago | Inteligência + Sabedoria | `✦` | Roxo `#7B5CF0` |
| ♛ Rei | Carisma + Relacionamento | `♛` | Dourado `#F0C040` |
| ◈ Equilibrado | Distribuição uniforme | `◈` | Verde `#4CAF50` |

**Regra de cálculo:** se a diferença entre o maior e o menor par for < 2 níveis → Equilibrado.

**Bônus de Arquétipo:** ao atingir média de **nível 10** nos atributos primários, desbloqueio de **+5% XP** permanente nesses atributos. Progresso exibido no header como "Nv. X/10" → "+5% XP" ao desbloquear.

---

## 5. Sistema de XP e Progressão

### Fórmula por nível (por atributo)

```
XP para próximo nível = 80 + 20L + 15L²
```

onde `L` = nível atual do atributo.

| Nível (L) | XP para subir | XP acumulado |
|---|---|---|
| 1 | 115 | 115 |
| 2 | 180 | 295 |
| 3 | 275 | 570 |
| 5 | 575 | 1.680 |
| 10 | 1.580 | 8.330 |
| 20 | 6.080 | 43.330 |

### Multiplicadores de dificuldade

| Dificuldade | Multiplicador | Uso recomendado |
|---|---|---|
| Fácil | 1× | Hábitos pequenos, tarefas rotineiras |
| Médio | 1,5× | Metas moderadas, esforço consistente |
| Difícil | 3× | Desafios reais, projetos importantes |
| Épico | 7× | Conquistas excepcionais, marcos de vida |

### Nível Global e Rank

```
Nível Global = (soma dos níveis dos 6 atributos) − 5
```

| Rank | Nível Global |
|---|---|
| E | 1–9 |
| D | 10–24 |
| C | 25–49 |
| B | 50–89 |
| A | 90–149 |
| S | 150+ |

---

## 6. Sistema de Quests

### Quest Principal (criada pelo usuário)
- Título livre
- Atributos afetados (multi-select via chips)
- XP base: presets de 25 / 50 / 100 / 250 / 500
- Dificuldade: Fácil / Médio / Difícil / Épico
- Preview em tempo real: `50 × 1.5x = 75 XP`

### Quest do Sistema (sugerida)
- Sorteada do banco pré-programado em `system_quests_data.dart`
- Aceitar → adiciona à lista de pendentes
- Ignorar → descarta sem penalidade

### Diário do Herói
Ao concluir qualquer quest, um diálogo opcional pergunta:
> "O que você aprendeu?"

A reflexão fica vinculada à data da conclusão e é exibida no calendário ao clicar no dia.

---

## 7. Banco de Dados (Supabase)

### Tabela `profile`
| Coluna | Tipo | Descrição |
|---|---|---|
| `id` | uuid PK | = `auth.uid()` |
| `name` | text | Nome do jogador |

### Tabela `attributes`
| Coluna | Tipo | Descrição |
|---|---|---|
| `id` | text | `forca`, `inteligencia`, etc. |
| `user_id` | uuid FK | Referência ao profile |
| `level` | int | Nível atual |
| `current_xp` | int | XP dentro do nível atual |

### Tabela `quests`
| Coluna | Tipo | Descrição |
|---|---|---|
| `id` | uuid PK | Gerado no cliente |
| `user_id` | uuid FK | Dono da quest |
| `title` | text | Título |
| `xp_per_attribute` | jsonb | `{"forca": 100, "destreza": 50}` |
| `difficulty` | text | `facil / medio / dificil / epico` |
| `status` | text | `pending / completed` |
| `completed_at` | timestamptz | Data de conclusão |
| `reflection` | text | Entrada do Diário do Herói |

**Row Level Security:** todas as tabelas têm políticas `using (auth.uid() = user_id)`.

---

## 8. Painéis (todos flutuantes e arrastáveis)

### Painel Principal
- Header: nome, rank, nível global, arquétipo + badge de bônus
- Radar chart dos 6 atributos
- Botões: Quests / + Nova / Cal / Stats

### Painel de Quests
- Lista de quests pendentes
- Card: título, XP por atributo, [✓ Concluir] [Abandonar]
- Botão "Sugerir Quest do Dia"
- Diálogo de conclusão com campo de reflexão + popup de level up

### Painel de Criação de Quest
- Chips de atributos (multi-select)
- Presets de XP com preview em tempo real
- Seletor de dificuldade com multiplicador visível

### Painel de Calendário
- Grade mensal com heatmap de XP (intensidade escala com XP do dia)
- Hoje destacado com borda dourada
- Clicar no dia → quests concluídas + reflexões do Diário

---

## 9. Fluxo de Uso

```
Abrir app
    │
    ▼
Login (email + senha) ──► Supabase Auth
    │
    ▼
Carregar dados do Supabase (player + quests)
    │
    ▼
Painel Principal flutuante
    │
    ├── [Quests] ──► Lista de pendentes
    │                    │
    │              [✓ Concluir]
    │                    │
    │              Diálogo: "O que aprendeu?"
    │                    │
    │              Calcular XP + bônus arquétipo
    │                    │
    │              Level up? ──► Popup dourado
    │
    ├── [+ Nova] ──► Formulário ──► Salvar no Supabase
    │
    └── [Cal] ──► Calendário com heatmap
```

---

## 10. Build e Distribuição

### Linux (desenvolvimento)
```bash
flutter run -d linux
```

### Linux (release)
```bash
flutter build linux --release
# Bundle em: build/linux/x64/release/bundle/
```

### Android APK (via CI)
Push uma tag `vX.Y.Z` → GitHub Actions builda e publica em Releases:
```bash
git tag v1.0.0
git push origin v1.0.0
```

### Android APK (local, requer Android SDK)
```bash
flutter build apk --release
# APK em: build/app/outputs/flutter-apk/app-release.apk
```

---

## 11. Estrutura de Arquivos

```
lib/
├── main.dart                      # init Supabase + window_manager (desktop)
├── app.dart                       # router (auth) + inicializador com lifecycle refresh
├── core/
│   ├── config/supabase_config.dart
│   ├── constants/
│   │   ├── app_colors.dart
│   │   └── app_ranks.dart
│   ├── models/
│   │   ├── attribute.dart
│   │   ├── player.dart            # arquétipos, xpBonusFor(), archetypeLevel
│   │   └── quest.dart
│   └── utils/
│       └── xp_calculator.dart     # xpForLevel(), applyDifficulty(), addXp()
├── data/
│   ├── supabase_service.dart      # CRUD com try/catch e logging
│   └── system_quests_data.dart    # banco pré-programado de quests
├── features/
│   ├── auth/auth_screen.dart
│   ├── calendar/calendar_panel.dart
│   ├── dashboard/
│   │   ├── dashboard_panel.dart   # PlayerNotifier + layout principal
│   │   └── radar_chart_widget.dart
│   └── quests/
│       ├── quest_board_panel.dart # QuestsNotifier + conclusão + reflexão
│       └── create_quest_panel.dart
└── widgets/
    ├── floating_window.dart
    ├── draggable_panel.dart
    └── transparent_route.dart

.github/workflows/release.yml      # CI: build APK + Linux bundle por tag
```

---

## 12. Backlog

Ver `melhorias.md` para o roadmap detalhado com prioridades.
