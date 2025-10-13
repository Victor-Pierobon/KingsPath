#!/usr/bin/env python3
"""
Script para demonstrar o visual futurista do Kings Path
"""

import sys
from PyQt6.QtWidgets import QApplication
from main import MainWindow

def demo_visual():
    """Demonstra o visual futurista do app"""
    print("[DEMO VISUAL] Iniciando Kings Path com tema futurista...")
    print("🎨 Características do novo visual:")
    print("  ✨ Transparência sutil")
    print("  🔮 Cores roxo e azul ciano")
    print("  🌟 Efeitos de brilho (glow)")
    print("  🚀 Design futurista")
    print("  📱 Interface moderna")
    print("\n🎮 Execute o app para ver o visual!")

if __name__ == "__main__":
    demo_visual()
    
    # Opcional: abrir o app diretamente
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec())