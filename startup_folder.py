#!/usr/bin/env python3
"""
Script para adicionar atalho na pasta Startup do Windows
"""

import os
import shutil

def add_to_startup_folder():
    """Adiciona atalho na pasta Startup"""
    # Pasta Startup do usuário
    startup_folder = os.path.join(
        os.environ["APPDATA"],
        "Microsoft\\Windows\\Start Menu\\Programs\\Startup"
    )
    
    # Arquivo .pyw atual
    pyw_path = os.path.abspath("KingsPath.pyw")
    
    # Destino na pasta Startup
    startup_path = os.path.join(startup_folder, "KingsPath.pyw")
    
    try:
        # Copiar arquivo para pasta Startup
        shutil.copy2(pyw_path, startup_path)
        print(f"[STARTUP] Arquivo copiado para: {startup_path}")
        return True
    except Exception as e:
        print(f"[ERRO] Falha ao copiar: {e}")
        return False

def remove_from_startup_folder():
    """Remove atalho da pasta Startup"""
    startup_folder = os.path.join(
        os.environ["APPDATA"],
        "Microsoft\\Windows\\Start Menu\\Programs\\Startup"
    )
    
    startup_path = os.path.join(startup_folder, "KingsPath.pyw")
    
    try:
        if os.path.exists(startup_path):
            os.remove(startup_path)
            print(f"[STARTUP] Arquivo removido: {startup_path}")
        return True
    except Exception as e:
        print(f"[ERRO] Falha ao remover: {e}")
        return False

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] == "remove":
        success = remove_from_startup_folder()
    else:
        success = add_to_startup_folder()
    
    if success:
        print("\n[SUCESSO] Configuração da pasta Startup concluída!")
        if len(sys.argv) == 1:
            print("O Kings Path agora iniciará automaticamente!")
    else:
        print("\n[ERRO] Configuração falhou!")