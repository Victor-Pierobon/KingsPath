# Kings Path

Sistema de gamificação de vida pessoal estilo Solo Leveling. Cada ação real — estudar, treinar, socializar — gera XP em atributos do seu personagem. A interface flutua sobre o desktop como um HUD de RPG.

**Plataformas:** Linux desktop · Android

---

## Funcionalidades

### Personagem e Progressão
- **6 atributos:** Força, Inteligência, Sabedoria, Destreza, Carisma, Relacionamento
- **Curva de XP quadrática:** `80 + 20L + 15L²` — rápida no início, exigente no late game
- **Rank global:** E → D → C → B → A → S baseado na soma dos atributos
- **Radar chart** dos atributos no painel principal

### Arquétipos Junguianos
Calculados dinamicamente com base nos atributos mais desenvolvidos:

| Arquétipo | Atributos | Bônus ao Lv.10 |
|---|---|---|
| ⚔ Guerreiro | Força + Destreza | +5% XP em Força e Destreza |
| ✦ Mago | Inteligência + Sabedoria | +5% XP em Inteligência e Sabedoria |
| ♛ Rei | Carisma + Relacionamento | +5% XP em Carisma e Relacionamento |
| ◈ Equilibrado | Distribuição uniforme | — |

### Quests
- **Criação livre:** título, atributos afetados, XP base (presets: 25/50/100/250/500) e dificuldade
- **Multiplicadores:** Fácil 1× · Médio 1.5× · Difícil 3× · Épico 7×
- **Preview em tempo real:** `50 × 1.5x = 75 XP por atributo`
- **Quests do sistema:** banco pré-programado com sugestões por atributo

### Diário do Herói
Ao concluir uma quest, campo opcional "O que você aprendeu?" — reflexões ficam visíveis no calendário.

### Calendário
- Grade mensal com **heatmap de XP diário** (intensidade escala com o XP ganho)
- Hoje destacado com borda dourada
- Clicar em qualquer dia exibe as quests concluídas e reflexões do Diário

### Interface
- Painéis **flutuantes e arrastáveis** — sem barra de título, fundo transparente
- Sempre no topo (always-on-top) para uso enquanto trabalha
- Tema escuro estilo Solo Leveling com bordas com glow roxo

### Sincronização
- Dados persistidos no **Supabase** (PostgreSQL na nuvem)
- Sync automático entre Linux e Android via mesma conta
- **Refresh automático** ao retomar o app (troca de foco no desktop, retorno ao primeiro plano no Android)

---

## Setup (desenvolvimento)

### Dependências do sistema (Arch/CachyOS)
```bash
sudo pacman -S cmake ninja clang pkg-config gtk3
yay -S flutter
```

### Configurar Supabase
1. Crie um projeto em [supabase.com](https://supabase.com)
2. No SQL Editor, execute:

```sql
create table profile (
  user_id uuid primary key references auth.users on delete cascade,
  name text not null default 'Jogador'
);

create table attributes (
  attribute_id text not null,
  user_id uuid not null references profile on delete cascade,
  level int not null default 1,
  current_xp int not null default 0,
  total_xp_earned int not null default 0,
  primary key (attribute_id, user_id)
);

create table quests (
  id uuid primary key,
  user_id uuid not null references profile on delete cascade,
  title text not null,
  description text not null default '',
  xp_per_attribute jsonb not null default '{}',
  difficulty text not null default 'medio',
  due_date timestamptz,
  recurrence text not null default 'none',
  status text not null default 'pending',
  created_at timestamptz not null default now(),
  completed_at timestamptz,
  reflection text,
  is_system_quest boolean not null default false
);

alter table profile enable row level security;
alter table attributes enable row level security;
alter table quests enable row level security;

create policy "own" on profile for all using (auth.uid() = user_id);
create policy "own" on attributes for all using (auth.uid() = user_id);
create policy "own" on quests for all using (auth.uid() = user_id);
```

3. Em **Authentication → Providers → Email**, desative "Confirm email"
4. Preencha `lib/core/config/supabase_config.dart` com URL e anon key do projeto

### Rodar
```bash
flutter pub get
flutter run -d linux
```

---

## Build e Distribuição

### Linux (release local)
```bash
flutter build linux --release
# Executável em: build/linux/x64/release/bundle/kings_path
```

### Android APK (via GitHub Actions — recomendado)
Crie e suba uma tag para disparar o build automático no CI:
```bash
git tag v1.0.0
git push origin v1.0.0
```

O APK e o bundle Linux ficam disponíveis em [Releases](../../releases) em ~5 minutos.

### Android APK (local, requer Android SDK)
```bash
flutter build apk --release
# APK em: build/app/outputs/flutter-apk/app-release.apk
```

---

## Stack

| | |
|---|---|
| Framework | Flutter 3.41 / Dart 3.11 |
| Backend | Supabase (PostgreSQL + Auth) |
| State | Riverpod |
| Charts | fl_chart |
| Desktop window | window_manager |
| CI/CD | GitHub Actions |

---

## Roadmap

Ver [`melhorias.md`](melhorias.md) para o backlog detalhado.
