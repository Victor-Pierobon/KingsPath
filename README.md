# Kings Path

Sistema gamificado de evolução pessoal estilo Solo Leveling, desenvolvido em Flutter para Linux desktop e Android.

## Conceito

Transforme seus hábitos e objetivos em quests RPG. Cada ação real — estudar, treinar, socializar — ganha XP em atributos específicos do seu personagem. O sistema calcula automaticamente seu arquétipo dominante (Mago, Guerreiro, Rei) com base nos atributos mais desenvolvidos.

## Atributos

| Atributo | Representa |
|---|---|
| ⚡ Força | Exercício físico, disciplina corporal |
| 📘 Inteligência | Estudo, aprendizado técnico |
| 🌿 Sabedoria | Reflexão, meditação, escrita |
| 💨 Destreza | Agilidade, performance, habilidades motoras |
| 👁 Carisma | Comunicação, presença, liderança |
| 🤝 Relacionamento | Vínculos, networking, conexões genuínas |

## Arquétipos

- ⚔ **Guerreiro** — Força + Destreza dominantes
- ✦ **Mago** — Inteligência + Sabedoria dominantes
- ♛ **Rei** — Carisma + Relacionamento dominantes
- ◈ **Equilibrado** — distribuição uniforme

## Stack

- **Flutter/Dart** — UI cross-platform (Linux + Android)
- **Supabase** — banco PostgreSQL na nuvem, sync em tempo real
- **Riverpod** — gerenciamento de estado
- **fl_chart** — radar chart dos atributos

## Setup

### Requisitos
```bash
sudo pacman -S cmake ninja clang pkg-config gtk3
yay -S flutter
```

### Configuração do Supabase
1. Crie um projeto em [supabase.com](https://supabase.com)
2. Execute o SQL em `docs/schema.sql`
3. Desative "Confirm email" em Authentication → Providers → Email
4. Preencha `lib/core/config/supabase_config.dart` com URL e anon key

### Rodar
```bash
flutter pub get
flutter run -d linux
```

## Progressão de XP

Fórmula por nível: `XP = 80 + 20L + 15L²`

Multiplicadores por dificuldade:
- Fácil: 1x · Médio: 1.5x · Difícil: 3x · Épico: 7x
