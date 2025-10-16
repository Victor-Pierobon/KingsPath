#!/usr/bin/env python3
"""
Script para configurar dados de demonstração no Kings Path
"""

import os
import database

def setup_demo_data():
    """Configura dados de demonstração"""
    print("[SETUP] Configurando Kings Path...")
    
    # Inicializar banco (cria se não existir)
    database.init_db()
    print("[SETUP] Banco inicializado")
    
    # Adicionar missões de exemplo
    demo_missions = [
        ("Fazer 30 minutos de exercício", 25, "Força"),
        ("Ler 20 páginas de um livro", 30, "Inteligência"),
        ("Ter uma conversa significativa com alguém", 20, "Carisma"),
        ("Meditar por 15 minutos", 25, "Sabedoria"),
        ("Economizar R$ 50 hoje", 15, "Riqueza"),
        ("Ligar para um amigo ou familiar", 25, "Relacionamento"),
        ("Fazer flexões até a falha", 20, "Força"),
        ("Aprender algo novo online", 25, "Inteligência"),
        ("Ajudar alguém sem esperar nada em troca", 30, "Carisma"),
        ("Refletir sobre o dia no diário", 20, "Sabedoria"),
        ("Pesquisar investimentos por 30 min", 25, "Riqueza"),
        ("Sair com amigos ou família", 30, "Relacionamento")
    ]
    
    for description, xp, attribute in demo_missions:
        database.add_mission(description, xp, attribute)
    
    print(f"[SETUP] {len(demo_missions)} missões de exemplo adicionadas!")
    
    print("\n[MISSOES] Missões ativas no banco:")
    missions = database.get_active_missions()
    print(f"Total: {len(missions)} missões")
    
    for i, mission in enumerate(missions[-5:], 1):  # Mostrar apenas as últimas 5
        print(f"  {i}. {mission['description']} (+{mission['reward_xp']} XP em {mission['attribute_name']})")
    
    if len(missions) > 5:
        print(f"  ... e mais {len(missions) - 5} missões")
    
    print(f"\n[SUCESSO] Tudo pronto! Execute 'python main.py' para começar sua jornada!")

if __name__ == "__main__":
    setup_demo_data()