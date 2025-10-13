#!/usr/bin/env python3
"""
Script para simular progresso nos atributos para demonstração
"""

from models import Player

def demo_progress():
    """Simula progresso nos atributos"""
    print("[DEMO] Simulando progresso nos atributos...")
    
    player = Player("DemoPlayer")
    
    # Simular progresso em diferentes atributos
    progress_data = [
        ("Força", 150),      # Vai subir para nível 2
        ("Inteligência", 80), # Progresso no nível 1
        ("Carisma", 200),    # Vai subir para nível 2
        ("Sabedoria", 50),   # Progresso no nível 1
        ("Riqueza", 300)     # Vai subir para nível 3
    ]
    
    print("\n[PROGRESSO] Aplicando XP nos atributos:")
    for attr_name, xp in progress_data:
        player.complete_mission_action(xp, attr_name)
        print(f"  - {attr_name}: +{xp} XP")
    
    print(f"\n[RESULTADO] Status final:")
    print(f"Nível Geral: {player.get_overall_level()}")
    
    attrs_data = player.get_attributes_data()
    for name, data in attrs_data.items():
        print(f"  - {name}: Nível {data['level']} ({data['progress']:.1f}%)")
    
    print(f"\n[INFO] Execute 'python main.py' e clique em 'Ver Status Geral' para ver o gráfico!")

if __name__ == "__main__":
    demo_progress()