# Roadmap de Desenvolvimento: Kings Path

Sistema gamificado de progresso pessoal estilo Solo Leveling, com arquétipos Junguianos.

**Stack:** Flutter/Dart · Supabase (PostgreSQL) · Riverpod · fl_chart

---

## ✅ Concluído

### Engine de XP
- **Fórmula de progressão** — `80 + 20L + 15L²` (rápida no início, exigente no late game)
- **Multiplicadores de dificuldade** — Fácil 1x · Médio 1.5x · Difícil 3x · Épico 7x
- **Presets de XP** — botões 25/50/100/250/500 com preview do XP final em tempo real

### Identidade do Jogador
- **Arquétipos** — Guerreiro (Força+Destreza), Mago (Inteligência+Sabedoria), Rei (Carisma+Relacionamento), Equilibrado
- Calculado dinamicamente, exibido no header com cor e ícone próprios
- **Bônus de Arquétipo** — ao atingir nível 10 no arquétipo, +5% XP nos atributos primários
  - Mago: +5% XP em inteligência/sabedoria
  - Guerreiro: +5% XP em força/destreza
  - Rei: +5% XP em carisma/relacionamento
  - Progresso visível no header (ex: "Nível 7/10 para bônus")

### Interface
- **Radar Chart** dos atributos
- **Calendário com heatmap** de XP diário — intensidade da célula escala com XP ganho no dia
- **Diário do Herói** — campo "O que aprendi?" ao concluir quest, reflexões visíveis no calendário
- **Painéis flutuantes e arrastáveis** — janela overlay transparente sem borda
- **Tela de login/cadastro** integrada ao visual do app

### Infraestrutura
- **Supabase** — persistência na nuvem, sync entre Linux desktop e Android
- **RLS** — Row Level Security, cada usuário vê apenas seus próprios dados
- **Riverpod** — gerenciamento de estado reativo

---

## 📋 Backlog

### Dynamic Quest Master
- Edge Function no Supabase para geração de quests via Gemini
- Análise do perfil atual (atributos fracos, nível, histórico) para sugestão personalizada
- **The Shadow** — penalidade visual se quests diárias forem ignoradas por muitos dias

### Visual Feedback
- `TweenAnimationBuilder` nas barras de progresso do Radar Chart
- Efeito de partículas ou brilho ao concluir quest / level up

### Fricção Zero
- Atalho global de teclado (Command Palette) para nova quest sem abrir a janela principal
- Widget Android com Radar Chart e atalho para "Nova Quest"

### Persistência Offline
- Cache local com Hive ou Isar
- Sincronização com Supabase ao reconectar

### AEGIS (Futuro)
- Interpretação de comandos de voz
- Sync bidirecional com assistente pessoal
