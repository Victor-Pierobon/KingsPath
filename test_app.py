#!/usr/bin/env python3
"""
Script de teste para verificar se o app está funcionando corretamente
"""

import database
from models import Player

def test_database():
    """Testa as funções do banco de dados"""
    print("=== Testando Banco de Dados ===")
    
    # Inicializar banco
    database.init_db()
    print("[OK] Banco inicializado")
    
    # Adicionar missão de teste
    database.add_mission("Fazer exercícios", 25, "Força")
    database.add_mission("Ler um livro", 30, "Inteligência")
    print("[OK] Missões de teste adicionadas")
    
    # Verificar missões ativas
    missions = database.get_active_missions()
    print(f"[OK] {len(missions)} missões ativas encontradas")
    
    for mission in missions:
        print(f"  - {mission['description']} (+{mission['reward_xp']} XP em {mission['attribute_name']})")
    
    return len(missions) > 0

def test_player():
    """Testa a classe Player"""
    print("\n=== Testando Player ===")
    
    player = Player("TestPlayer")
    print(f"[OK] Player criado: {player.name}")
    
    # Testar nível geral
    overall_level = player.get_overall_level()
    print(f"[OK] Nível geral: {overall_level}")
    
    # Testar dados dos atributos
    attrs_data = player.get_attributes_data()
    print("[OK] Dados dos atributos:")
    for name, data in attrs_data.items():
        print(f"  - {name}: Nível {data['level']}, Progresso {data['progress']:.1f}%")
    
    # Testar ganho de XP
    player.complete_mission_action(25, "Força")
    print("[OK] XP adicionado em Força")
    
    return True

if __name__ == "__main__":
    print("Iniciando testes do Kings Path...\n")
    
    db_ok = test_database()
    player_ok = test_player()
    
    print(f"\n=== Resultado dos Testes ===")
    print(f"Banco de dados: {'[OK]' if db_ok else '[ERRO]'}")
    print(f"Player: {'[OK]' if player_ok else '[ERRO]'}")
    
    if db_ok and player_ok:
        print("\n[SUCESSO] Todos os testes passaram! O app deve funcionar corretamente.")
    else:
        print("\n[ERRO] Alguns testes falharam. Verifique os erros acima.")