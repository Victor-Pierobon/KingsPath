#!/usr/bin/env python3
"""
Script para configurar Kings Path para iniciar com o Windows
"""

import os
import shutil
import winreg

def setup_startup():
    """Configura inicialização automática usando arquivo batch"""
    print("[STARTUP] Configurando inicialização automática...")
    
    # Caminho do arquivo .pyw (executa sem terminal)
    pyw_path = os.path.abspath("KingsPath.pyw")
    
    if not os.path.exists(pyw_path):
        print("[ERRO] Arquivo KingsPath.pyw não encontrado.")
        return False
    
    try:
        # Adicionar ao registro do Windows
        key = winreg.OpenKey(
            winreg.HKEY_CURRENT_USER,
            r"Software\Microsoft\Windows\CurrentVersion\Run",
            0,
            winreg.KEY_SET_VALUE
        )
        
        winreg.SetValueEx(key, "KingsPath", 0, winreg.REG_SZ, pyw_path)
        winreg.CloseKey(key)
        
        print(f"[STARTUP] Adicionado ao registro: {pyw_path}")
        return True
        
    except Exception as e:
        print(f"[ERRO] Falha ao configurar startup: {e}")
        return False

def remove_startup():
    """Remove inicialização automática"""
    print("[STARTUP] Removendo inicialização automática...")
    
    try:
        key = winreg.OpenKey(
            winreg.HKEY_CURRENT_USER,
            r"Software\Microsoft\Windows\CurrentVersion\Run",
            0,
            winreg.KEY_SET_VALUE
        )
        
        winreg.DeleteValue(key, "KingsPath")
        winreg.CloseKey(key)
        print("[STARTUP] Removido do registro")
        return True
        
    except Exception as e:
        print(f"[ERRO] Falha ao remover startup: {e}")
        return False

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] == "remove":
        success = remove_startup()
    else:
        success = setup_startup()
    
    if success:
        print("\n[SUCESSO] Configuração concluída!")
        if len(sys.argv) == 1:
            print("O Kings Path agora iniciará automaticamente com o Windows!")
            print("Para remover: python setup_startup.py remove")
    else:
        print("\n[ERRO] Configuração falhou!")