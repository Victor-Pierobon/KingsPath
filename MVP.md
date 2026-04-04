# Kings Path — MVP Specification

> App de gamificação de vida diária inspirado em Solo Leveling.  
> Interface em janelas flutuantes, cross-platform (Android + Windows/Mac/Linux).

---

## 1. Stack Tecnológica

| Camada | Tecnologia | Motivo |
|---|---|---|
| Framework | **Flutter** | Único codebase para Android, iOS, Windows, macOS, Linux |
| Banco de dados | **Google Sheets API v4** | Zero infraestrutura, uso pessoal, editável manualmente |
| Auth | **Google Sign-In** (OAuth2) | Necessário para acessar o Sheets da conta do usuário |
| State | **Riverpod** | Simples, reativo, sem boilerplate excessivo |
| UI flutuante desktop | `window_manager` | Janela frameless, always-on-top, transparente |
| UI flutuante mobile | `flutter_overlay_window` | Overlay real sobre outros apps (Android) |

### Por que não web/Electron/Tauri?
- Flutter gera **binários nativos reais** — sem browser embutido, sem overhead
- `flutter_overlay_window` permite janelas flutuantes reais no Android (como widgets do SO)
- `window_manager` no desktop permite janela sem borda com transparência e always-on-top

---

## 2. Conceito Visual — Janelas Flutuantes

Inspirado no HUD de Solo Leveling: **painéis semi-transparentes** que surgem sobre a tela, não uma interface fullscreen convencional.

```
╔══════════════════════════════════╗
║  ⚔  NOVA QUEST DISPONÍVEL        ║  ← painel flutuante (overlay)
║─────────────────────────────────║
║  [Secundária] Leitura Rápida     ║
║  +15 XP  Inteligência            ║
║                                  ║
║       [Aceitar]  [Ignorar]       ║
╚══════════════════════════════════╝
```

```
╔══════════════════════════════╗
║  VICTOR  •  Rank E  •  Lv.1  ║  ← painel principal (sempre visível)
║──────────────────────────────║
║         Sabedoria             ║
║            /\                 ║
║  Carisma  /  \  Inteligência  ║  ← gráfico de radar
║          /    \               ║
║  Relac. <  ●   > Força        ║     (RadarChart - fl_chart)
║          \    /               ║
║           \  /                ║
║         Destreza              ║
║──────────────────────────────║
║  [Quests]  [+Criar]  [Stats] ║
╚══════════════════════════════╝
```

- Paleta: fundo `#0A0A1A` (azul-noite), texto `#E0E8FF`, destaque `#7B5CF0` (roxo), XP `#F0C040` (dourado)
- Bordas com glow roxo/azul (`BoxDecoration` com `BoxShadow`)
- Fonte: `Rajdhani` ou `Exo 2` (Google Fonts)
- Todas as janelas são **arrastáveis** e **redimensionáveis**

---

## 3. Atributos

| Atributo | Ícone | Atividades Exemplares |
|---|---|---|
| **Força** | ⚡ | Musculação, crossfit, caminhada pesada, esporte de contato |
| **Inteligência** | 📘 | Programar, ler artigo técnico, resolver lógica, curso online |
| **Sabedoria** | 🌿 | Journaling, meditação, terapia, reflexão, leitura filosófica |
| **Destreza** | 💨 | Corrida, ciclismo, HIIT, yoga, parkour, agilidade |
| **Carisma** | 👁 | Discurso público, etiqueta, se arrumar bem, storytelling |
| **Relacionamento** | 🤝 | Encontro, ligar para amigo, evento social, fazer novo amigo |

---

## 4. Sistema de Level e XP

### Fórmula de XP por nível (por atributo)

```
XP_para_proximo_nivel = 100 + 40 * n + 10 * n²
```

onde `n` = nível atual do atributo.

A curva é quadrática suave: nos primeiros níveis o crescimento é quase linear (o fator `100` domina), e vai curvando gradualmente sem saltos bruscos nem aceleração exponencial.

| Nível atual (n) | XP para o próximo | XP acumulado total |
|---|---|---|
| 1 | 150 | 150 |
| 2 | 220 | 370 |
| 3 | 310 | 680 |
| 4 | 420 | 1.100 |
| 5 | 550 | 1.650 |
| 6 | 700 | 2.350 |
| 7 | 870 | 3.220 |
| 8 | 1.060 | 4.280 |
| 9 | 1.270 | 5.550 |
| 10 | 1.500 | 7.050 |
| 15 | 2.650 | 18.600 |
| 20 | 4.100 | 38.700 |
| 30 | 7.300 | 108.150 |
| 50 | 17.100 | — |

**Calibração com quests do dia:** fazendo 2–3 quests diárias (~150 XP/dia por atributo):
- Lv. 1 → 2 em ~1 dia
- Lv. 5 → 6 em ~4 dias
- Lv. 10 → 11 em ~10 dias
- Lv. 20 → 21 em ~27 dias

### Nível Global (nível do jogador)

```
nivel_global = (soma dos níveis dos 6 atributos) - 5
```

> Começa em **nível 1** quando todos os atributos estão em nível 1 (6 − 5 = 1).  
> A subtração é 5, não 6 — com -6 o ponto de partida seria nível 0.

Exemplos de progressão:
| Situação | Soma dos atributos | Nível global |
|---|---|---|
| Início (todos Lv.1) | 6 | **1** |
| Atributos médios Lv.5 | 30 | **25** |
| Atributos médios Lv.10 | 60 | **55** |
| Atributos médios Lv.20 | 120 | **115** |

### Rank Global (baseado no nível global)
| Rank | Nível global |
|---|---|
| E | 1–9 |
| D | 10–24 |
| C | 25–49 |
| B | 50–89 |
| A | 90–149 |
| S | 150+ |

### XP por tipo de quest
| Tipo | XP base |
|---|---|
| Quest principal (criada pelo usuário) | 50–500 (definido na criação) |
| Quest secundária (sugerida pelo sistema) | 15–75 |
| Quest diária automática | 30 |

---

## 5. Sistema de Quests

### Quest Principal (criada pelo usuário)
```
Campos:
- Título (ex: "Completar módulo de algoritmos")
- Descrição
- Atributos afetados: [ ] Força  [ ] Inteligência  [ ] ...  (multi-select)
- XP por atributo (pode ser diferente por atributo)
- Dificuldade: Fácil / Médio / Difícil / Épico
- Prazo (opcional)
- Recorrente: Não / Diária / Semanal
```

**Exemplo:**
```
Título: Correr 5km e ouvir podcast
Atributos: Destreza (+60 XP), Inteligência (+20 XP)
Dificuldade: Médio
```

### Quest Secundária (sugerida pelo sistema)
Aparece automaticamente quando:
- O usuário abre o app sem quests pendentes
- Botão "Quests do Dia" é acionado
- Notificação diária às 08h

O sistema sorteia quests do banco pré-programado abaixo.

---

## 6. Banco de Quests Secundárias Pré-Programadas

### Força ⚡
- Fazer 20 flexões agora mesmo (25 XP)
- 30 minutos de caminhada (30 XP)
- 1 hora de academia (60 XP)
- Subir escadas em vez de elevador por um dia (20 XP)

### Inteligência 📘
- Ler 1 capítulo de um livro técnico (30 XP)
- Resolver 1 exercício de lógica ou algoritmo (25 XP)
- Assistir 1 aula de um curso online (40 XP)
- Ler um artigo sobre um tema novo (20 XP)
- Aprender 10 palavras em outro idioma (20 XP)

### Sabedoria 🌿
- Escrever 10 minutos no diário (25 XP)
- Meditar por 10 minutos (25 XP)
- Refletir sobre uma decisão difícil recente (30 XP)
- Ler um trecho de filosofia ou estoicismo (20 XP)
- Identificar 3 coisas pelas quais é grato hoje (15 XP)

### Destreza 💨
- Correr 3km no menor tempo possível (50 XP)
- 15 minutos de HIIT (45 XP)
- Sessão de alongamento / yoga de 20 minutos (25 XP)
- Pular corda por 10 minutos (30 XP)

### Carisma 👁
- Gravar um vídeo de 2 minutos falando sobre algo que domina (40 XP)
- Praticar uma abertura de conversa com um desconhecido (35 XP)
- Pesquisar e aplicar 1 regra de etiqueta nova (20 XP)
- Se arrumar completamente mesmo sem sair de casa (15 XP)
- Escrever um post ou comentário público sobre algo relevante (25 XP)

### Relacionamento 🤝
- Ligar (não mensagem) para um amigo que não fala há semanas (40 XP)
- Marcar um encontro social (presencial) (50 XP)
- Enviar uma mensagem genuína de incentivo a alguém (15 XP)
- Conhecer alguém novo (online ou presencial) (45 XP)
- Fazer algo inesperado e gentil por alguém próximo (30 XP)

---

## 7. Estrutura do Google Sheets (banco de dados)

O app cria automaticamente a planilha na primeira execução.

### Aba `stats`
| player_name | attribute | level | current_xp | total_xp_earned |
|---|---|---|---|---|
| Victor | forca | 4 | 230 | 630 |
| Victor | inteligencia | 7 | 120 | 2620 |
| ... | | | | |

### Aba `quests`
| id | title | description | attributes | xp_per_attribute | difficulty | due_date | recurrence | status | created_at |
|---|---|---|---|---|---|---|---|---|---|
| q001 | Correr 5km | ... | destreza,inteligencia | 60,20 | medio | 2026-04-05 | none | pending | 2026-04-03 |

- `attributes`: separado por vírgula  
- `xp_per_attribute`: XP correspondente, na mesma ordem  
- `status`: `pending` / `completed` / `failed` / `skipped`

### Aba `history`
| quest_id | title | completed_at | xp_awarded | attributes_leveled_up |
|---|---|---|---|---|
| q001 | Correr 5km | 2026-04-03T14:22 | destreza:60,inteligencia:20 | destreza |

### Aba `system_quests`
Tabela estática das quests secundárias pré-programadas (seção 6).  
Pode ser editada manualmente no Sheets para adicionar quests personalizadas.

| id | title | attribute | xp | category |
|---|---|---|---|---|
| sq001 | Fazer 20 flexões agora mesmo | forca | 25 | daily |

---

## 8. Telas / Painéis (todos flutuantes)

### 8.1 Painel Principal (sempre visível)
- Status do jogador: nome, rank e nível global
- **Gráfico de radar** centralizado com os 6 atributos (ver seção 8.8)
- Botões: [Quests] [+Nova Quest] [Stats]
- Dimensão padrão: ~320×400px, arrastável

### 8.2 Painel de Quests
- Lista de quests pendentes (principais + secundárias aceitas)
- Cada card: título, atributos afetados, XP total, botão [Concluir] [Abandonar]
- Botão "Sugerir Quest do Dia"

### 8.3 Painel Criação de Quest
- Formulário: título, descrição, atributos (chips selecionáveis), XP por atributo, prazo, recorrência
- Botão [Criar Quest]

### 8.4 Popup de Level Up (automático)
Aparece ao completar uma quest que resulta em level up:
```
╔═══════════════════════════╗
║   ✦ LEVEL UP!  ✦          ║
║                            ║
║   Inteligência             ║
║   Lv. 6  →  Lv. 7         ║
║                            ║
║       [ OK ]               ║
╚═══════════════════════════╝
```

### 8.5 Popup de Quest Concluída
- Título da quest concluída
- Lista de XP ganho por atributo com animação de contador
- Alerta de level up se ocorreu

### 8.6 Painel de Histórico
- Lista das últimas quests concluídas com data e XP ganho
- Filtro por atributo

### 8.7 Configurações
- Conta Google (login/logout)
- ID da planilha (ou botão "Criar nova planilha")
- Notificações: horário do lembrete diário
- Nome do jogador

### 8.8 Painel de Estatísticas (Stats)
Abre ao clicar em [Stats] no painel principal.

- **Radar chart em destaque** (~260×260px):
  - 6 eixos, um por atributo
  - O valor de cada eixo é o **nível atual** do atributo (normalizado 0–max_level para o raio)
  - Preenchimento com cor roxa semi-transparente (`#7B5CF0` a 40% de opacidade)
  - Bordas com glow azul
  - Labels dos atributos com ícone + nível (ex: `⚡ Lv.4`)
- Abaixo do radar: barras de XP individuais por atributo (progresso dentro do nível atual)
- Dimensão do painel: ~340×520px, arrastável

**Comportamento do radar:**
- O radar reflete o **nível** de cada atributo, não o XP bruto — isso torna o perfil visual estável e legível
- Um jogador focado em Inteligência terá o eixo correspondente muito maior que os demais, revelando o "build" do personagem
- Ao ocorrer level up, o radar anima suavemente expandindo o eixo afetado (`AnimatedRadarChart`)

---

## 9. Fluxo de Uso

```
Inicializar app
      │
      ▼
 Google Sign-In ──► Verificar/criar Sheets
      │
      ▼
 Painel Principal flutuante (sempre ativo)
      │
      ├── [Quests] ─► Listar quests pendentes
      │                     │
      │               [Concluir Quest]
      │                     │
      │               Calcular XP + salvar no Sheets
      │                     │
      │               Level up? ──► Popup de Level Up
      │
      ├── [+Nova Quest] ─► Formulário ─► Salvar no Sheets
      │
      └── [Sugerir Quest] ─► Sortear do banco de system_quests
                                   ─► Popup com opção Aceitar/Ignorar
```

---

## 10. Notificações

- **08h00**: "Você tem X quests pendentes. Bom dia, Hunter."
- **20h00**: "Você completou quests hoje? Não deixe o dia passar sem progresso."
- Se nenhuma quest foi concluída no dia: "Dia livre detectado. Quer uma sugestão de quest rápida?"

---

## 11. Fases de Implementação

### Fase 1 — Core (MVP funcionando)
- [ ] Setup Flutter + autenticação Google
- [ ] Criar/ler planilha automaticamente
- [ ] Painel principal com radar chart dos atributos
- [ ] Painel de Stats com radar + barras de XP
- [ ] Criar e completar quests (principais)
- [ ] Sistema de XP e level up por atributo
- [ ] Popup de level up com animação do eixo do radar

### Fase 2 — Janelas Flutuantes
- [ ] `window_manager` para desktop (frameless, always-on-top, arrastável)
- [ ] `flutter_overlay_window` para Android
- [ ] Tema visual Solo Leveling completo

### Fase 3 — Quests Secundárias
- [ ] Banco de system_quests pré-programado
- [ ] Botão "Sugerir Quest do Dia"
- [ ] Notificações locais (flutter_local_notifications)

### Fase 4 — Polimento
- [ ] Animações (XP aumentando, level up)
- [ ] Histórico detalhado
- [ ] Quests recorrentes automáticas (diária/semanal)
- [ ] Rank global baseado na média dos atributos

---

## 12. Dependências Flutter (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Google
  google_sign_in: ^6.2.1
  googleapis: ^13.1.0
  googleapis_auth: ^1.4.1

  # State
  flutter_riverpod: ^2.5.1

  # UI
  google_fonts: ^6.2.1
  fl_chart: ^0.69.0          # gráfico de radar

  # Desktop
  window_manager: ^0.3.9

  # Mobile overlay
  flutter_overlay_window: ^0.3.0

  # Notificações
  flutter_local_notifications: ^17.2.2

  # Utils
  uuid: ^4.4.0
  intl: ^0.19.0
```

---

## 13. Estrutura de Pastas

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/         # cores, fontes, ranks
│   ├── models/            # Attribute, Quest, Player
│   └── utils/             # xp_calculator.dart, rank.dart
├── data/
│   ├── sheets_repository.dart   # CRUD no Google Sheets
│   └── system_quests_data.dart  # banco pré-programado hardcoded
├── features/
│   ├── auth/
│   │   └── auth_provider.dart
│   ├── dashboard/
│   │   ├── dashboard_panel.dart
│   │   └── attribute_bar.dart
│   ├── quests/
│   │   ├── quest_board_panel.dart
│   │   ├── create_quest_panel.dart
│   │   └── quest_card.dart
│   └── notifications/
│       └── notification_service.dart
└── widgets/
    ├── floating_window.dart      # wrapper base para todos os painéis
    ├── level_up_popup.dart
    └── quest_complete_popup.dart
```

---

## 14. Próximos Passos para Iniciar

1. **Criar projeto Flutter**: `flutter create kings_path --org com.seuname`
2. **Ativar plataformas**: `flutter config --enable-windows-desktop`
3. **Google Cloud Console**: criar projeto, ativar *Google Sheets API* e *Google Drive API*, configurar OAuth2 para desktop e Android
4. **Copiar `pubspec.yaml`** com as dependências da seção 12
5. **Implementar na ordem das fases** (seção 11)

> O Google Sheets da conta do usuário será criado automaticamente na primeira autenticação,  
> já com todas as abas estruturadas. Nenhum servidor externo necessário.
