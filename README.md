# Kings Path - Gestor Gamificado de Evolução Pessoal

Um aplicativo inspirado em Solo Leveling para gamificar seu desenvolvimento pessoal através de missões e evolução de atributos.

## 🎮 Funcionalidades

### ✅ Implementadas
- **Sistema de Atributos**: 5 atributos principais (Força, Inteligência, Carisma, Sabedoria, Riqueza)
- **Sistema de XP e Níveis**: Cada atributo evolui independentemente
- **Gerenciamento de Missões**: Adicione, complete e delete missões
- **Status Geral**: Página com nível geral e gráfico radar dos atributos
- **Interface Gráfica**: Interface futurista com transparência e cores azul/roxo
- **Tema Visual**: Design inspirado em Solo Leveling com efeitos de brilho

### 📊 Status Geral
- **Nível Geral**: Calculado pela média dos níveis dos atributos
- **Gráfico Radar**: Visualização dos níveis de todos os atributos
- **Detalhes dos Atributos**: Progresso detalhado de cada atributo

## 🚀 Como Usar

### Instalação
```bash
# Clone o repositório
cd KingsPath

# Instale as dependências
pip install -r requirements.txt
```

### Configurar Dados de Demonstração
```bash
python setup_demo.py
```

### Executar o App
```bash
python main.py
```

### Testar Funcionalidades
```bash
python test_app.py
```

## 🎯 Como Funciona

1. **Adicionar Missões**: Use o formulário para criar novas missões
   - Descrição da missão
   - Quantidade de XP de recompensa
   - Atributo que será beneficiado

2. **Completar Missões**: Clique em "Concluir" para ganhar XP
   - O XP é automaticamente adicionado ao atributo correspondente
   - Níveis aumentam automaticamente quando o XP necessário é atingido

3. **Ver Status Geral**: Clique em "Ver Status Geral"
   - Visualize seu nível geral
   - Veja o gráfico radar com todos os atributos
   - Acompanhe o progresso detalhado

## 🔧 Estrutura do Projeto

- `main.py` - Interface principal do aplicativo
- `models.py` - Classes Player e Attribute
- `database.py` - Gerenciamento do banco de dados SQLite
- `status_window.py` - Janela de status geral com gráfico radar
- `status_window_simple.py` - Janela de status geral (versão simplificada)
- `setup_demo.py` - Script para configurar dados de demonstração
- `styles.py` - Estilos futuristas do aplicativo
- `demo_visual.py` - Demonstração do tema visual
- `test_app.py` - Script de testes
- `kings_path.db` - Banco de dados SQLite (criado automaticamente)

## 🎨 Próximas Funcionalidades
- Sistema de conquistas/achievements
- Diferentes tipos de missões (diárias, semanais, mensais)
- Sistema de recompensas especiais
- Histórico de progresso
- Exportar/importar dados
- Temas personalizáveis
- Notificações de level up
- Sistema de streaks (sequências de dias)

## 🐛 Problemas Resolvidos

- ✅ Missões não apareciam na lista (corrigido)
- ✅ Bugs de sintaxe no código (corrigidos)
- ✅ Problemas de inicialização do banco de dados (corrigidos)
- ✅ Interface de status geral implementada
- ✅ Função level_up corrigida no modelo Attribute
- ✅ Função items() corrigida no modelo Player
- ✅ Bugs no database.py corrigidos (cursor, DB_NAME)
- ✅ Interface melhorada com estilos e feedback visual
- ✅ Barra de rolagem adicionada na lista de missões
- ✅ Gráfico radar implementado com matplotlib
- ✅ Problema do numpy/matplotlib resolvido
- ✅ Tema futurista implementado com transparência
- ✅ Cores azul e roxo com efeitos de brilho
- ✅ Ícones e emojis adicionados para melhor UX

## 📝 Notas Técnicas

- **Banco de Dados**: SQLite para persistência local
- **Interface**: PyQt6 para interface gráfica moderna
- **Gráficos**: Matplotlib para visualização de dados
- **Arquitetura**: MVC simplificado com separação de responsabilidades